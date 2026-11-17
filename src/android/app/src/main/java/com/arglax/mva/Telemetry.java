package com.arglax.mva;

import android.app.ActivityManager;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.content.pm.PackageInfo;
import android.hardware.display.DisplayManager;
import android.os.BatteryManager;
import android.os.Build;
import android.os.Debug;
import android.os.PowerManager;
import android.telephony.TelephonyManager;
import android.util.Log;
import android.view.Display;
import android.webkit.WebView;

import org.json.JSONArray;
import org.json.JSONObject;

import java.io.InputStream;
import java.io.OutputStream;
import java.security.MessageDigest;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.Date;
import java.util.Iterator;
import java.util.List;
import java.util.Locale;
import java.util.TimeZone;
import java.util.UUID;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.regex.Pattern;

final class Telemetry {
    private static final String TAG = "MVA";
    private static final String PREFS = "mva.telemetry";
    private static final int TIMEOUT_MS = 15000;
    private static final String REMOTE_URL = "https://raw.githubusercontent.com/Arglax/MVA/main/telemetry.json";
    private static final int SCHEMA = 2;
    private static final int MAX_DAYS = 400;
    private static final int MAX_PENDING = 1500;
    private static final int MAX_TRANSFORMS = 400;
    private static final int LOG_LINES = 200;
    private static final int LOG_CHARS = 48 * 1024;
    private static final Pattern FEATURE_ID = Pattern.compile("[a-z][a-zA-Z0-9_]{0,47}(\\.(on|off))?");
    private static final Pattern HEALTH_ID = Pattern.compile("[a-z][a-zA-Z0-9_]{0,31}(\\.[a-z][a-zA-Z0-9_]{0,31})?");

    private final Context app;
    private final SharedPreferences prefs;
    private final String install;
    private final String version;
    private final ExecutorService io = Executors.newSingleThreadExecutor();
    private final long sessionStart = System.currentTimeMillis();
    private final Object lock = new Object();
    private final ArrayDeque<String> logRing = new ArrayDeque<>();

    private volatile boolean enabled;

    private JSONObject pending;
    private boolean deviceDue = true;
    private JSONObject device;

    private final boolean carried;
    private volatile String moment = "tick";
    private volatile double jitter = Math.random() * 0.2;
    private volatile boolean startDone;
    private volatile Remote remote = Remote.DEFAULTS;

    private volatile double lastFps;
    private volatile int lastAppMb;
    private volatile int lastPageMb;
    private volatile String lastSettings = "";
    private volatile String lastContext = "";
    private volatile String[] names = new String[0];

    Telemetry(Context context) {
        app = context.getApplicationContext();
        prefs = app.getSharedPreferences(PREFS, Context.MODE_PRIVATE);
        String id = prefs.getString("install", null);
        if (id == null) {
            id = UUID.randomUUID().toString();
            prefs.edit().putString("install", id).apply();
        }
        install = id;
        enabled = prefs.getBoolean("enabled", true);
        version = BuildConfig.VERSION_NAME;
        try {
            pending = new JSONObject(prefs.getString("pending", "{}"));
        } catch (Exception e) {
            pending = new JSONObject();
        }
        carried = hasCounts(pending);
        remote = Remote.parse(prefs.getString("remote", null));
        if (configured()) io.execute(this::fetchRemote);
    }

    private static boolean hasCounts(JSONObject p) {
        for (String kind : new String[]{"inc", "min", "max"}) {
            JSONObject m = p.optJSONObject(kind);
            if (m != null && m.length() > 0) return true;
        }
        JSONArray del = p.optJSONArray("del");
        return del != null && del.length() > 0;
    }

    static final class Remote {
        static final Remote DEFAULTS = new Remote(true, 60, 1.0, true, 3, true);
        final boolean usage;
        final int minMinutes;
        final double sample;
        final boolean reports;
        final int perDay;
        final boolean fullLog;

