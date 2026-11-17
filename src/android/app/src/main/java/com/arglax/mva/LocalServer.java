package com.arglax.mva;

import android.content.Context;
import android.content.res.AssetManager;
import android.util.Log;

import org.json.JSONArray;
import org.json.JSONObject;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.InetAddress;
import java.net.InetSocketAddress;
import java.net.ServerSocket;
import java.net.Socket;
import java.net.URL;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Base64;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.RejectedExecutionException;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;

final class LocalServer {
    static final int PORT = 47921;
    private static final String TAG = "MVA";
    private static final String UA = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0 Safari/537.36";
    private static final String SERVERS = "https://game.aq.com/game/api/data/servers";
    private static final String WS_GUID = "258EAFA5-E914-47DA-95CA-C5AB0DC85B11";
    private static final String[] REQUEST_HEADERS = {"Accept", "Accept-Language", "Content-Type", "If-None-Match", "If-Modified-Since", "Range", "ccid", "token"};
    private static final String[] RESPONSE_HEADERS = {"Cache-Control", "ETag", "Last-Modified", "Expires", "Content-Range", "Accept-Ranges"};
    private static final Set<String> CACHED = new HashSet<>(Arrays.asList("swf", "png", "jpg", "jpeg", "gif", "mp3"));
    private static final long FRESH_MS = 6 * 3600 * 1000L;
    private static final long CACHE_MAX = 400L * 1024 * 1024;
    private static final int MAX_HEAD = 32 * 1024;
    private static final long MAX_BODY = 8L * 1024 * 1024;

    private static final int MAX_THREADS = 64;
    private static final int MAX_WAITING = 128;
    private static final Map<String, String> MIME = new HashMap<>();

    static {
        MIME.put("html", "text/html; charset=utf-8");
        MIME.put("js", "text/javascript; charset=utf-8");
        MIME.put("css", "text/css; charset=utf-8");
        MIME.put("json", "application/json; charset=utf-8");
        MIME.put("wasm", "application/wasm");
        MIME.put("swf", "application/x-shockwave-flash");
        MIME.put("woff2", "font/woff2");
        MIME.put("png", "image/png");
        MIME.put("jpg", "image/jpeg");
        MIME.put("jpeg", "image/jpeg");
        MIME.put("gif", "image/gif");
        MIME.put("mp3", "audio/mpeg");
        MIME.put("svg", "image/svg+xml");
        MIME.put("xml", "text/xml");
    }

    private final Context context;
    private final AssetManager assets;
    private final File cacheDir;
    private final boolean phone;
    private final String token;
    private final ExecutorService pool;
    private ServerSocket server;
    private volatile List<String[]> serverList;

    LocalServer(Context context, boolean phone) {
        this.context = context.getApplicationContext();
        this.assets = this.context.getAssets();
        this.cacheDir = new File(this.context.getCacheDir(), "game");
        this.phone = phone;
        byte[] raw = new byte[16];
        new SecureRandom().nextBytes(raw);
        StringBuilder sb = new StringBuilder();
        for (byte b : raw) sb.append(String.format(Locale.ROOT, "%02x", b));
        this.token = sb.toString();
        ThreadPoolExecutor p = new ThreadPoolExecutor(MAX_THREADS, MAX_THREADS, 60, TimeUnit.SECONDS, new LinkedBlockingQueue<>(MAX_WAITING));
        p.allowCoreThreadTimeOut(true);
        this.pool = p;
    }

    String pageUrl() {
        return "http://127.0.0.1:" + server.getLocalPort() + "/" + token + "/";
    }

    boolean isOurs(String url) {
        return url != null && url.startsWith("http://127.0.0.1:" + server.getLocalPort() + "/" + token + "/");
    }

    void start() throws IOException {
        InetAddress loopback = InetAddress.getByName("127.0.0.1");
        try {
            server = new ServerSocket();
            server.setReuseAddress(true);
            server.bind(new InetSocketAddress(loopback, PORT), 64);
        } catch (IOException taken) {
            server = new ServerSocket(0, 64, loopback);
        }
        Thread accept = new Thread(() -> {
            while (!server.isClosed()) {
                try {
                    Socket s = server.accept();
                    try {
                        pool.execute(() -> serve(s));
                    } catch (RejectedExecutionException full) {
                        closeQuietly(s);
                    }
                } catch (IOException e) {
                    if (!server.isClosed()) Log.w(TAG, "accept: " + e.getMessage());
                }
            }
        }, "mva-server");
        accept.setDaemon(true);
        accept.start();
        pool.execute(this::loadServerList);
    }

