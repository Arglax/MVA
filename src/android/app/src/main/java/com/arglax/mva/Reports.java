package com.arglax.mva;

import android.app.Activity;
import android.app.ActivityManager;
import android.app.AlertDialog;
import android.app.ApplicationExitInfo;
import android.content.SharedPreferences;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import org.json.JSONObject;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.security.MessageDigest;
import java.util.ArrayDeque;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

final class Reports {
    private static final String TAG = "MVA";
    private static final String CUT = "<redacted>";
    private static final int MAX_PROMPTS = 3;
    private static final int MAX_ERROR = 1000;
    private static final int MAX_STACK = 8192;
    private static final int MAX_LOG = 48 * 1024;
    private static final int SHORT_LOG = 16 * 1024;
    private static final String[] FULL_ONLY = {"mem", "fps", "temp", "uptimeMs", "settings", "log"};

    private static final String KEY = "((?:pass|pwd|pword|token|auth|session|user|login|nick|unm)[A-Za-z0-9_-]{0,32})";

    private static final Pattern KEYED_QUOTED = Pattern.compile("(?i)" + KEY + "(\"?\\s*[:=]\\s*\")((?:[^\"\\\\\\r\\n]|\\\\.)*+)(?=\")");
    private static final Pattern KEYED = Pattern.compile("(?i)" + KEY + "(\"?\\s*[:=]\\s*\"?)([^\\s\"&,;<>}\\]]+)");
    private static final Pattern BEARER = Pattern.compile("(?i)\\b(Bearer\\s+)[A-Za-z0-9._~+/=-]+");
    private static final Pattern TAGGED = Pattern.compile("(?i)<(nick|pword|unm|pwd|login|token)>(<!\\[CDATA\\[)?[^<\\]]*");
    private static final Pattern EMAIL = Pattern.compile("(?<![A-Za-z0-9._%+-])[A-Za-z0-9._%+-]{1,64}@[A-Za-z0-9.-]{1,255}\\.[A-Za-z]{2,}");
    private static final Pattern USER_PATH = Pattern.compile("(?i)(/home/|/Users/|[A-Z]:[\\\\/]Users[\\\\/])[^/\\\\\\s\"']+");
    private static final Pattern LONG_KEY = Pattern.compile("\\b[A-Fa-f0-9]{32,}\\b|\\beyJ[A-Za-z0-9_\\-]{10,}\\.[A-Za-z0-9_\\-.]+");

    private final Activity activity;
    private final Telemetry telemetry;
    private final Handler main = new Handler(Looper.getMainLooper());
    private final ArrayDeque<JSONObject> waiting = new ArrayDeque<>();
    private final Set<String> asked = new HashSet<>();
    private final File crashFile;
    private int prompts;
    private boolean showing;
    private boolean visible;
    private static boolean handlerSet;

    Reports(Activity activity, Telemetry telemetry) {
        this.activity = activity;
        this.telemetry = telemetry;
        crashFile = new File(activity.getFilesDir(), "last_fault.json");
    }

    static String scrub(String text, String[] names) {
        if (text == null || text.isEmpty()) return "";
        String s = text;
        if (names != null) {
            for (String n : names) {
                if (n == null || n.length() < 3) continue;
                s = Pattern.compile(Pattern.quote(n), Pattern.CASE_INSENSITIVE).matcher(s).replaceAll(Matcher.quoteReplacement(CUT));
            }
        }
        s = BEARER.matcher(s).replaceAll("$1" + Matcher.quoteReplacement(CUT));
        s = KEYED_QUOTED.matcher(s).replaceAll("$1$2" + Matcher.quoteReplacement(CUT));
        s = KEYED.matcher(s).replaceAll("$1$2" + Matcher.quoteReplacement(CUT));
        s = TAGGED.matcher(s).replaceAll("<$1>" + Matcher.quoteReplacement(CUT));
        s = EMAIL.matcher(s).replaceAll(Matcher.quoteReplacement(CUT));
        s = USER_PATH.matcher(s).replaceAll("$1" + Matcher.quoteReplacement(CUT));
        s = LONG_KEY.matcher(s).replaceAll(Matcher.quoteReplacement(CUT));
        return s;
    }