        Remote(boolean usage, int minMinutes, double sample, boolean reports, int perDay, boolean fullLog) {
            this.usage = usage;
            this.minMinutes = minMinutes;
            this.sample = sample;
            this.reports = reports;
            this.perDay = perDay;
            this.fullLog = fullLog;
        }

        static Remote parse(String json) {
            if (json == null) return DEFAULTS;
            try {
                JSONObject j = new JSONObject(json);
                if (j.optInt("v", 0) != 1) return DEFAULTS;
                JSONObject u = j.optJSONObject("usage"), r = j.optJSONObject("reports");
                if (u == null) u = new JSONObject();
                if (r == null) r = new JSONObject();
                double sample = u.optDouble("sample", 1.0);
                if (Double.isNaN(sample)) sample = 1.0;
                return new Remote(u.optBoolean("enabled", true),
                        Math.max(10, Math.min(1440, u.optInt("minMinutes", 60))),
                        Math.max(0, Math.min(1, sample)),
                        r.optBoolean("enabled", true),
                        Math.max(0, Math.min(10, r.optInt("perDay", 3))),
                        r.optBoolean("fullLog", true));
            } catch (Exception e) {
                return DEFAULTS;
            }
        }
    }

    Remote remote() {
        return remote;
    }

    private void fetchRemote() {
        long now = System.currentTimeMillis();
        if (now - prefs.getLong("remoteAt", 0) < 24 * 3600 * 1000L) {
            settingsLog("skipped, cached copy used (" + (prefs.getString("remote", null) != null ? "file" : "defaults") + ")");
            return;
        }
        HttpURLConnection c = null;
        try {
            c = (HttpURLConnection) new URL(REMOTE_URL).openConnection();
            c.setConnectTimeout(5000);
            c.setReadTimeout(5000);
            String etag = prefs.getString("remoteEtag", null);
            if (etag != null && prefs.getString("remote", null) != null) c.setRequestProperty("If-None-Match", etag);
            int code = c.getResponseCode();
            SharedPreferences.Editor e = prefs.edit().putLong("remoteAt", now);
            if (code == 200) {
                StringBuilder b = new StringBuilder();
                try (InputStream in = c.getInputStream()) {
                    byte[] buf = new byte[4096];
                    int n;
                    while (b.length() < 16384 && (n = in.read(buf)) > 0) b.append(new String(buf, 0, n, StandardCharsets.UTF_8));
                }
                remote = Remote.parse(b.toString());
                e.putString("remote", b.toString());
                String tag = c.getHeaderField("ETag");
                if (tag != null) e.putString("remoteEtag", tag); else e.remove("remoteEtag");
            } else if (code != 304) {

                remote = Remote.DEFAULTS;
                e.remove("remote").remove("remoteEtag");
            }
            e.apply();
            settingsLog(code + (code == 200 ? ", new copy cached" : code == 304 ? ", cached copy used" : ", defaults"));
        } catch (Exception e) {
            settingsLog("not read: " + e.getClass().getSimpleName() + ", "
                    + (prefs.getString("remote", null) != null ? "cached copy used" : "defaults"));
        } finally {
            if (c != null) c.disconnect();
        }
    }

    private void settingsLog(String what) {
        Log.i(TAG, "[Settings] " + what);
        logLine("[Settings] " + what);
    }

    private boolean sampled() {
        Remote r = remote;
        if (r.sample >= 1) return true;
        try {
            byte[] h = MessageDigest.getInstance("SHA-256").digest(install.getBytes(StandardCharsets.UTF_8));
            long v = ((h[0] & 0xFFL) << 24) | ((h[1] & 0xFFL) << 16) | ((h[2] & 0xFFL) << 8) | (h[3] & 0xFFL);
            return v / 4294967296.0 < r.sample;
        } catch (Exception e) {
            return true;
        }
    }

    static boolean configured() {
        return !BuildConfig.TELEMETRY_KEY.isEmpty() && !BuildConfig.TELEMETRY_PROJECT.isEmpty();
    }

    String install() {
        return install;
    }

    static String appVersion() {
        return BuildConfig.VERSION_NAME + " (" + BuildConfig.VERSION_CODE + ")";
    }

