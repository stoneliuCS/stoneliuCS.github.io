#!/usr/bin/env python3
"""Build the static site.

The source .typ files are PLAIN Typst documents — they contain no web-specific
markup and compile to PDF on their own. Everything needed for the web is
resolved here: for each page/post this generates a tiny wrapper that applies
typst/lib/web.typ (nav, paper styling, math/diagram -> SVG, heading levels),
passes metadata via --input, compiles to HTML, stitches inline-math paragraphs
back together, and injects <title>/<link> into <head>.
"""

import datetime
import hashlib
import json
import re
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
TYPST = ROOT / "typst"
POSTS = TYPST / "posts"
OUT = ROOT / "_site"
CSS_FILE = TYPST / "assets" / "css" / "styles.css"
CSS_HREF = "/assets/css/styles.css"
WRAPPER = TYPST / "__build_wrapper__.typ"

# Google Analytics (GA4) Measurement ID, e.g. "G-XXXXXXXXXX". Find it under
# analytics.google.com -> Admin -> Data Streams -> your web stream. It is public
# (served in every page's HTML), so it's fine to commit. Leave "" to disable.
GA_MEASUREMENT_ID = "G-7SRSHNGC31"


def ga_snippet() -> str:
    """The standard gtag.js snippet, or "" when no Measurement ID is set."""
    if not GA_MEASUREMENT_ID:
        return ""
    return (
        f'    <script async src="https://www.googletagmanager.com/gtag/js?id={GA_MEASUREMENT_ID}"></script>\n'
        f"    <script>\n"
        f"      window.dataLayer = window.dataLayer || [];\n"
        f"      function gtag(){{dataLayer.push(arguments);}}\n"
        f"      gtag('js', new Date());\n"
        f"      gtag('config', '{GA_MEASUREMENT_ID}');\n"
        f"    </script>\n"
    )


def css_href() -> str:
    """CSS link with a content-hash query so browsers/CDNs can't serve a stale
    stylesheet: the URL changes whenever styles.css changes."""
    digest = hashlib.sha1(CSS_FILE.read_bytes()).hexdigest()[:8]
    return f"{CSS_HREF}?v={digest}"
# Posts are auto-discovered from typst/posts/*.typ: each carries a
# `#metadata((...)) <post-meta>` block that build.py reads (via `typst query`)
# and expands into the full manifest entry written here for web.typ to read.
POST_MANIFEST = TYPST / "_posts.json"

# Typst HTML export splits a paragraph at every inline equation, emitting
# <p>text</p><svg/><p>text</p>. Stitch those back into one paragraph so inline
# math flows within the prose. Block equations live in <div class="math-block">
# (preceded by <div>, not a bare <svg>), so they're left untouched.
_INLINE_MATH = re.compile(r'</p>\s*(<svg class="typst-frame".*?</svg>)\s*<p>', re.S)
_SVG_HEIGHT = re.compile(r"height:\s*([\d.]+)em")

# Inline-math SVGs carry no baseline, so they'd sit too high in the line. The
# math axis is ~0.22em above the text baseline; align each equation's vertical
# centre to it, so taller equations (e.g. inline fractions) shift down more.
_MATH_AXIS_EM = 0.22


def _align_inline(svg: str) -> str:
    m = _SVG_HEIGHT.search(svg)
    if not m:
        return svg
    valign = round(_MATH_AXIS_EM - float(m.group(1)) / 2, 3)
    return svg.replace(
        'style="overflow: visible;',
        f'style="overflow: visible; vertical-align: {valign}em;',
        1,
    )


def stitch_inline_math(html: str) -> str:
    return _INLINE_MATH.sub(lambda m: " " + _align_inline(m.group(1)) + " ", html)


def last_modified(src: Path) -> str:
    """Date (YYYY-MM-DD) of the last git commit touching the file, '' if none."""
    proc = subprocess.run(
        ["git", "log", "-1", "--format=%cs", "--", str(src)],
        capture_output=True, text=True, cwd=ROOT,
    )
    return proc.stdout.strip() if proc.returncode == 0 else ""


def inject_head(html: str, title: str) -> str:
    extra = (
        f"    <title>{title}</title>\n"
        f'    <link rel="stylesheet" href="{css_href()}">\n'
        f"{ga_snippet()}"
    )
    if "  </head>" not in html:
        raise RuntimeError("expected '</head>' in Typst HTML output")
    return html.replace("  </head>", extra + "  </head>", 1)


def compile_wrapper(wrapper_src: str, inputs: dict) -> str:
    WRAPPER.write_text(wrapper_src)
    try:
        cmd = [
            "typst", "compile", "--features", "html", "--format", "html",
            "--root", str(TYPST),
            "--input", "web=true",  # lets lib/web.typ pick its HTML branch (e.g. aside)
        ]
        for key, value in inputs.items():
            cmd += ["--input", f"{key}={value}"]
        cmd += [str(WRAPPER), "-"]
        return subprocess.run(
            cmd, check=True, capture_output=True, text=True
        ).stdout
    finally:
        WRAPPER.unlink(missing_ok=True)


