#!/usr/bin/env python3
"""Build the static site.

The source .typ files are PLAIN Typst documents — they contain no web-specific
markup and compile to PDF on their own. Everything needed for the web is
resolved here: for each page/post this generates a tiny wrapper that applies
typst/lib/web.typ (nav, paper styling, math/diagram -> SVG, heading levels),
passes metadata via --input, compiles to HTML, stitches inline-math paragraphs
back together, and injects <title>/<link> into <head>.
"""

import json
import re
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
TYPST = ROOT / "typst"
OUT = ROOT / "_site"
CSS_HREF = "/assets/css/styles.css"
WRAPPER = TYPST / "__build_wrapper__.typ"

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


def inject_head(html: str, title: str) -> str:
    extra = (
        f"    <title>{title}</title>\n"
        f'    <link rel="stylesheet" href="{CSS_HREF}">\n'
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


def build() -> None:
    manifest = json.loads((TYPST / "pages.json").read_text())

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

    # Thoughts index — generated entirely from the manifest.
    html = compile_wrapper(
        '#import "/lib/web.typ": web-thoughts\n#web-thoughts()\n',
        {"current": "/thoughts.html"},
    )
    emit("thoughts.html", html, "thoughts")
    print("  (generated) -> _site/thoughts.html")

    # Articles.
    for p in manifest["posts"]:
        html = compile_wrapper(
            f'#import "/lib/web.typ": web-post\n'
            f"#show: web-post\n"
            f'#include "/{p["src"]}"\n',
            {
                "current": "",
                "title": p["title"],
                "date": p["date_meta"],
                "author": p["author"],
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