    long uptimeMs() {
        return System.currentTimeMillis() - sessionStart;
    }

    void run(Runnable r) {
        io.execute(r);
    }

    boolean enabled() {
        return enabled;
    }

    void setEnabled(boolean on) {
        enabled = on;
        prefs.edit().putBoolean("enabled", on).apply();
        if (!on) {
            synchronized (lock) {
                pending = new JSONObject();
                prefs.edit().remove("pending").apply();
            }
        }
    }

    void logLine(String text) {
        if (text == null) return;
        String line = new SimpleDateFormat("HH:mm:ss", Locale.US).format(new Date()) + " " + trim(text, 300);
        synchronized (logRing) {
            logRing.addLast(line);
            while (logRing.size() > LOG_LINES) logRing.removeFirst();
        }
    }

    String logTail() {
        StringBuilder b = new StringBuilder();
        synchronized (logRing) {
            for (String l : logRing) b.append(l).append('\n');
        }
        return b.length() > LOG_CHARS ? b.substring(b.length() - LOG_CHARS) : b.toString();
    }

    String[] names() {
        return names;
    }

    void count(String id) {
        if (id == null || !FEATURE_ID.matcher(id).matches()) return;
        add("inc", "features." + id, 1);
        save();
    }

    void health(String key, long n) {
        if (key == null || n <= 0 || !HEALTH_ID.matcher(key).matches()) return;
        add("inc", "health." + key, n);
        save();
    }

    private void add(String kind, String path, double v) {
        if (!enabled || !configured()) return;
        synchronized (lock) {
            try {
                JSONObject m = pending.optJSONObject(kind);
                if (m == null) {
                    m = new JSONObject();
                    pending.put(kind, m);
                }
                if (!m.has(path)) {
                    if (m.length() >= MAX_PENDING) return;
                    m.put(path, v);
                } else {
                    double old = m.getDouble(path);
                    m.put(path, "inc".equals(kind) ? old + v : "min".equals(kind) ? Math.min(old, v) : Math.max(old, v));
                }
            } catch (Exception ignored) {
            }
        }
    }

    private void save() {
        synchronized (lock) {
            prefs.edit().putString("pending", pending.toString()).apply();
        }
    }

    void stats(String json) {
        try {
            JSONObject j = new JSONObject(json);
            remember(j);
            JSONObject minute = j.optJSONObject("minute");
            if (minute != null) io.execute(() -> minute(minute));
        } catch (Exception ignored) {
        }
    }

    void remember(JSONObject j) {
        JSONObject s = j.optJSONObject("settings");
        if (s != null) lastSettings = s.toString();
        JSONObject c = j.optJSONObject("context");
        if (c != null) lastContext = c.toString();
        if (j.has("pageMb")) lastPageMb = Math.max(0, j.optInt("pageMb", 0));
        if (j.has("fps")) lastFps = j.optDouble("fps", lastFps);
        JSONArray n = j.optJSONArray("names");
        if (n != null) {
            List<String> out = new ArrayList<>();
            for (int i = 0; i < n.length() && out.size() < 4; i++) {
                String v = n.optString(i, "").trim();
                if (v.length() >= 3 && v.length() <= 64) out.add(v);
            }

            if (!out.isEmpty()) names = out.toArray(new String[0]);
        }
    }

    String settingsJson() {
        return lastSettings;
    }

    String contextJson() {
        return lastContext;
    }

    double lastFps() {
        return lastFps;
    }