    void stop() {
        try {
            if (server != null) server.close();
        } catch (IOException ignored) {
        }
        pool.shutdownNow();
    }

    private static final class Request {
        String method;
        String path;
        String query = "";
        final Map<String, String> headers = new HashMap<>();
        byte[] body = new byte[0];
        int bad;

        String header(String name) {
            return headers.get(name.toLowerCase(Locale.ROOT));
        }
    }

    private void serve(Socket socket) {
        try {
            socket.setSoTimeout(120000);
            socket.setTcpNoDelay(true);
            InputStream in = socket.getInputStream();
            OutputStream out = socket.getOutputStream();
            Request req = readRequest(in);
            if (req == null) {
                socket.close();
                return;
            }
            if (req.bad != 0) {
                text(out, req.bad, req.bad == 413 ? "Payload Too Large" : "Bad Request", "bad request");
                socket.close();
                return;
            }
            String prefix = "/" + token + "/";
            if (!req.path.startsWith(prefix)) {
                text(out, 404, "Not Found", "not found");
                socket.close();
                return;
            }
            String path = req.path.substring(prefix.length());
            if (path.equals("ws/sock")) {
                webSocket(socket, req, in, out);
                return;
            }
            if (path.startsWith("p/")) proxy(out, req, path.substring(2));
            else if (path.equals("config.json")) send(out, 200, "OK", MIME.get("json"), config().getBytes(StandardCharsets.UTF_8), null);
            else asset(out, path.isEmpty() ? "index.html" : path);
            out.flush();
            socket.close();
        } catch (IOException | RuntimeException e) {

            closeQuietly(socket);
        }
    }

    private static Request readRequest(InputStream in) throws IOException {
        ByteArrayOutputStream head = new ByteArrayOutputStream();
        int state = 0;
        while (state < 4) {
            int b = in.read();
            if (b < 0) return null;
            head.write(b);
            if (head.size() > MAX_HEAD) return null;
            state = (b == '\r' && (state == 0 || state == 2)) ? state + 1 : (b == '\n' && (state == 1 || state == 3)) ? state + 1 : (b == '\r' ? 1 : 0);
        }
        String[] lines = head.toString("ISO-8859-1").split("\r\n");
        if (lines.length == 0) return null;
        String[] first = lines[0].split(" ");
        if (first.length < 2) return null;
        Request r = new Request();
        r.method = first[0];
        String target = first[1];
        int q = target.indexOf('?');
        r.path = q < 0 ? target : target.substring(0, q);
        r.query = q < 0 ? "" : target.substring(q + 1);
        for (int i = 1; i < lines.length; i++) {
            int c = lines[i].indexOf(':');
            if (c > 0) r.headers.put(lines[i].substring(0, c).trim().toLowerCase(Locale.ROOT), lines[i].substring(c + 1).trim());
        }
        String len = r.header("Content-Length");
        if (len != null) {
            long n;
            try {
                n = Long.parseLong(len.trim());
            } catch (NumberFormatException e) {
                n = -1;
            }
            if (n < 0 || n > MAX_BODY) {
                r.bad = n < 0 ? 400 : 413;
                return r;
            }
            byte[] body = new byte[(int) n];
            int got = 0;
            while (got < n) {
                int k = in.read(body, got, (int) n - got);
                if (k < 0) return null;
                got += k;
            }
            r.body = body;
        }
        return r;
    }

    private static void send(OutputStream out, int code, String reason, String type, byte[] body, Map<String, String> extra) throws IOException {
        StringBuilder h = new StringBuilder();
        h.append("HTTP/1.1 ").append(code).append(' ').append(reason).append("\r\n");
        if (type != null) h.append("Content-Type: ").append(type).append("\r\n");
        h.append("Content-Length: ").append(body.length).append("\r\n");
        h.append("X-Content-Type-Options: nosniff\r\n");
        if (extra != null) for (Map.Entry<String, String> e : extra.entrySet()) h.append(e.getKey()).append(": ").append(e.getValue()).append("\r\n");
        h.append("Connection: close\r\n\r\n");
        out.write(h.toString().getBytes(StandardCharsets.ISO_8859_1));
        out.write(body);
    }