    private String clean(String text, int max) {
        return Telemetry.trim(scrub(Telemetry.trim(text, max * 2), telemetry.names()), max);
    }

    static String signature(String kind, String error, String stack) {
        StringBuilder b = new StringBuilder(kind).append('\n').append(normal(error));
        int frames = 0;
        for (String line : String.valueOf(stack).split("\n")) {
            String l = line.trim();
            if (l.isEmpty()) continue;
            b.append('\n').append(normal(l));
            if (++frames >= 6) break;
        }
        try {
            byte[] h = MessageDigest.getInstance("SHA-256").digest(b.toString().getBytes(StandardCharsets.UTF_8));
            StringBuilder hex = new StringBuilder();
            for (int i = 0; i < 8; i++) hex.append(String.format("%02x", h[i]));
            return hex.toString();
        } catch (Exception e) {
            return Integer.toHexString(b.toString().hashCode());
        }
    }

    private static String normal(String s) {
        return String.valueOf(s).replaceAll("0x[0-9a-fA-F]+", "#").replaceAll("\\d+", "#").replaceAll("\\s+", " ").trim();
    }

    JSONObject capture(String kind, String error, String stack, JSONObject contextOverride) {
        JSONObject it = new JSONObject();
        try {
            it.put("kind", kind);
            it.put("ts", System.currentTimeMillis());
            it.put("app", Telemetry.appVersion());
            it.put("error", clean(error, MAX_ERROR));
            it.put("stack", clean(stack, MAX_STACK));
            JSONObject context = new JSONObject();
            JSONObject from = contextOverride;
            if (from == null) {
                try {
                    from = new JSONObject(telemetry.contextJson());
                } catch (Exception e) {
                    from = new JSONObject();
                }
            }
            for (String k : new String[]{"screen", "feature", "map"}) context.put(k, clean(from.optString(k, ""), 60));
            it.put("context", context);
            JSONObject mem = new JSONObject();
            mem.put("appMb", telemetry.lastAppMb());
            mem.put("freeMb", telemetry.freeRamMb());
            mem.put("wasmMb", telemetry.pageMb());
            it.put("mem", mem);
            it.put("fps", telemetry.lastFps());
            it.put("temp", telemetry.batteryTemp());
            it.put("uptimeMs", telemetry.uptimeMs());
            JSONObject settings = new JSONObject();
            try {
                JSONObject s = new JSONObject(telemetry.settingsJson());
                for (Iterator<String> keys = s.keys(); keys.hasNext() && settings.length() < 60; ) {
                    String k = keys.next();
                    Object v = s.get(k);
                    if (!k.matches("[A-Za-z][A-Za-z0-9_]{0,39}")) continue;
                    if (v instanceof Boolean || v instanceof Number) settings.put(k, v);
                    else if (v instanceof String) settings.put(k, clean((String) v, 80));
                }
            } catch (Exception ignored) {
            }
            it.put("settings", settings);
            String log = scrub(telemetry.logTail(), telemetry.names());
            it.put("log", log.length() > MAX_LOG ? log.substring(log.length() - MAX_LOG) : log);
        } catch (Exception ignored) {
        }
        return it;
    }

    private JSONObject document(JSONObject it, boolean full) throws Exception {
        JSONObject d = new JSONObject(it.toString());
        d.put("consent", full ? "full" : "minimal");
        d.put("signature", signature(d.optString("kind"), d.optString("error"), d.optString("stack")));
        if (full) {
            d.put("install", telemetry.install());
            d.put("device", telemetry.device());

            String log = d.optString("log", "");
            if (!telemetry.remote().fullLog && log.length() > SHORT_LOG) d.put("log", log.substring(log.length() - SHORT_LOG));
        } else {
            for (String k : FULL_ONLY) d.remove(k);
        }
        return d;
    }

    void watchCrashes() {
        if (handlerSet) return;
        handlerSet = true;
        final Thread.UncaughtExceptionHandler before = Thread.getDefaultUncaughtExceptionHandler();
        Thread.setDefaultUncaughtExceptionHandler((thread, error) -> {
            try {
                StringWriter w = new StringWriter();
                error.printStackTrace(new PrintWriter(w));
                String first = error.getClass().getName() + ": " + error.getMessage();
                saveForNextStart(capture("crash", first, w.toString(), null));
            } catch (Throwable ignored) {
            }
            if (before != null) before.uncaughtException(thread, error);
        });
    }