    private void minute(JSONObject m) {
        if (!enabled || !configured()) return;
        double fps = m.optDouble("fps", 0);
        int lo = m.optInt("lo", 0), hi = m.optInt("hi", 0);
        if (!(fps > 0) || lo <= 0 || hi <= 0 || fps > 1000) return;
        fps = Math.round(fps * 10) / 10.0;
        lastFps = fps;
        int appMb = appMb();
        int ramMb = deviceRamMb();
        double pct = ramMb > 0 ? Math.round(appMb * 1000.0 / ramMb) / 10.0 : 0;
        double temp = batteryTemp();
        String day = "perfDays.d" + utc("yyyyMMdd") + ".";
        for (String base : new String[]{"perf.", day}) {
            add("inc", base + "n", 1);
            add("inc", base + "fpsSum", fps);
            add("min", base + "fpsMin", lo);
            add("max", base + "fpsMax", hi);
            add("inc", base + "ramSum", appMb);
            add("max", base + "ramPeak", appMb);
            add("inc", base + "ramPctSum", pct);
        }
        if (temp > 0) {
            add("inc", "perf.tempSum", temp);
            add("max", "perf.tempPeak", temp);
        }
        if (hot()) add("inc", "perf.hot", 1);
        add("inc", "fpsHist." + (fps < 15 ? "b0" : fps < 20 ? "b15" : fps < 25 ? "b20" : fps < 30 ? "b25"
                : fps < 40 ? "b30" : fps < 50 ? "b40" : fps < 60 ? "b50" : "b60"), 1);
        add("inc", "ramHist." + (pct < 10 ? "p0" : pct < 20 ? "p10" : pct < 30 ? "p20" : pct < 40 ? "p30"
                : pct < 50 ? "p40" : "p50"), 1);
        noteDay("d" + utc("yyyyMMdd"));
        save();
    }

    private void noteDay(String day) {
        synchronized (lock) {
            String all = prefs.getString("days", "");
            if (("," + all + ",").contains("," + day + ",")) return;
            List<String> days = new ArrayList<>();
            for (String d : all.split(",")) if (!d.isEmpty()) days.add(d);
            days.add(day);
            try {
                while (days.size() > MAX_DAYS) {
                    JSONArray del = pending.optJSONArray("del");
                    if (del == null) {
                        del = new JSONArray();
                        pending.put("del", del);
                    }
                    del.put("perfDays." + days.remove(0));
                }
            } catch (Exception ignored) {
            }
            prefs.edit().putString("days", String.join(",", days)).apply();
        }
    }

    int appMb() {
        int own = 0;
        try {
            Debug.MemoryInfo mi = new Debug.MemoryInfo();
            Debug.getMemoryInfo(mi);
            own = mi.getTotalPss() / 1024;
        } catch (Throwable ignored) {
        }
        lastAppMb = own + lastPageMb;
        return lastAppMb;
    }

    int lastAppMb() {
        return lastAppMb > 0 ? lastAppMb : appMb();
    }

    int pageMb() {
        return lastPageMb;
    }

    int deviceRamMb() {
        try {
            ActivityManager.MemoryInfo mi = new ActivityManager.MemoryInfo();
            app.getSystemService(ActivityManager.class).getMemoryInfo(mi);
            return (int) (mi.totalMem / (1024 * 1024));
        } catch (Throwable e) {
            return 0;
        }
    }

    int freeRamMb() {
        try {
            ActivityManager.MemoryInfo mi = new ActivityManager.MemoryInfo();
            app.getSystemService(ActivityManager.class).getMemoryInfo(mi);
            return (int) (mi.availMem / (1024 * 1024));
        } catch (Throwable e) {
            return 0;
        }
    }

    double batteryTemp() {
        try {
            Intent battery = app.registerReceiver(null, new IntentFilter(Intent.ACTION_BATTERY_CHANGED));
            return battery == null ? 0 : battery.getIntExtra(BatteryManager.EXTRA_TEMPERATURE, 0) / 10.0;
        } catch (Throwable e) {
            return 0;
        }
    }

    private boolean hot() {
        try {
            PowerManager pm = app.getSystemService(PowerManager.class);
            if (pm == null) return false;
            if (pm.getCurrentThermalStatus() >= PowerManager.THERMAL_STATUS_MODERATE) return true;
            if (Build.VERSION.SDK_INT >= 30) {
                float h = pm.getThermalHeadroom(10);
                return !Float.isNaN(h) && h >= 1.0f;
            }
        } catch (Throwable ignored) {
        }
        return false;
    }