def emit(out_rel: str, html: str, title: str) -> None:
    dest = OUT / out_rel
    dest.parent.mkdir(parents=True, exist_ok=True)
    dest.write_text(inject_head(stitch_inline_math(html), title))


def read_post_meta(src: Path) -> dict:
    """Pull the <post-meta> dictionary out of a post via `typst query`."""
    proc = subprocess.run(
        ["typst", "query", "--root", str(TYPST), str(src),
         "<post-meta>", "--field", "value", "--one"],
        capture_output=True, text=True,
    )
    if proc.returncode != 0:
        hint = ""
        if "found 0" in proc.stderr:
            hint = (
                "\n  -> add a metadata block at the top:\n"
                '     #metadata((title: \"...\", date: \"YYYY-MM-DD\", '
                'section: \"notes\"|\"thoughts\")) <post-meta>'
            )
        raise RuntimeError(f"{src.name}: could not read <post-meta>{hint}\n{proc.stderr.strip()}")
    return json.loads(proc.stdout)


def post_entry(src: Path, meta: dict) -> dict:
    """Expand a post's metadata into a full manifest entry, deriving the
    mechanical fields (url, output path, both date formats) so they can't
    drift out of sync."""
    try:
        date = datetime.date.fromisoformat(meta["date"])
    except (KeyError, ValueError):
        raise RuntimeError(f"{src.name}: <post-meta> needs a date as YYYY-MM-DD")
    section = meta.get("section")
    if section not in ("thoughts", "notes"):
        raise RuntimeError(
            f'{src.name}: <post-meta> section must be "thoughts" or "notes", got {section!r}'
        )

    slug = meta.get("slug") or meta["title"].replace(" ", "-")
    out_rel = f"{date:%Y/%m/%d}/{slug}.html"
    entry = {
        "src": src.relative_to(TYPST).as_posix(),
        "out": out_rel,
        "url": "/" + out_rel,
        "title": meta["title"],
        "section": section,
        "author": meta.get("author", "Stone Liu"),
        "date_meta": f"{date:%d %b %Y}",
        "date_list": f"{date:%B} {date.day}, {date:%Y}",
        "_date": date.isoformat(),
    }
    if "topic" in meta:
        entry["topic"] = meta["topic"]
    if meta.get("description"):
        entry["description"] = meta["description"]
    if meta.get("featured"):
        entry["featured"] = True
    # "Last updated" from git: shown only when later than the publish date.
    mod = last_modified(src)
    if mod:
        try:
            mdate = datetime.date.fromisoformat(mod)
            if mdate > date:
                entry["modified_meta"] = f"{mdate:%d %b %Y}"
        except ValueError:
            pass
    return entry


def discover_posts() -> list:
    """Build the post manifest from typst/posts/*.typ, newest first."""
    posts = [post_entry(src, read_post_meta(src)) for src in sorted(POSTS.glob("*.typ"))]
    posts.sort(key=lambda p: p["_date"], reverse=True)
    POST_MANIFEST.write_text(json.dumps(posts, indent=2) + "\n")
    return posts


def build() -> None:
    manifest = json.loads((TYPST / "pages.json").read_text())
    posts = discover_posts()

    if OUT.exists():
        shutil.rmtree(OUT)
    OUT.mkdir(parents=True)
    shutil.copytree(TYPST / "assets", OUT / "assets")

    # Plain content pages (the home page).
    for pg in manifest["pages"]:
        html = compile_wrapper(
            f'#import "/lib/web.typ": web-page\n'
            f"#show: web-page\n"
            f'#include "/{pg["src"]}"\n',
            {"current": pg.get("current", "")},
        )
        emit(pg["out"], html, pg["title"])
        print(f"  {pg['src']} -> _site/{pg['out']}")

    # Thoughts index (standalone takes) — generated from the manifest.
    html = compile_wrapper(
        '#import "/lib/web.typ": web-thoughts\n#web-thoughts()\n',
        {"current": "/thoughts.html"},
    )
    emit("thoughts.html", html, "thoughts")
    print("  (generated) -> _site/thoughts.html")

    # Notes index (topic-grouped) — generated from the manifest.
    html = compile_wrapper(
        '#import "/lib/web.typ": web-notes\n#web-notes()\n',
        {"current": "/notes.html"},
    )
    emit("notes.html", html, "notes")
    print("  (generated) -> _site/notes.html")

    # Articles.
    for p in posts:
        html = compile_wrapper(
            f'#import "/lib/web.typ": web-post\n'
            f"#show: web-post\n"
            f'#include "/{p["src"]}"\n',
            {
                "current": "",
                "title": p["title"],
                "date": p["date_meta"],
                "author": p["author"],
                "modified": p.get("modified_meta", ""),
            },
        )
        emit(p["out"], html, p["title"])
        print(f"  {p['src']} -> _site/{p['out']}")

    print(f"Built site into {OUT}")


if __name__ == "__main__":
    try:
        build()
    except subprocess.CalledProcessError as exc:
        sys.stderr.write(exc.stderr or "")
        sys.exit(exc.returncode)
