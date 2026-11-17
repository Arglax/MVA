package com.arglax.mva;

import android.view.ViewGroup;

import android.view.Gravity;

import android.widget.TextView;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.ActivityNotFoundException;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.res.Configuration;
import android.net.Uri;
import android.os.BatteryManager;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.os.PowerManager;
import android.os.StatFs;
import android.os.SystemClock;
import android.util.Log;
import android.view.View;
import android.view.WindowInsets;
import android.view.WindowInsetsController;
import android.view.WindowManager;
import android.view.inputmethod.InputMethodManager;
import android.webkit.ConsoleMessage;
import android.webkit.JavascriptInterface;
import android.webkit.RenderProcessGoneDetail;
import android.webkit.WebChromeClient;
import android.webkit.WebResourceRequest;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.FrameLayout;
import android.window.OnBackInvokedDispatcher;

import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;

public class MainActivity extends Activity {
    private static final String TAG = "MVA";
    private static final long THERMAL_MS = 10000;
    private static final long USAGE_MS = 10 * 60 * 1000;

    private FrameLayout root;
    private WebView webView;
    private LocalServer server;
    private final Handler main = new Handler(Looper.getMainLooper());
    private boolean visible;
    private Telemetry telemetry;
    private Reports reports;
    private boolean started;
    private long shownAt;
    private long gone1, gone2;

    private final Runnable usageTick = new Runnable() {
        @Override
        public void run() {
            telemetry.usage("tick");
            telemetry.flush();
            if (visible) main.postDelayed(this, USAGE_MS);
        }
    };

    private final Runnable thermalTick = new Runnable() {
        @Override
        public void run() {
            sendThermal();
            if (visible) main.postDelayed(this, THERMAL_MS);
        }
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        WebView.setWebContentsDebuggingEnabled(BuildConfig.DEBUG);
        telemetry = new Telemetry(this);
        reports = new Reports(this, telemetry);
        reports.watchCrashes();
        reports.checkLastRun();
        if (getSharedPreferences("mva.app", MODE_PRIVATE).getBoolean("keepOn", true))
            getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        root = new FrameLayout(this);
        root.setBackgroundColor(0xFF0E0905);
        setContentView(root);
        hideSystemBars();
        Configuration c = getResources().getConfiguration();
        server = new LocalServer(this, c.smallestScreenWidthDp < 600);
        try {
            server.start();
        } catch (IOException e) {
            Log.e(TAG, "server: " + e.getMessage());

            reports.saveForNextStart(reports.capture("problem", "The local game server could not start: " + e, "", null));
            finish();
            return;
        }
        createWebView();
        if (Build.VERSION.SDK_INT >= 33) {
            getOnBackInvokedDispatcher().registerOnBackInvokedCallback(OnBackInvokedDispatcher.PRIORITY_DEFAULT, this::handleBack);
        }
        webView.loadUrl(server.pageUrl());
    }

    @SuppressLint("SetJavaScriptEnabled")
    private void createWebView() {
        webView = new WebView(this);
        webView.setBackgroundColor(0xFF0E0905);
        webView.setRendererPriorityPolicy(WebView.RENDERER_PRIORITY_IMPORTANT, false);
        root.addView(webView, 0, new FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT));
        WebSettings s = webView.getSettings();
        s.setJavaScriptEnabled(true);
        s.setDomStorageEnabled(true);
        s.setMediaPlaybackRequiresUserGesture(false);
        s.setAllowFileAccess(false);
        s.setAllowContentAccess(false);
        s.setSupportZoom(false);
        s.setSupportMultipleWindows(false);
        s.setJavaScriptCanOpenWindowsAutomatically(false);
        s.setSafeBrowsingEnabled(true);
        webView.addJavascriptInterface(new Bridge(), "MvaAndroid");
        webView.setWebViewClient(new Client());