    private String country() {
        String c = "";
        try {
            TelephonyManager tm = app.getSystemService(TelephonyManager.class);
            if (tm != null) {
                c = tm.getNetworkCountryIso();
                if (c == null || c.length() != 2) c = tm.getSimCountryIso();
            }
        } catch (Throwable ignored) {
        }
        if (c == null || c.length() != 2) c = Locale.getDefault().getCountry();
        c = c == null ? "" : c.toUpperCase(Locale.US);
        return c.matches("[A-Z]{2}") ? c : "";
    }

    JSONObject device() {
        JSONObject cached = device;
        if (cached != null) return cached;
        JSONObject d = new JSONObject();
        try {
            d.put("model", trim(Build.MANUFACTURER + " " + Build.MODEL, 60));
            d.put("android", trim(String.valueOf(Build.VERSION.RELEASE), 20));
            d.put("sdk", Build.VERSION.SDK_INT);
            String soc = Build.VERSION.SDK_INT >= 31 ? Build.SOC_MODEL : Build.HARDWARE;
            if (soc == null || soc.isEmpty() || "unknown".equalsIgnoreCase(soc)) soc = Build.HARDWARE;
            d.put("soc", trim(String.valueOf(soc), 40));
            d.put("cores", Runtime.getRuntime().availableProcessors());
            d.put("ramMb", deviceRamMb());
            int hz = 0;
            try {
                Display display = app.getSystemService(DisplayManager.class).getDisplay(Display.DEFAULT_DISPLAY);
                for (Display.Mode mode : display.getSupportedModes()) hz = Math.max(hz, Math.round(mode.getRefreshRate()));
            } catch (Throwable ignored) {
            }
            d.put("refreshHz", hz);
            String webview = "";
            try {
                PackageInfo p = WebView.getCurrentWebViewPackage();
                if (p != null && p.versionName != null) webview = p.versionName;
            } catch (Throwable ignored) {
            }
            d.put("webview", trim(webview, 40));
            d.put("country", country());
            d.put("app", appVersion());
        } catch (Exception ignored) {
        }
        device = d;
        return d;
    }

    void crash() {
        logLine("engine fault");
    }

    void usage(String moment) {
        this.moment = moment;
    }

    void flush() {
        if (!enabled || !configured()) return;
        final String why = moment;
        moment = "tick";
        io.execute(() -> flushNow(why));
    }

    private boolean due(String why) {
        long now = System.currentTimeMillis();
        if (now < prefs.getLong("backoffUntil", 0)) return false;
        long since = now - prefs.getLong("lastUpload", 0);
        switch (why) {
            case "start":
                if (startDone) return false;
                startDone = true;
                return carried;
            case "stop":
                return since >= 5 * 60 * 1000L;
            default:
                return since >= (long) (remote.minMinutes * 60 * 1000L * (1 + jitter));
        }
    }

    private void flushNow(String why) {
        if (!enabled || !configured() || !remote.usage || !sampled()) return;
        JSONObject p;
        boolean dev;
        synchronized (lock) {

            if (!hasCounts(pending) || !due(why)) return;
            dev = deviceDue;
            p = pending;
            pending = new JSONObject();
        }
        int code = 0;
        try {
            code = commit(p, dev);
        } catch (Exception e) {
            Log.i(TAG, "[Usage] counts not sent: " + e.getClass().getSimpleName());
        }
        boolean ok = code >= 200 && code < 300;
        synchronized (lock) {
            SharedPreferences.Editor e = prefs.edit();
            if (ok) {
                if (dev) deviceDue = false;
                e.putBoolean("created", true).putLong("lastUpload", System.currentTimeMillis())
                        .remove("backoffStep").remove("backoffUntil");
                jitter = Math.random() * 0.2;
            } else {
                if (enabled) merge(p);
                if (busy(code)) backOff(e);
            }
            e.putString("pending", pending.toString()).apply();
        }
    }

    private static boolean busy(int code) {
        return code == 429 || code >= 500;
    }

