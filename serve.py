#!/usr/bin/env python3
"""Dev server with live reload.

Builds once, serves _site/, and watches the Typst sources. On any change it
rebuilds and bumps a version counter; a tiny snippet injected into every served
HTML page long-polls /__livereload__ and reloads the browser when the version
changes. Pure stdlib — no extra dependencies.
"""

import http.server
import os
import threading
import time
from pathlib import Path
from urllib.parse import parse_qs, urlparse

import build

ROOT = Path(__file__).resolve().parent
OUT = ROOT / "_site"
WATCH = ROOT / "typst"
PORT = int(os.environ.get("PORT", "8000"))
# Files build.py generates inside typst/ — watching them would loop forever.
EXCLUDE = {"_posts.json", "__build_wrapper__.typ"}

_version = 0
_cond = threading.Condition()

RELOAD_JS = b"""<script>
(function () {
  let v = null;
  (async function poll() {
    try {
      const r = await fetch('/__livereload__' + (v === null ? '' : '?v=' + v));
      const n = await r.text();
      if (v !== null && n !== v) return location.reload();
      v = n;
    } catch (e) { await new Promise(r => setTimeout(r, 1000)); }
    poll();
  })();
})();
</script>
"""


def rebuild(reason: str) -> None:
    global _version
    try:
        build.build()
    except Exception as exc:  # keep serving the last good build
        print(f"[livereload] build FAILED ({reason}): {exc}")
        return
    with _cond:
        _version += 1
        _cond.notify_all()
    print(f"[livereload] rebuilt ({reason}) -> v{_version}")


def snapshot() -> dict:
    files = [ROOT / "build.py"]
    files += [f for f in WATCH.rglob("*") if f.is_file() and f.name not in EXCLUDE]
    return {f: f.stat().st_mtime for f in files}


def watch() -> None:
    prev = snapshot()
    while True:
        time.sleep(0.4)
        cur = snapshot()
        if cur != prev:
            changed = next((f.name for f in cur if prev.get(f) != cur.get(f)), "?")
            prev = cur
            rebuild(changed)


class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=str(OUT), **kwargs)

    def log_message(self, format, *args):  # quieter; rebuild logs are what matter
        pass

    def end_headers(self):  # never cache anything in dev, so reloads are fresh
        self.send_header("Cache-Control", "no-store")
        super().end_headers()

    def do_GET(self):
        if self.path.startswith("/__livereload__"):
            return self._livereload()
        fs = Path(self.translate_path(self.path))
        if fs.is_dir():
            fs = fs / "index.html"
        if fs.suffix == ".html" and fs.is_file():
            return self._serve_html(fs)
        return super().do_GET()

    def _serve_html(self, fs: Path) -> None:
        body = fs.read_bytes()
        if b"</body>" in body:
            body = body.replace(b"</body>", RELOAD_JS + b"</body>", 1)
        else:
            body += RELOAD_JS
        self.send_response(200)
        self.send_header("Content-Type", "text/html; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def _livereload(self) -> None:
        client_v = parse_qs(urlparse(self.path).query).get("v", [None])[0]
        with _cond:
            if client_v is not None and client_v == str(_version):
                _cond.wait(timeout=25)  # hold the request until a rebuild
            body = str(_version).encode()
        self.send_response(200)
        self.send_header("Content-Type", "text/plain")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)


def main() -> None:
    rebuild("initial")
    threading.Thread(target=watch, daemon=True).start()
    with http.server.ThreadingHTTPServer(("", PORT), Handler) as httpd:
        print(f"[livereload] serving http://localhost:{PORT} (Ctrl-C to stop)")
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\n[livereload] bye")


if __name__ == "__main__":
    main()