    private static void text(OutputStream out, int code, String reason, String msg) throws IOException {
        send(out, code, reason, "text/plain; charset=utf-8", msg.getBytes(StandardCharsets.UTF_8), null);
    }

    private static String ext(String path) {
        int slash = path.lastIndexOf('/');
        int dot = path.lastIndexOf('.');
        return dot > slash ? path.substring(dot + 1).toLowerCase(Locale.ROOT) : "";
    }

    private void asset(OutputStream out, String path) throws IOException {
        if (path.contains("..") || path.startsWith("/")) {
            text(out, 404, "Not Found", "not found");
            return;
        }
        try (InputStream in = assets.open(path)) {
            String type = MIME.get(ext(path));
            send(out, 200, "OK", type == null ? "application/octet-stream" : type, readAll(in), null);
        } catch (IOException e) {
            text(out, 404, "Not Found", "not found");
        }
    }

    private static byte[] readAll(InputStream in) throws IOException {
        ByteArrayOutputStream buf = new ByteArrayOutputStream();
        byte[] chunk = new byte[64 * 1024];
        int n;
        while ((n = in.read(chunk)) > 0) buf.write(chunk, 0, n);
        return buf.toByteArray();
    }

    static boolean allowedHost(String host) {
        if (host == null) return false;
        String h = host.toLowerCase(Locale.ROOT);
        int colon = h.indexOf(':');
        if (colon >= 0) {
            if (!h.substring(colon + 1).matches("[0-9]{1,5}")) return false;
            h = h.substring(0, colon);
        }
        if (!h.matches("[a-z0-9.-]+")) return false;
        return h.equals("aq.com") || h.endsWith(".aq.com") || h.equals("artix.com") || h.endsWith(".artix.com");
    }

    private void proxy(OutputStream out, Request req, String target) throws IOException {
        int a = target.indexOf('/');
        int b = a < 0 ? -1 : target.indexOf('/', a + 1);
        String scheme = a < 0 ? "" : target.substring(0, a);
        String host = a < 0 ? "" : (b < 0 ? target.substring(a + 1) : target.substring(a + 1, b));
        String rest = b < 0 ? "/" : target.substring(b);
        if (!scheme.equals("https") && !scheme.equals("http") || !allowedHost(host)) {
            text(out, 403, "Forbidden", "host not allowed");
            return;
        }
        String url = "https://" + host + rest + (req.query.isEmpty() ? "" : "?" + req.query);

        if (!allowedHost(new URL(url).getHost())) {
            text(out, 403, "Forbidden", "host not allowed");
            return;
        }
        boolean get = req.method.equals("GET") || req.method.equals("HEAD");
        String kind = ext(rest);
        boolean cacheable = req.method.equals("GET") && CACHED.contains(kind) && !rest.contains("/api/") && req.header("Range") == null;
        File cached = cacheable ? cacheFile(cacheKey(host, rest, req.query)) : null;
        File meta = cached == null ? null : new File(cached.getPath() + ".m");
        if (cached != null && cached.isFile() && System.currentTimeMillis() - cached.lastModified() < FRESH_MS) {
            sendCached(out, cached, kind);
            return;
        }
        int[] waits = {2000, 3000, 5000, 8000};
        for (int attempt = 0; ; attempt++) {
            try {
                HttpURLConnection c = open(url, req, cached != null && cached.isFile() ? readMeta(meta) : null);
                int code = c.getResponseCode();
                if (code == 304 && cached != null && cached.isFile()) {
                    cached.setLastModified(System.currentTimeMillis());
                    c.disconnect();
                    sendCached(out, cached, kind);
                    return;
                }
                InputStream in = code >= 400 ? c.getErrorStream() : c.getInputStream();
                byte[] body = in == null ? new byte[0] : readAll(in);
                Map<String, String> headers = new LinkedHashMap<>();
                for (String name : RESPONSE_HEADERS) {
                    String v = c.getHeaderField(name);
                    if (v != null) headers.put(name, v);
                }
                headers.put("Content-Security-Policy", "sandbox");
                String type = c.getContentType();
                if (type == null) type = MIME.getOrDefault(kind, "application/octet-stream");
                if (code == 200 && cached != null) store(cached, meta, body, c);
                c.disconnect();
                send(out, code, code == 200 ? "OK" : "Status", type, req.method.equals("HEAD") ? new byte[0] : body, headers);
                return;
            } catch (IOException e) {
                if (!get || attempt >= waits.length) {
                    if (cached != null && cached.isFile()) {
                        sendCached(out, cached, kind);
                        return;
                    }
                    text(out, 502, "Bad Gateway", "network error");
                    return;
                }
                try {
                    Thread.sleep(waits[attempt]);
                } catch (InterruptedException ie) {
                    Thread.currentThread().interrupt();
                    text(out, 502, "Bad Gateway", "interrupted");
                    return;
                }
            }
        }
    }