    private void backOff(SharedPreferences.Editor e) {
        int step = prefs.getInt("backoffStep", 0);
        long now = System.currentTimeMillis();
        long until;
        if (step == 0) until = now + 3600 * 1000L;
        else if (step == 1) until = now + 3 * 3600 * 1000L;
        else until = (now / 86400000L + 1) * 86400000L;
        e.putInt("backoffStep", Math.min(step + 1, 2)).putLong("backoffUntil", until);
        logLine("[Usage] database busy, next try in " + ((until - now) / 60000) + " min");
    }

    private void merge(JSONObject old) {
        JSONObject now = pending;
        pending = old;
        try {
            for (String kind : new String[]{"inc", "min", "max"}) {
                JSONObject m = now.optJSONObject(kind);
                if (m == null) continue;
                for (Iterator<String> it = m.keys(); it.hasNext(); ) {
                    String k = it.next();
                    add(kind, k, m.getDouble(k));
                }
            }
            JSONArray del = now.optJSONArray("del");
            if (del != null) {
                JSONArray mine = pending.optJSONArray("del");
                if (mine == null) {
                    mine = new JSONArray();
                    pending.put("del", mine);
                }
                for (int i = 0; i < del.length(); i++) mine.put(del.getString(i));
            }
        } catch (Exception ignored) {
        }
    }

    private static boolean isDouble(String path) {
        return path.endsWith("fpsSum") || path.endsWith("ramPctSum") || path.endsWith("tempSum") || path.endsWith("tempPeak");
    }

    private static JSONObject number(String path, double v) throws Exception {
        return isDouble(path) ? new JSONObject().put("doubleValue", Math.round(v * 10) / 10.0)
                : new JSONObject().put("integerValue", String.valueOf(Math.round(v)));
    }

    private int commit(JSONObject p, boolean dev) throws Exception {
        List<JSONObject> transforms = new ArrayList<>();
        for (String[] kind : new String[][]{{"inc", "increment"}, {"min", "minimum"}, {"max", "maximum"}}) {
            JSONObject m = p.optJSONObject(kind[0]);
            if (m == null) continue;
            for (Iterator<String> it = m.keys(); it.hasNext(); ) {
                String path = it.next();
                transforms.add(new JSONObject().put("fieldPath", path).put(kind[1], number(path, m.getDouble(path))));
            }
        }
        if (!prefs.getBoolean("created", false))
            transforms.add(new JSONObject().put("fieldPath", "firstSeen").put("setToServerValue", "REQUEST_TIME"));
        String name = "projects/" + BuildConfig.TELEMETRY_PROJECT + "/databases/(default)/documents/mva_installs/" + install;
        JSONArray del = p.optJSONArray("del");
        int at = 0;
        do {
            JSONObject fields = new JSONObject();
            fields.put("install", str(install));
            fields.put("schema", integer(SCHEMA));
            fields.put("ver", str(version));
            JSONArray mask = new JSONArray().put("install").put("schema").put("ver");
            if (at == 0) {
                if (dev) {
                    fields.put("device", value(device()));
                    mask.put("device");
                }

                if (del != null) for (int i = 0; i < del.length(); i++) mask.put(del.getString(i));
            }
            JSONArray part = new JSONArray();
            for (int end = Math.min(transforms.size(), at + MAX_TRANSFORMS); at < end; at++) part.put(transforms.get(at));

            part.put(new JSONObject().put("fieldPath", "lastSeen").put("setToServerValue", "REQUEST_TIME"));
            JSONObject write = new JSONObject();
            write.put("update", new JSONObject().put("name", name).put("fields", fields));
            write.put("updateMask", new JSONObject().put("fieldPaths", mask));
            write.put("updateTransforms", part);
            String body = new JSONObject().put("writes", new JSONArray().put(write)).toString();
            int code = post(":commit", body, "mva_installs");
            if (code < 200 || code >= 300) return code;
        } while (at < transforms.size());
        return 200;
    }