    void saveForNextStart(JSONObject it) {
        try (FileOutputStream out = new FileOutputStream(crashFile)) {
            out.write(it.toString().getBytes(StandardCharsets.UTF_8));
        } catch (Throwable ignored) {
        }
    }

    void checkLastRun() {
        telemetry.run(() -> {
            JSONObject saved = null;
            try {
                if (crashFile.exists()) saved = new JSONObject(new String(Files.readAllBytes(crashFile.toPath()), StandardCharsets.UTF_8));
            } catch (Throwable ignored) {
            }
            crashFile.delete();
            JSONObject fromSystem = null;
            boolean counted = false;
            if (Build.VERSION.SDK_INT >= 30) {
                try {
                    fromSystem = readExits();
                    counted = true;
                } catch (Throwable e) {
                    Log.i(TAG, "[Report] exit records: " + e.getClass().getSimpleName());
                }
            }
            if (saved != null && !counted && "crash".equals(saved.optString("kind"))) telemetry.health("crashes", 1);
            final JSONObject it = saved != null ? saved : fromSystem;
            if (it != null) main.post(() -> offer(it, true));
        });
    }

    private JSONObject readExits() throws Exception {
        if (Build.VERSION.SDK_INT < 30) return null;
        SharedPreferences prefs = activity.getSharedPreferences("mva.telemetry", Activity.MODE_PRIVATE);
        long seen = prefs.getLong("exitSeen", -1);

        if (seen < 0) {
            prefs.edit().putLong("exitSeen", System.currentTimeMillis()).apply();
            return null;
        }
        long newest = seen;
        JSONObject found = null;
        ActivityManager am = activity.getSystemService(ActivityManager.class);
        List<ApplicationExitInfo> list = am.getHistoricalProcessExitReasons(null, 0, 16);

        Set<Integer> pids = new HashSet<>();
        for (ApplicationExitInfo info : list) {
            if (info.getTimestamp() <= seen || !activity.getPackageName().equals(info.getProcessName())) continue;
            newest = Math.max(newest, info.getTimestamp());
            if (!pids.add(info.getPid())) continue;
            int reason = info.getReason();
            telemetry.health("exitReasons." + reasonName(reason), 1);
            boolean crash = reason == ApplicationExitInfo.REASON_CRASH || reason == ApplicationExitInfo.REASON_CRASH_NATIVE
                    || reason == ApplicationExitInfo.REASON_INITIALIZATION_FAILURE;
            boolean anr = reason == ApplicationExitInfo.REASON_ANR;
            if (crash) telemetry.health("crashes", 1);
            if (anr) telemetry.health("anr", 1);
            if ((crash || anr) && found == null) {
                String what = reason == ApplicationExitInfo.REASON_CRASH_NATIVE ? "Native crash" : anr ? "App not responding" : "Crash";
                String detail = info.getDescription() == null ? "" : info.getDescription();
                String stack = anr ? mainThread(info) : "";
                JSONObject it = capture("crash", what + ": " + detail, stack, new JSONObject());

                for (String k : new String[]{"mem", "fps", "temp", "uptimeMs", "log"}) it.remove(k);
                it.put("ts", info.getTimestamp());
                found = it;
            }
        }
        if (newest != seen) prefs.edit().putLong("exitSeen", newest).apply();
        return found;
    }

    private static String mainThread(ApplicationExitInfo info) {
        if (Build.VERSION.SDK_INT < 30) return "";
        try (InputStream in = info.getTraceInputStream()) {
            if (in == null) return "";
            ByteArrayOutputStream out = new ByteArrayOutputStream();
            byte[] buf = new byte[8192];
            int n;
            while (out.size() < 256 * 1024 && (n = in.read(buf)) > 0) out.write(buf, 0, n);
            String all = new String(out.toByteArray(), StandardCharsets.UTF_8);
            int at = all.indexOf("\"main\"");
            if (at < 0) return "";
            int end = all.indexOf("\n\n", at);
            return all.substring(at, end < 0 ? Math.min(all.length(), at + MAX_STACK) : Math.min(end, at + MAX_STACK));
        } catch (Throwable e) {
            return "";
        }
    }

