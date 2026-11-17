"""Builds web/mva.swf, the MVA game loader, from loader/src.

FFDec (JPEXS) compiles ActionScript 3, but only into classes that already exist in a SWF. So this
script first writes a skeleton SWF of its own: one empty class per source file (names taken from the
sources), with nothing else in it. FFDec then compiles every source into its class. The result is
cleaned (no product info, metadata or debug tags), and checked: every class must have landed and no
forbidden word may appear anywhere in the uncompressed file.

Needs Java and FFDec:  MVA_JAVA (default: java on PATH)  MVA_FFDEC (path to ffdec.jar)

Run:  python -I tools/build_loader.py
"""
import os
import re
import shutil
import struct
import subprocess
import sys
import tempfile
import zlib
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "loader" / "src"
OUT = ROOT / "web" / "mva.swf"
DOC_CLASS = "mva.Main"
# Kept reversed so this file passes its own scan.
FORBIDDEN = [w[::-1].encode() for w in ("auks", "aukseb" + "iv", "rezilanretxe", "yrtsigeretomer")]
STAGE_W, STAGE_H, FPS = 958, 550, 30
SWF_VERSION = 43


def u30(v: int) -> bytes:
    out = bytearray()
    while True:
        b = v & 0x7F
        v >>= 7
        if v:
            out.append(b | 0x80)
        else:
            out.append(b)
            return bytes(out)


def read_u30(buf: bytes, pos: int):
    result = shift = 0
    while True:
        b = buf[pos]
        pos += 1
        result |= (b & 0x7F) << shift
        if not b & 0x80:
            return result, pos
        shift += 7


class Pool:
    def __init__(self):
        self.strings = [""]
        self.namespaces = [None]
        self.multinames = [None]

    def s(self, text):
        if text not in self.strings:
            self.strings.append(text)
        return self.strings.index(text)

    def pkg(self, name):
        key = (0x16, self.s(name))
        if key not in self.namespaces:
            self.namespaces.append(key)
        return self.namespaces.index(key)

    def qname(self, package, name):
        key = (0x07, self.pkg(package), self.s(name))
        if key not in self.multinames:
            self.multinames.append(key)
        return self.multinames.index(key)

    def encode(self):
        out = bytearray(u30(0) + u30(0) + u30(0))       # no ints, uints, doubles
        out += u30(len(self.strings))
        for t in self.strings[1:]:
            b = t.encode("utf-8")
            out += u30(len(b)) + b
        out += u30(len(self.namespaces))
        for kind, name in self.namespaces[1:]:
            out += bytes([kind]) + u30(name)
        out += u30(0)                                    # no namespace sets
        out += u30(len(self.multinames))
        for kind, ns, name in self.multinames[1:]:
            out += bytes([kind]) + u30(ns) + u30(name)
        return bytes(out)


def skeleton_abc(classes):
    """One script per class; each class extends Object with an empty constructor."""
    p = Pool()
    obj = p.qname("", "Object")
    methods, bodies, instances, statics, scripts = [], [], [], [], []

    def method(code, stack, locals_, init_scope, max_scope):
        idx = len(methods)
        methods.append(u30(0) + u30(0) + u30(0) + bytes([0]))   # no params, any return, no name, no flags
        bodies.append(u30(idx) + u30(stack) + u30(locals_) + u30(init_scope) + u30(max_scope)
                      + u30(len(code)) + code + u30(0) + u30(0))
        return idx

    for i, (package, name) in enumerate(classes):
        cls = p.qname(package, name)
        iinit = method(bytes([0xD0, 0x30, 0xD0, 0x49, 0x00, 0x47]), 1, 1, 2, 3)
        cinit = method(bytes([0xD0, 0x30, 0x47]), 1, 1, 2, 3)
        instances.append(u30(cls) + u30(obj) + bytes([0]) + u30(0) + u30(iinit) + u30(0))
        statics.append(u30(cinit) + u30(0))
        code = (bytes([0xD0, 0x30, 0x65, 0x00, 0x60]) + u30(obj) + bytes([0x30, 0x60]) + u30(obj)
                + bytes([0x58]) + u30(i) + bytes([0x1D, 0x68]) + u30(cls) + bytes([0x47]))
        init = method(code, 2, 1, 0, 2)
        scripts.append(u30(init) + u30(1) + u30(cls) + bytes([4]) + u30(0) + u30(i))

    abc = bytearray(struct.pack("<HH", 16, 46))
    abc += p.encode()
    abc += u30(len(methods)) + b"".join(methods)
    abc += u30(0)                                        # no metadata
    abc += u30(len(classes)) + b"".join(instances) + b"".join(statics)
    abc += u30(len(scripts)) + b"".join(scripts)
    abc += u30(len(bodies)) + b"".join(bodies)
    return bytes(abc)