    private HttpURLConnection open(String url, Request req, String[] validators) throws IOException {
        URL u = new URL(url);
        for (int hops = 0; hops < 5; hops++) {
            HttpURLConnection c = (HttpURLConnection) u.openConnection();
            c.setInstanceFollowRedirects(false);
            c.setConnectTimeout(20000);
            c.setReadTimeout(120000);
            c.setRequestMethod(req.method.equals("HEAD") ? "HEAD" : req.method);
            for (String name : REQUEST_HEADERS) {
                String v = req.header(name);
                if (v != null) c.setRequestProperty(name, v);
            }
            if (validators != null) {
                if (validators[0] != null) c.setRequestProperty("If-None-Match", validators[0]);
                if (validators[1] != null) c.setRequestProperty("If-Modified-Since", validators[1]);
            }
            c.setRequestProperty("User-Agent", UA);
            c.setRequestProperty("Referer", "https://game.aq.com/game/");
            c.setRequestProperty("X-Requested-With", "ShockwaveFlash/32.0.0.465");
            if (req.body.length > 0 || req.method.equals("POST")) {
                c.setDoOutput(true);
                try (OutputStream o = c.getOutputStream()) {
                    o.write(req.body);
                }
            }
            int code = c.getResponseCode();
            if (code < 300 || code > 308 || code == 304) return c;
            String loc = c.getHeaderField("Location");
            c.disconnect();
            if (loc == null) throw new IOException("redirect without location");
            u = new URL(u, loc);
            if (!"https".equals(u.getProtocol()) || !allowedHost(u.getHost())) throw new IOException("redirect off the game's hosts");
        }
        throw new IOException("too many redirects");
    }

    private static String cacheKey(String host, String path, String query) {
        StringBuilder kept = new StringBuilder();
        for (String part : query.split("&")) {
            if (part.isEmpty() || part.startsWith("ver=")) continue;
            if (kept.length() > 0) kept.append('&');
            kept.append(part);
        }
        return host.toLowerCase(Locale.ROOT) + path + (kept.length() == 0 ? "" : "?" + kept);
    }