    private static String reasonName(int reason) {
        switch (reason) {
            case ApplicationExitInfo.REASON_EXIT_SELF: return "exitSelf";
            case ApplicationExitInfo.REASON_SIGNALED: return "signaled";
            case ApplicationExitInfo.REASON_LOW_MEMORY: return "lowMemory";
            case ApplicationExitInfo.REASON_CRASH: return "crash";
            case ApplicationExitInfo.REASON_CRASH_NATIVE: return "crashNative";
            case ApplicationExitInfo.REASON_ANR: return "anr";
            case ApplicationExitInfo.REASON_INITIALIZATION_FAILURE: return "initFailure";
            case ApplicationExitInfo.REASON_PERMISSION_CHANGE: return "permissionChange";
            case ApplicationExitInfo.REASON_EXCESSIVE_RESOURCE_USAGE: return "excessiveResources";
            case ApplicationExitInfo.REASON_USER_REQUESTED: return "userRequested";
            case ApplicationExitInfo.REASON_USER_STOPPED: return "userStopped";
            case ApplicationExitInfo.REASON_DEPENDENCY_DIED: return "dependencyDied";
            case ApplicationExitInfo.REASON_OTHER: return "other";

            case 14: return "freezer";
            case 15: return "packageStateChange";
            case 16: return "packageUpdated";
            default: return "reason" + reason;
        }
    }

    void fault(String kind, String error, String stack, JSONObject context) {
        final JSONObject it = capture(kind, error, stack, context);
        main.post(() -> offer(it, false));
    }

    private void offer(JSONObject it, boolean fromLastRun) {
        if (!Telemetry.configured() || !telemetry.remote().reports) return;
        String sig = signature(it.optString("kind"), it.optString("error"), it.optString("stack"));
        if (!fromLastRun && (asked.contains(sig) || prompts + waiting.size() >= MAX_PROMPTS)) return;
        asked.add(sig);
        waiting.addLast(it);
        showNext();
    }

    void onVisible(boolean on) {
        visible = on;
        if (on) showNext();
    }

    private void showNext() {
        if (showing || !visible || waiting.isEmpty() || activity.isFinishing() || activity.isDestroyed()) return;
        final JSONObject it = waiting.removeFirst();
        showing = true;
        prompts++;
        boolean crashed = !"problem".equals(it.optString("kind"));
        try {

            AlertDialog dialog = new AlertDialog.Builder(activity, android.R.style.Theme_DeviceDefault_Dialog_Alert)
                    .setTitle(crashed ? "MVA has crashed" : "MVA ran into a problem")
                    .setMessage("Do you want to submit the crash report to Arglax?\n\n"
                            + "Yes: the full report with your phone's specs and country.\n"
                            + "No: only the error itself, with nothing about you or your phone.")
                    .setCancelable(false)
                    .setNegativeButton("Yes", (d, w) -> answered(it, true))
                    .setPositiveButton("No", (d, w) -> answered(it, false))
                    .create();
            dialog.setCanceledOnTouchOutside(false);
            dialog.show();
        } catch (Throwable e) {
            showing = false;
        }
    }

    private void answered(JSONObject it, boolean full) {
        showing = false;
        try {
            JSONObject doc = document(it, full);
            if (allowedToday(doc.optString("signature"))) telemetry.sendReport(doc);
        } catch (Exception ignored) {
        }
        main.post(this::showNext);
    }

    private boolean allowedToday(String signature) {
        Telemetry.Remote r = telemetry.remote();
        if (!r.reports) return false;
        SharedPreferences prefs = activity.getSharedPreferences("mva.telemetry", Activity.MODE_PRIVATE);
        String day = String.valueOf(System.currentTimeMillis() / 86400000L);
        boolean today = day.equals(prefs.getString("reportDay", ""));
        int sent = today ? prefs.getInt("reportCount", 0) : 0;
        String sigs = today ? prefs.getString("reportSigs", "") : "";
        if (sent >= r.perDay || ("," + sigs + ",").contains("," + signature + ",")) return false;
        prefs.edit().putString("reportDay", day).putInt("reportCount", sent + 1)
                .putString("reportSigs", sigs.isEmpty() ? signature : sigs + "," + signature).apply();
        return true;
    }
}