    void sendReport(JSONObject report) {
        if (!configured()) return;
        io.execute(() -> {

            if (System.currentTimeMillis() < prefs.getLong("backoffUntil", 0)) return;
            try {
                JSONObject fields = value(report).getJSONObject("mapValue").getJSONObject("fields");
                fields.put("ts", new JSONObject().put("timestampValue", stamp(new Date(report.optLong("ts", System.currentTimeMillis())))));
                int code = post("/mva_reports", "{\"fields\":" + fields + "}", "mva_reports");
                if (busy(code)) {
                    SharedPreferences.Editor e = prefs.edit();
                    backOff(e);
                    e.apply();
                }
            } catch (Exception e) {
                Log.i(TAG, "[Report] not sent: " + e.getClass().getSimpleName());
            }
        });
    }

    private int post(String path, String body, String what) {
        HttpURLConnection c = null;
        try {
            URL url = new URL("https://firestore.googleapis.com/v1/projects/" + BuildConfig.TELEMETRY_PROJECT
                    + "/databases/(default)/documents" + path + "?key=" + BuildConfig.TELEMETRY_KEY);
            c = (HttpURLConnection) url.openConnection();
            c.setConnectTimeout(TIMEOUT_MS);
            c.setReadTimeout(TIMEOUT_MS);
            c.setRequestMethod("POST");
            c.setDoOutput(true);
            c.setRequestProperty("Content-Type", "application/json; charset=utf-8");
            try (OutputStream out = c.getOutputStream()) {
                out.write(body.getBytes(StandardCharsets.UTF_8));
            }
            int code = c.getResponseCode();

            if (code >= 400 && code != 429) {
                try (InputStream err = c.getErrorStream()) {
                    if (err != null) {
                        byte[] buf = new byte[2048];
                        int n = err.read(buf);
                        if (n > 0 && new String(buf, 0, n, StandardCharsets.UTF_8).contains("RESOURCE_EXHAUSTED")) code = 429;
                    }
                } catch (Exception ignored) {
                }
            }
            Log.i(TAG, "[Usage] " + what + " -> " + code);
            logLine("[Usage] " + what + " -> " + code);
            return code;
        } catch (Exception e) {
            Log.i(TAG, "[Usage] " + what + " not sent: " + e.getClass().getSimpleName());
            logLine("[Usage] " + what + " not sent: " + e.getClass().getSimpleName());
            return 0;
        } finally {
            if (c != null) c.disconnect();
        }
    }

    static JSONObject value(Object v) throws Exception {
        if (v instanceof JSONObject) {
            JSONObject in = (JSONObject) v, fields = new JSONObject();
            for (Iterator<String> it = in.keys(); it.hasNext(); ) {
                String k = it.next();
                Object child = in.get(k);
                if (child == JSONObject.NULL || child instanceof JSONArray) continue;
                fields.put(k, value(child));
            }
            return new JSONObject().put("mapValue", new JSONObject().put("fields", fields));
        }
        if (v instanceof Boolean) return new JSONObject().put("booleanValue", v);
        if (v instanceof Integer || v instanceof Long) return new JSONObject().put("integerValue", String.valueOf(v));
        if (v instanceof Number) {
            double d = ((Number) v).doubleValue();
            if (Double.isNaN(d) || Double.isInfinite(d)) d = 0;
            return new JSONObject().put("doubleValue", d);
        }
        return str(String.valueOf(v));
    }

    static String trim(String s, int max) {
        if (s == null) return "";
        return s.length() > max ? s.substring(0, max) : s;
    }

    private static JSONObject str(String s) throws Exception {
        return new JSONObject().put("stringValue", s);
    }

    private static JSONObject integer(int v) throws Exception {
        return new JSONObject().put("integerValue", String.valueOf(v));
    }

    private static String utc(String pattern) {
        SimpleDateFormat f = new SimpleDateFormat(pattern, Locale.US);
        f.setTimeZone(TimeZone.getTimeZone("UTC"));
        return f.format(new Date());
    }

    private static String stamp(Date d) {
        SimpleDateFormat f = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'", Locale.US);
        f.setTimeZone(TimeZone.getTimeZone("UTC"));
        return f.format(d);
    }
}
