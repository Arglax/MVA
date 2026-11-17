"""Desktop stand-in for the app's local server, for working on web/ in a desktop browser.

Serves web/, config.json (no game-server sockets: the game reaches its login screen only), the
allowlisted proxy p/<scheme>/<host>/<path>, and prints the page's log lines (a stand-in for the app
interface is put in front of index.html).

Run:  python -I tools/dev_server.py [port]      then open http://127.0.0.1:<port>/dev/
"""
import http.server
import json
import re
import sys
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path

WEB = Path(__file__).resolve().parent.parent / "web"
UA = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0 Safari/537.36"
# Stand-in for the app interface: every call is printed by this server instead of being sent anywhere.
SHIM = (b"<script>(()=>{const say=m=>fetch('log',{method:'POST',body:String(m)});window.MvaAndroid={log:say,keyboard(){},"
        b"playing:v=>say('playing '+v),openLink:u=>say('openLink '+u),count:id=>say('count '+id),"
        b"health:(k,n)=>say('health '+k+' '+n),stats:j=>say('stats '+j),problem:j=>say('problem '+j),"
        b"settings:j=>say('settings '+j)};})();</script>")
TYPES = {".html": "text/html", ".js": "text/javascript", ".json": "application/json", ".wasm": "application/wasm",
         ".swf": "application/x-shockwave-flash"}


def allowed(host):
    h = host.lower()
    if not re.fullmatch(r"[a-z0-9.-]+(:[0-9]{1,5})?", h):
        return False
    h = h.split(":")[0]
    return h in ("aq.com", "artix.com") or h.endswith(".aq.com") or h.endswith(".artix.com")


class Handler(http.server.BaseHTTPRequestHandler):
    def log_message(self, fmt, *args):
        pass

    def reply(self, code, body, ctype="text/plain"):
        self.send_response(code)
        self.send_header("Content-Type", ctype)
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def route(self):
        if not self.path.startswith("/dev/"):
            return self.reply(404, b"not found")
        path = self.path[5:]
        query = ""
        if "?" in path:
            path, query = path.split("?", 1)
        if path == "log":
            n = int(self.headers.get("Content-Length", 0))
            print("[page]", self.rfile.read(n).decode("utf-8", "replace"), flush=True)
            return self.reply(204, b"")
        if path.startswith("p/"):
            return self.proxy(path[2:], query)
        if path == "config.json":
            cfg = {"quality": "high", "frameRate": 0, "maxPixelRatio": 2, "preferredRenderer": "", "touchRowH": 0, "socketProxy": []}
            return self.reply(200, json.dumps(cfg).encode(), "application/json")
        f = (WEB / (path or "index.html")).resolve()
        if WEB not in f.parents or not f.is_file():
            return self.reply(404, b"not found")
        body = f.read_bytes()
        if f.name == "index.html":
            body = body.replace(b"<head>", b"<head>" + SHIM, 1)
        self.reply(200, body, TYPES.get(f.suffix, "application/octet-stream"))

    def proxy(self, target, query):
        scheme, _, rest = target.partition("/")
        host, _, path = rest.partition("/")
        if scheme not in ("http", "https") or not allowed(host):
            return self.reply(403, b"host not allowed")
        url = f"https://{host}/{path}" + (f"?{query}" if query else "")
        if not allowed(urllib.parse.urlsplit(url).hostname or ""):
            return self.reply(403, b"host not allowed")
        n = int(self.headers.get("Content-Length", 0) or 0)
        data = self.rfile.read(n) if n else None
        req = urllib.request.Request(url, data=data, method=self.command, headers={
            "User-Agent": UA, "Referer": "https://game.aq.com/game/", "X-Requested-With": "ShockwaveFlash/32.0.0.465"})
        for h in ("Content-Type", "ccid", "token"):
            if self.headers.get(h):
                req.add_header(h, self.headers[h])
        try:
            with urllib.request.urlopen(req, timeout=60) as r:
                self.reply(r.status, r.read(), r.headers.get("Content-Type", "application/octet-stream"))
        except urllib.error.HTTPError as e:
            self.reply(e.code, e.read() or b"", e.headers.get("Content-Type", "text/plain"))
        except Exception as e:
            self.reply(502, str(e).encode())

    do_GET = do_POST = do_HEAD = route


if __name__ == "__main__":
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8931
    print(f"http://127.0.0.1:{port}/dev/", flush=True)
    http.server.ThreadingHTTPServer(("127.0.0.1", port), Handler).serve_forever()