def tag(code, body=b""):
    if len(body) < 0x3F:
        return struct.pack("<H", (code << 6) | len(body)) + body
    return struct.pack("<HI", (code << 6) | 0x3F, len(body)) + body


def rect(xmin, xmax, ymin, ymax):
    vals = [xmin, xmax, ymin, ymax]
    nbits = max(max(v.bit_length() for v in vals) + 1, 1)
    bits = format(nbits, "05b") + "".join(format(v, f"0{nbits}b") for v in vals)
    bits += "0" * (-len(bits) % 8)
    return bytes(int(bits[i:i + 8], 2) for i in range(0, len(bits), 8))


def skeleton_swf(classes):
    body = rect(0, STAGE_W * 20, 0, STAGE_H * 20) + struct.pack("<HH", FPS << 8, 1)
    body += tag(69, struct.pack("<I", 0x09))             # FileAttributes: AS3 + network access
    body += tag(9, b"\x00\x00\x00")                      # black background
    body += tag(82, struct.pack("<I", 1) + b"\x00" + skeleton_abc(classes))
    body += tag(76, struct.pack("<HH", 1, 0) + DOC_CLASS.encode() + b"\x00")
    body += tag(1) + tag(0)
    return b"FWS" + bytes([SWF_VERSION]) + struct.pack("<I", 8 + len(body)) + body


def parse_swf(data: bytes):
    sig = data[:3]
    if sig == b"CWS":
        body = zlib.decompress(data[8:])
    elif sig == b"FWS":
        body = data[8:]
    else:
        raise SystemExit(f"unsupported SWF signature {sig!r}")
    nbits = body[0] >> 3
    hdr_len = (5 + nbits * 4 + 7) // 8 + 4
    header, pos, tags = body[:hdr_len], hdr_len, []
    while pos < len(body):
        code_len = struct.unpack_from("<H", body, pos)[0]
        code, length, pos = code_len >> 6, code_len & 0x3F, pos + 2
        if length == 0x3F:
            length = struct.unpack_from("<I", body, pos)[0]
            pos += 4
        tags.append((code, body[pos:pos + length]))
        pos += length
        if code == 0:
            break
    return data[3], header, tags


def clean_swf(data: bytes) -> bytes:
    """Drops product info, metadata and debugger tags, clears the metadata flag, recompresses."""
    version, header, tags = parse_swf(data)
    keep = []
    for code, body in tags:
        if code in (41, 77, 63, 64, 58):
            continue
        if code == 69:
            body = struct.pack("<I", struct.unpack_from("<I", body)[0] & ~0x10)
        keep.append(tag(code, body) if code != 0 else tag(0))
    raw = header + b"".join(keep)
    return b"CWS" + bytes([version]) + struct.pack("<I", 8 + len(raw)) + zlib.compress(raw, 9)