        webView.setWebChromeClient(new WebChromeClient() {
            @Override
            public boolean onConsoleMessage(ConsoleMessage message) {
                return !BuildConfig.DEBUG;
            }
        });
    }

    private void toPage(String json) {
        if (webView != null) webView.evaluateJavascript("window.MvaBridge&&MvaBridge.handle(" + json + ")", null);
    }

    @Override
    protected void onStart() {
        super.onStart();
        visible = true;
        toPage("{\"t\":\"background\",\"v\":false}");
        main.removeCallbacks(thermalTick);
        main.post(thermalTick);
        shownAt = System.currentTimeMillis();
        if (!started) {
            started = true;
            telemetry.usage("start");
            telemetry.health("sessions", 1);
            telemetry.flush();
        }
        reports.onVisible(true);
        main.removeCallbacks(usageTick);
        main.postDelayed(usageTick, USAGE_MS);
    }

    @Override
    protected void onStop() {
        visible = false;
        main.removeCallbacks(thermalTick);
        main.removeCallbacks(usageTick);
        telemetry.usage("stop");
        if (shownAt > 0) telemetry.health("sessionMs", System.currentTimeMillis() - shownAt);
        shownAt = 0;
        telemetry.flush();
        reports.onVisible(false);
        toPage("{\"t\":\"background\",\"v\":true}");
        super.onStop();
    }

    @Override
    public void onWindowFocusChanged(boolean hasFocus) {
        super.onWindowFocusChanged(hasFocus);
        if (hasFocus) hideSystemBars();
    }

    @Override
    public void onTrimMemory(int level) {
        super.onTrimMemory(level);
        if (level == TRIM_MEMORY_RUNNING_CRITICAL || level == TRIM_MEMORY_COMPLETE) telemetry.health("lowMemory", 1);
    }

    @Override
    protected void onDestroy() {
        main.removeCallbacksAndMessages(null);
        GameService.stop(this);
        if (webView != null) webView.destroy();
        if (server != null) server.stop();
        super.onDestroy();
    }

    private FrameLayout sheet;

    private static boolean isCharPage(Uri uri) {
        return uri != null && "https".equals(uri.getScheme()) && "account.aq.com".equalsIgnoreCase(uri.getHost())
                && uri.getPath() != null && uri.getPath().toLowerCase(java.util.Locale.ROOT).startsWith("/charpage");
    }

    @SuppressLint("SetJavaScriptEnabled")
    private void showWebSheet(String url) {
        if (sheet != null) {
            ((WebView) sheet.getChildAt(0)).loadUrl(url);
            return;
        }
        FrameLayout root = new FrameLayout(this);
        root.setBackgroundColor(0xFF120C08);
        root.setClickable(true);
        WebView page = new WebView(this);
        WebSettings ws = page.getSettings();
        ws.setJavaScriptEnabled(true);
        ws.setDomStorageEnabled(true);
        ws.setMediaPlaybackRequiresUserGesture(false);
        ws.setLoadWithOverviewMode(true);
        ws.setUseWideViewPort(true);
        ws.setAllowFileAccess(false);
        ws.setAllowContentAccess(false);
        page.setWebViewClient(new WebViewClient() {
            @Override
            public void onPageFinished(WebView view, String url) {

                view.evaluateJavascript("(function(){var n=0;var t=setInterval(function(){var p=document.querySelector('ruffle-embed,ruffle-object,ruffle-player');if(p){if(n===0)p.scrollIntoView({block:'center'});try{p.play&&p.play()}catch(e){}}if(++n>16)clearInterval(t)},400)})()", null);
            }

            @Override
            public boolean shouldOverrideUrlLoading(WebView view, WebResourceRequest request) {
                if ("account.aq.com".equalsIgnoreCase(request.getUrl().getHost())) return false;

                if (!"https".equals(request.getUrl().getScheme())) return true;
                try {
                    startActivity(new Intent(Intent.ACTION_VIEW, request.getUrl()));
                } catch (ActivityNotFoundException ignored) {
                }
                return true;
            }
        });
        root.addView(page, new FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT));
        TextView close = new TextView(this);
        close.setText("✕");
        close.setTextSize(22);
        close.setTextColor(0xFFE8C15A);
        close.setGravity(Gravity.CENTER);
        close.setBackgroundColor(0xCC1A1206);
        close.setOnClickListener(v -> closeWebSheet());
        int size = (int) (52 * getResources().getDisplayMetrics().density);
        FrameLayout.LayoutParams lp = new FrameLayout.LayoutParams(size, size, Gravity.TOP | Gravity.END);
        root.addView(close, lp);
        addContentView(root, new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        sheet = root;
        page.loadUrl(url);
    }

    private void closeWebSheet() {
        if (sheet == null) return;
        WebView page = (WebView) sheet.getChildAt(0);
        ((ViewGroup) sheet.getParent()).removeView(sheet);
        page.destroy();
        sheet = null;
    }

    @SuppressWarnings("deprecation")
    @Override
    public void onBackPressed() {
        handleBack();
    }

    private void handleBack() {
        if (sheet != null) {
            closeWebSheet();
            return;
        }
        if (webView == null) {
            finish();
            return;
        }
        webView.evaluateJavascript("window.MvaBridge?MvaBridge.handle({t:'back'}):false", result -> {
            if (!"true".equals(result)) moveTaskToBack(true);
        });
    }

    private void askNotificationsOnce() {
        if (Build.VERSION.SDK_INT < 33) return;
        if (checkSelfPermission("android.permission.POST_NOTIFICATIONS") == android.content.pm.PackageManager.PERMISSION_GRANTED) return;
        android.content.SharedPreferences prefs = getSharedPreferences("mva", MODE_PRIVATE);
        if (prefs.getBoolean("askedNotifications", false)) return;
        prefs.edit().putBoolean("askedNotifications", true).apply();
        requestPermissions(new String[]{"android.permission.POST_NOTIFICATIONS"}, 7);
    }

    private void sendThermal() {
        try {
            JSONObject m = new JSONObject();
            m.put("t", "thermal");
            PowerManager pm = getSystemService(PowerManager.class);
            m.put("status", pm == null ? 0 : pm.getCurrentThermalStatus());
            float headroom = -1f;
            if (pm != null && Build.VERSION.SDK_INT >= 30) {
                float h = pm.getThermalHeadroom(10);
                if (!Float.isNaN(h)) headroom = h;
            }
            m.put("headroom", headroom);
            Intent battery = registerReceiver(null, new IntentFilter(Intent.ACTION_BATTERY_CHANGED));
            int tenths = battery == null ? 0 : battery.getIntExtra(BatteryManager.EXTRA_TEMPERATURE, 0);
            m.put("battery", tenths / 10.0);
            toPage(m.toString());
        } catch (Exception ignored) {
        }
    }

    @SuppressWarnings("deprecation")
    private void hideSystemBars() {
        if (Build.VERSION.SDK_INT >= 30) {
            getWindow().setDecorFitsSystemWindows(false);
            WindowInsetsController c = getWindow().getInsetsController();
            if (c != null) {
                c.hide(WindowInsets.Type.systemBars());
                c.setSystemBarsBehavior(WindowInsetsController.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE);
            }
        } else {
            getWindow().getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
                    | View.SYSTEM_UI_FLAG_FULLSCREEN | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                    | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                    | View.SYSTEM_UI_FLAG_LAYOUT_STABLE);
        }
    }

    private final class Bridge {
        @JavascriptInterface
        public void log(String text) {
            Log.i(TAG, text == null ? "" : text.length() > 2000 ? text.substring(0, 2000) : text);
            telemetry.logLine(text);
        }

        @JavascriptInterface
        public void keyboard() {
            runOnUiThread(() -> {
                InputMethodManager imm = getSystemService(InputMethodManager.class);
                if (imm != null && webView != null) {
                    webView.requestFocus();
                    imm.showSoftInput(webView, InputMethodManager.SHOW_IMPLICIT);
                }
            });
        }

        @JavascriptInterface
        public void playing(boolean on) {
            runOnUiThread(() -> {
                if (on) {
                    askNotificationsOnce();
                    GameService.start(MainActivity.this);
                } else GameService.stop(MainActivity.this);
            });
        }

        @JavascriptInterface
        public void stats(String json) {
            if (json != null && json.length() < 8000) telemetry.stats(json);
        }

        @JavascriptInterface
        public void count(String id) {
            telemetry.count(id);
        }

        @JavascriptInterface
        public void health(String key, double n) {
            if ("gameLoads".equals(key) || "gameLoadMsSum".equals(key) || "mapLoads".equals(key) || "engineReloads".equals(key))
                telemetry.health(key, Math.round(Math.min(n, 3600000)));
        }

        @JavascriptInterface
        public void problem(String json) {
            if (json == null || json.length() > 60000) return;
            try {
                JSONObject j = new JSONObject(json);
                telemetry.remember(j);
                boolean engine = "engine".equals(j.optString("kind"));
                if (engine) telemetry.crash();
                reports.fault(engine ? "engine" : "problem", j.optString("error"), j.optString("stack"), j.optJSONObject("context"));
            } catch (Exception ignored) {
            }
        }

        @JavascriptInterface
        public String appSettings() {
            try {
                return new JSONObject().put("keepOn", getSharedPreferences("mva.app", MODE_PRIVATE).getBoolean("keepOn", true))
                        .put("stats", telemetry.enabled()).toString();
            } catch (Exception e) {
                return "{}";
            }
        }

        @JavascriptInterface
        public void settings(String json) {
            try {
                JSONObject j = new JSONObject(json);
                if (j.has("stats")) telemetry.setEnabled(j.getBoolean("stats"));
                if (!j.has("keepOn")) return;
                boolean keepOn = j.getBoolean("keepOn");
                getSharedPreferences("mva.app", MODE_PRIVATE).edit().putBoolean("keepOn", keepOn).apply();
                runOnUiThread(() -> {
                    if (keepOn) getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
                    else getWindow().clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
                });
            } catch (Exception ignored) {
            }
        }

        @JavascriptInterface
        public String deviceFacts() {
            JSONObject f = new JSONObject();
            try {
                JSONObject d = telemetry.device();
                for (String key : new String[]{"model", "android", "sdk", "soc", "cores", "ramMb", "webview"})
                    if (d.has(key)) f.put(key, d.get(key));
                f.put("is64", Build.SUPPORTED_64_BIT_ABIS.length > 0);
                long top = 0;
                int cores = Runtime.getRuntime().availableProcessors();
                for (int i = 0; i < cores; i++) {
                    try (BufferedReader r = new BufferedReader(new FileReader("/sys/devices/system/cpu/cpu" + i + "/cpufreq/cpuinfo_max_freq"))) {
                        String line = r.readLine();
                        if (line != null) top = Math.max(top, Long.parseLong(line.trim()));
                    } catch (Throwable ignored) {
                    }
                }
                f.put("maxKhz", top);
                try {
                    f.put("freeMb", new StatFs(getFilesDir().getPath()).getAvailableBytes() / (1024 * 1024));
                } catch (Throwable ignored) {
                }
            } catch (Throwable ignored) {
            }
            return f.toString();
        }

        @JavascriptInterface
        public void openLink(String url) {
            Uri uri = Uri.parse(url);
            if (!"https".equals(uri.getScheme())) return;
            if (isCharPage(uri)) {
                runOnUiThread(() -> showWebSheet(url));
                return;
            }
            runOnUiThread(() -> {
                try {
                    startActivity(new Intent(Intent.ACTION_VIEW, uri));
                } catch (ActivityNotFoundException ignored) {
                }
            });
        }
    }

    private final class Client extends WebViewClient {
        @Override
        public boolean shouldOverrideUrlLoading(WebView view, WebResourceRequest request) {
            String url = request.getUrl().toString();
            if (server.isOurs(url)) return false;
            if (isCharPage(request.getUrl())) {
                showWebSheet(url);
                return true;
            }
            if ("https".equals(request.getUrl().getScheme())) {
                try {
                    startActivity(new Intent(Intent.ACTION_VIEW, request.getUrl()));
                } catch (ActivityNotFoundException ignored) {
                }
            }
            return true;
        }

        @Override
        public boolean onRenderProcessGone(WebView view, RenderProcessGoneDetail detail) {
            if (view != webView) return true;
            Log.w(TAG, detail.didCrash() ? "page renderer crashed" : "Android closed the page renderer");
            telemetry.logLine(detail.didCrash() ? "page renderer crashed" : "Android closed the page renderer");
            telemetry.crash();
            telemetry.health("engineReloads", 1);

            if (detail.didCrash()) reports.fault("engine", "The page's process crashed", "", null);
            else if (visible) reports.fault("problem", "Android closed the page's process (out of memory)", "", null);
            GameService.stop(MainActivity.this);
            root.removeView(webView);
            webView.destroy();

            long now = SystemClock.elapsedRealtime();
            boolean loop = gone1 > 0 && now - gone1 <= 60000;
            gone1 = gone2;
            gone2 = now;
            if (loop) {
                webView = null;
                reports.saveForNextStart(reports.capture("engine", "The page's process stopped 3 times within a minute", "", null));
                finish();
                return true;
            }
            createWebView();
            webView.loadUrl(server.pageUrl());
            return true;
        }
    }
}