    private File cacheFile(String key) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] d = md.digest(key.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < 16; i++) sb.append(String.format(Locale.ROOT, "%02x", d[i]));
            return new File(cacheDir, sb.toString());
        } catch (Exception e) {
            return null;
        }
    }

    private void sendCached(OutputStream out, File f, String kind) throws IOException {
        try (InputStream in = new FileInputStream(f)) {

            Map<String, String> headers = new HashMap<>();
            headers.put("Content-Security-Policy", "sandbox");
            send(out, 200, "OK", MIME.getOrDefault(kind, "application/octet-stream"), readAll(in), headers);
        }
    }

    private static String[] readMeta(File meta) {
        if (meta == null || !meta.isFile()) return null;
        try (InputStream in = new FileInputStream(meta)) {
            String[] parts = new String(readAll(in), StandardCharsets.UTF_8).split("\n", -1);
            return new String[]{parts.length > 0 && !parts[0].isEmpty() ? parts[0] : null, parts.length > 1 && !parts[1].isEmpty() ? parts[1] : null};
        } catch (IOException e) {
            return null;
        }
    }

    private synchronized void store(File f, File meta, byte[] body, HttpURLConnection c) {
        try {
            if (!cacheDir.isDirectory() && !cacheDir.mkdirs()) return;
            File tmp = new File(f.getPath() + ".tmp");
            try (OutputStream o = new FileOutputStream(tmp)) {
                o.write(body);
            }
            if (!tmp.renameTo(f)) {
                tmp.delete();
                return;
            }
            String etag = c.getHeaderField("ETag");
            String lm = c.getHeaderField("Last-Modified");
            try (OutputStream o = new FileOutputStream(meta)) {
                o.write(((etag == null ? "" : etag) + "\n" + (lm == null ? "" : lm)).getBytes(StandardCharsets.UTF_8));
            }
            trimCache();
        } catch (IOException e) {
            Log.w(TAG, "cache: " + e.getMessage());
        }
    }

    private void trimCache() {
        File[] files = cacheDir.listFiles();
        if (files == null) return;
        long total = 0;
        for (File f : files) total += f.length();
        if (total <= CACHE_MAX) return;
        Arrays.sort(files, (x, y) -> Long.compare(x.lastModified(), y.lastModified()));
        for (File f : files) {
            if (total <= CACHE_MAX * 8 / 10) break;
            total -= f.length();
            f.delete();
        }
    }

    private void loadServerList() {
        try {
            HttpURLConnection c = (HttpURLConnection) new URL(SERVERS).openConnection();
            c.setConnectTimeout(8000);
            c.setReadTimeout(8000);
            c.setRequestProperty("User-Agent", UA);
            JSONArray arr = new JSONArray(new String(readAll(c.getInputStream()), StandardCharsets.UTF_8));
            List<String[]> list = new ArrayList<>();
            for (int i = 0; i < arr.length(); i++) {
                JSONObject s = arr.getJSONObject(i);
                String ip = s.optString("sIP", "");
                int port = s.optInt("iPort", 0);
                if (!ip.isEmpty() && port > 0) list.add(new String[]{ip, String.valueOf(port)});
            }
            serverList = list;
            c.disconnect();
        } catch (Exception e) {
            Log.w(TAG, "server list: " + e.getMessage());
        }
    }

    private boolean allowedSocket(String host, int port) {
        List<String[]> list = serverList;
        if (list != null) for (String[] s : list) if (s[0].equalsIgnoreCase(host) && Integer.parseInt(s[1]) == port) return true;
        String h = host.toLowerCase(Locale.ROOT);
        return h.endsWith(".aq.com") && port >= 5588 && port <= 5600;
    }

    private String config() {
        if (serverList == null) {
            for (int i = 0; i < 40 && serverList == null; i++) {
                try {
                    Thread.sleep(200);
                } catch (InterruptedException e) {
                    break;
                }
            }
        }
        Set<String> seen = new HashSet<>();
        JSONArray sockets = new JSONArray();
        try {
            List<String[]> all = new ArrayList<>();
            if (serverList != null) all.addAll(serverList);
            for (int i = 1; i <= 20; i++) for (int p = 5588; p <= 5600; p++) all.add(new String[]{"sock" + i + ".aq.com", String.valueOf(p)});
            for (String[] s : all) {
                if (!seen.add(s[0].toLowerCase(Locale.ROOT) + ":" + s[1])) continue;
                JSONObject o = new JSONObject();
                o.put("host", s[0]);
                o.put("port", Integer.parseInt(s[1]));
                o.put("proxyUrl", "ws://127.0.0.1:" + server.getLocalPort() + "/" + token + "/ws/sock?h=" + s[0] + "&p=" + s[1]);
                sockets.put(o);
            }
            JSONObject cfg = new JSONObject();
            cfg.put("quality", "high");
            cfg.put("frameRate", 0);
            cfg.put("maxPixelRatio", 3);
            cfg.put("preferredRenderer", "webgl");
            cfg.put("touchRowH", phone ? 60 : 0);
            cfg.put("socketProxy", sockets);
            return cfg.toString();
        } catch (Exception e) {
            return "{}";
        }
    }

    private void webSocket(Socket socket, Request req, InputStream in, OutputStream out) throws IOException {
        String key = req.header("Sec-WebSocket-Key");
        String host = null;
        int port = 0;
        for (String part : req.query.split("&")) {
            int eq = part.indexOf('=');
            if (eq < 0) continue;
            String k = part.substring(0, eq);
            String v = URLDecoder.decode(part.substring(eq + 1), "UTF-8");
            if (k.equals("h")) host = v;
            else if (k.equals("p")) {
                try {
                    port = Integer.parseInt(v);
                } catch (NumberFormatException ignored) {
                }
            }
        }
        String upgrade = req.header("Upgrade");
        if (key == null || upgrade == null || !upgrade.equalsIgnoreCase("websocket") || host == null || !allowedSocket(host, port)) {
            text(out, 403, "Forbidden", "socket not allowed");
            socket.close();
            return;
        }
        String accept;
        try {
            accept = Base64.getEncoder().encodeToString(MessageDigest.getInstance("SHA-1")
                    .digest((key + WS_GUID).getBytes(StandardCharsets.ISO_8859_1)));
        } catch (Exception e) {
            socket.close();
            return;
        }
        Socket tcp = new Socket();
        try {
            tcp.setTcpNoDelay(true);
            tcp.connect(new InetSocketAddress(host, port), 15000);
        } catch (IOException e) {
            Log.w(TAG, "socket " + host + ":" + port + ": " + e.getMessage());
            text(out, 502, "Bad Gateway", "connect failed");
            socket.close();
            tcp.close();
            return;
        }
        out.write(("HTTP/1.1 101 Switching Protocols\r\nUpgrade: websocket\r\nConnection: Upgrade\r\nSec-WebSocket-Accept: "
                + accept + "\r\n\r\n").getBytes(StandardCharsets.ISO_8859_1));
        out.flush();
        socket.setSoTimeout(0);
        InputStream tin = tcp.getInputStream();
        OutputStream tout = tcp.getOutputStream();
        Object sendLock = new Object();
        Runnable down = () -> {
            byte[] buf = new byte[32 * 1024];
            try {
                int n;
                while ((n = tin.read(buf)) > 0) {
                    synchronized (sendLock) {
                        writeFrame(out, 0x2, buf, n);
                    }
                }
            } catch (IOException ignored) {
            } finally {
                try {
                    synchronized (sendLock) {
                        writeFrame(out, 0x8, new byte[0], 0);
                    }
                } catch (IOException ignored) {
                }
                closeQuietly(socket);
                closeQuietly(tcp);
            }
        };
        try {
            pool.execute(down);
        } catch (RejectedExecutionException full) {
            closeQuietly(tcp);
            closeQuietly(socket);
            return;
        }
        try {
            while (true) {
                int b0 = in.read();
                int b1 = in.read();
                if (b0 < 0 || b1 < 0) break;
                int op = b0 & 0x0F;
                boolean masked = (b1 & 0x80) != 0;
                long len = b1 & 0x7F;
                if (len == 126) len = ((long) readByte(in) << 8) | readByte(in);
                else if (len == 127) {
                    len = 0;
                    for (int i = 0; i < 8; i++) len = (len << 8) | readByte(in);
                }
                if (!masked || len < 0 || len > MAX_BODY) break;
                byte[] mask = new byte[4];
                readFully(in, mask, 4);
                byte[] data = new byte[(int) len];
                readFully(in, data, (int) len);
                for (int i = 0; i < data.length; i++) data[i] ^= mask[i & 3];
                if (op == 0x8) break;
                if (op == 0x9) {
                    synchronized (sendLock) {
                        writeFrame(out, 0xA, data, data.length);
                    }
                    continue;
                }
                if (op == 0x0 || op == 0x1 || op == 0x2) {
                    tout.write(data);
                    tout.flush();
                }
            }
        } catch (IOException ignored) {
        } finally {
            closeQuietly(tcp);
            closeQuietly(socket);
        }
    }

    private static int readByte(InputStream in) throws IOException {
        int b = in.read();
        if (b < 0) throw new IOException("closed");
        return b;
    }

    private static void readFully(InputStream in, byte[] buf, int len) throws IOException {
        int got = 0;
        while (got < len) {
            int n = in.read(buf, got, len - got);
            if (n < 0) throw new IOException("closed");
            got += n;
        }
    }

    private static void writeFrame(OutputStream out, int op, byte[] data, int len) throws IOException {
        ByteArrayOutputStream f = new ByteArrayOutputStream(len + 10);
        f.write(0x80 | op);
        if (len < 126) f.write(len);
        else if (len < 65536) {
            f.write(126);
            f.write(len >> 8);
            f.write(len & 0xFF);
        } else {
            f.write(127);
            for (int i = 7; i >= 0; i--) f.write((int) (((long) len >> (8 * i)) & 0xFF));
        }
        f.write(data, 0, len);
        out.write(f.toByteArray());
        out.flush();
    }

    private static void closeQuietly(Socket s) {
        try {
            s.close();
        } catch (IOException ignored) {
        }
    }
}
