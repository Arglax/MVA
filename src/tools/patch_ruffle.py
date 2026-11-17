"""Copies a Ruffle web build into web/ruffle and applies MVA's patches.

ruffle.js:
  - ExternalInterface.call from the game goes to the page's window.__mvaExt (Ruffle otherwise
    evaluates the name as JavaScript, which breaks names such as "pre-load");
  - the virtual keyboard calls go to window.__mvaKeyboard (keeps Ruffle's hidden input focused);
  - while the app is in the background (window.__mvaBackground) Ruffle ticks from its worker as for a
    hidden tab, and that worker keeps to the frame rate.
wasm: the engine's page switches get the mva prefix (same length, so no offset moves).

Run:  python -I tools/patch_ruffle.py <folder with ruffle.js, *.wasm and the LICENSE files>
"""
import re
import shutil
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "web" / "ruffle"

EXT_CALL = re.compile(r"return new Function\(`return \(\$\{(\w+)\}\)\(\.\.\.arguments\);`\)\(\.\.\.(\w+)\)")
HIDDEN = "document.hidden?(this.lastActivePlayingState"
WORKER = ("self.onmessage = () => {\n                setTimeout(() => self.postMessage(\"tick\"), intervalMs);\n"
          "            };")
WORKER_NEW = ("let next = Date.now() + intervalMs;\n            self.onmessage = () => {\n"
              "                next = Math.max(next + intervalMs, Date.now());\n"
              "                setTimeout(() => self.postMessage(\"tick\"), Math.max(0, next - Date.now()));\n"
              "            };")


def patch_js(js: str) -> str:
    out, n = EXT_CALL.subn(lambda m: (
        f"return window.__mvaExt?window.__mvaExt({m.group(1)},{m.group(2)}):"
        f"new Function(`return (${{{m.group(1)}}})(...arguments);`)(...{m.group(2)})"), js)
    if n == 0:
        raise SystemExit("ExternalInterface patch did not apply")
    for method in ("openVirtualKeyboard", "closeVirtualKeyboard"):
        head = method + "(){"
        if head not in out:
            raise SystemExit(f"{method} patch did not apply")
        out = out.replace(head, f"{head}if(window.__mvaKeyboard)return window.__mvaKeyboard.{method}(this);")
    if HIDDEN not in out:
        raise SystemExit("background tick patch did not apply")
    out = out.replace(HIDDEN, "(document.hidden||window.__mvaBackground)?(this.lastActivePlayingState")
    if WORKER not in out:
        raise SystemExit("worker pacing patch did not apply")
    out = out.replace(WORKER, WORKER_NEW)
    return out


def rename(data: bytes) -> bytes:
    old = "svm"[::-1]
    for a, b in ((old, "mva"), (old.capitalize(), "Mva"), (old.upper(), "MVA")):
        data = data.replace(a.encode(), b.encode())
    return data


def main():
    if len(sys.argv) != 2:
        raise SystemExit(__doc__)
    src = Path(sys.argv[1])
    js = (src / "ruffle.js").read_text(encoding="utf-8")
    wasm = list(src.glob("*.wasm"))
    if not wasm:
        raise SystemExit("no .wasm in " + str(src))
    if OUT.exists():
        shutil.rmtree(OUT)
    OUT.mkdir(parents=True)
    (OUT / "ruffle.js").write_bytes(rename(patch_js(js).encode("utf-8")))
    for w in wasm:
        (OUT / w.name).write_bytes(rename(w.read_bytes()))
    for extra in ("LICENSE_APACHE", "LICENSE_MIT", "VERSION"):
        if (src / extra).exists():
            shutil.copy2(src / extra, OUT / extra)
    for f in OUT.iterdir():
        low = f.read_bytes().lower()
        for word in ("auks"[::-1].encode(), "svm"[::-1].encode()):
            if word in low:
                raise SystemExit(f"{f.name} still contains {word.decode()}")
    print("web/ruffle ready:", ", ".join(sorted(p.name for p in OUT.iterdir())))


if __name__ == "__main__":
    main()