def abc_strings(data: bytes):
    _, _, tags = parse_swf(data)
    out = []
    for code, body in tags:
        if code not in (72, 82):
            continue
        p = body.index(b"\x00", 4) + 1 if code == 82 else 0
        abc = body[p:]
        pos = 4
        n, pos = read_u30(abc, pos)
        for _ in range(max(0, n - 1)):
            _, pos = read_u30(abc, pos)
        n, pos = read_u30(abc, pos)
        for _ in range(max(0, n - 1)):
            _, pos = read_u30(abc, pos)
        n, pos = read_u30(abc, pos)
        pos += 8 * max(0, n - 1)
        n, pos = read_u30(abc, pos)
        for _ in range(max(0, n - 1)):
            ln, pos = read_u30(abc, pos)
            out.append(abc[pos:pos + ln].decode("utf-8", "replace"))
            pos += ln
    return out


def classes_from_sources():
    found = []
    for f in sorted(SRC.rglob("*.as")):
        text = f.read_text(encoding="utf-8")
        pkg = re.search(r"^\s*package\s+([\w.]*)\s*\{", text, re.M)
        cls = re.search(r"\b(?:public\s+)?(?:final\s+|dynamic\s+)*class\s+(\w+)", text)
        if not pkg or not cls:
            raise SystemExit(f"{f}: no package or class found")
        rel = f.relative_to(SRC).with_suffix("").as_posix().replace("/", ".")
        full = (pkg.group(1) + "." if pkg.group(1) else "") + cls.group(1)
        if rel != full:
            raise SystemExit(f"{f}: file path says {rel}, source says {full}")
        found.append((pkg.group(1), cls.group(1)))
    return found


def ffdec(*args):
    java = os.environ.get("MVA_JAVA", "java")
    jar = os.environ.get("MVA_FFDEC")
    if not jar:
        raise SystemExit("set MVA_FFDEC to ffdec.jar")
    r = subprocess.run([java, "-jar", jar, *args], capture_output=True, text=True)
    log = (r.stdout + r.stderr).strip()
    if r.returncode != 0 or re.search(r"(?i)\b(error|exception)\b", log):
        print(log[-3000:])
        raise SystemExit("FFDec failed: " + " ".join(args[:1]))
    return log


def main():
    classes = classes_from_sources()
    print(f"{len(classes)} classes: " + ", ".join(f"{p}.{n}" for p, n in classes))
    with tempfile.TemporaryDirectory(prefix="mva-loader-") as tmp:
        tmp = Path(tmp)
        (tmp / "skeleton.swf").write_bytes(skeleton_swf(classes))
        scripts = tmp / "scripts"
        shutil.copytree(SRC, scripts)
        ffdec("-importScript", str(tmp / "skeleton.swf"), str(tmp / "built.swf"), str(scripts))
        data = clean_swf((tmp / "built.swf").read_bytes())
        (tmp / "clean.swf").write_bytes(data)
        # Every class must have landed: FFDec skips a source silently when it can't place it.
        check = tmp / "check"
        ffdec("-export", "script", str(check), str(tmp / "clean.swf"))
        for p, n in classes:
            path = check / "scripts" / Path(*p.split(".")) / f"{n}.as"
            text = path.read_text(encoding="utf-8") if path.exists() else ""
            if len(text.splitlines()) < 4 or re.search(r"class\s+" + n + r"\s*\{\s*public function " + n + r"\(\)\s*\{\s*super\(\);\s*\}\s*\}", text):
                raise SystemExit(f"class {p}.{n} did not compile into the loader")
    _, _, tags = parse_swf(data)
    plain = b"".join(t[1] for t in tags).lower()
    hits = [w.decode() for w in FORBIDDEN if w in plain]
    hits += [s for s in abc_strings(data) if any(w.decode() in s.lower() for w in FORBIDDEN)]
    if hits:
        raise SystemExit("forbidden words in the loader: " + ", ".join(sorted(set(hits))))
    OUT.write_bytes(data)
    print(f"wrote {OUT} ({len(data)} bytes), forbidden-word scan clean")


if __name__ == "__main__":
    main()
