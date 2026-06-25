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
# (a <div>, never a bare <svg> right after </p>), so they're left untouched.
_INLINE_FRAME = r'<svg class="typst-frame".*?</svg>'
# A real block element (block equations are <div class="math-block">; also
# headings, lists, code, etc.). Used to tell "inline math ends a paragraph before
# a block" apart from "inline math has more prose after it".
_BLOCK_AHEAD = r"(?=\s*<(?:div|pre|ul|ol|h[1-6]|table|blockquote|figure|/(?:article|li|blockquote)))"
# inline math between two paragraph fragments -> rejoin into one paragraph.
_INLINE_MATH = re.compile(rf"</p>\s*({_INLINE_FRAME})\s*<p>", re.S)
# inline math that genuinely ENDS a paragraph (a block follows) -> keep it inside
# the preceding paragraph and re-close after it.
_INLINE_MATH_BEFORE_BLOCK = re.compile(rf"</p>\s*({_INLINE_FRAME}){_BLOCK_AHEAD}", re.S)
# inline math followed by more prose Typst failed to re-wrap -> drop the spurious
# </p> so the paragraph flows on through the equation.
_INLINE_MATH_TRAIL = re.compile(rf"</p>\s*({_INLINE_FRAME})", re.S)
# inline math orphaned at a paragraph START (preceded by a block, not </p>)
# -> fold it into the following paragraph.
_INLINE_MATH_LEAD = re.compile(rf"({_INLINE_FRAME})\s*<p>", re.S)
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
    # 1) inline math mid-paragraph: merge the two fragments back together.
    html = _INLINE_MATH.sub(lambda m: " " + _align_inline(m.group(1)) + " ", html)
    # 2) inline math that ends a paragraph right before a block: keep it in the
    #    preceding paragraph and re-close after it.
    html = _INLINE_MATH_BEFORE_BLOCK.sub(lambda m: " " + _align_inline(m.group(1)) + "</p>", html)
    # 3) inline math with more prose after it (Typst dropped the wrapping <p>):
    #    drop the spurious </p> so the paragraph flows on through the equation.
    html = _INLINE_MATH_TRAIL.sub(lambda m: " " + _align_inline(m.group(1)), html)
    # 4) inline math orphaned at a paragraph start (after a block): into next <p>.
    html = _INLINE_MATH_LEAD.sub(lambda m: "<p>" + _align_inline(m.group(1)) + " ", html)
    return html


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
                '     #metadata((title: \"...\", date: \"YYYY-MM-DD\")) <post-meta>'
                "\n     (section/topic come from the folder, not metadata)"
            )
        raise RuntimeError(f"{src.name}: could not read <post-meta>{hint}\n{proc.stderr.strip()}")
    return json.loads(proc.stdout)


def post_location(src: Path) -> tuple:
    """Derive (section, categories) from a post's folder layout, NOT its metadata:
        posts/<section>/<file>.typ                  -> (section, [])             standalone
        posts/<section>/<cat>/<file>.typ            -> (section, [cat])          grouped
        posts/<section>/<cat>/<subcat>/<file>.typ   -> (section, [cat, subcat])  nested
    Each category is the folder name verbatim (e.g. "Deep Learning"); the index
    renders the chain as nested bullets. Any depth is allowed."""
    parts = src.relative_to(POSTS).parts  # (..., "file.typ")
    folders = parts[:-1]
    if len(folders) == 0:
        raise RuntimeError(
            f"{src.name}: a post must live under a section folder "
            f"(posts/notes/... or posts/thoughts/...)"
        )
    section = folders[0]
    if section not in ("thoughts", "notes"):
        raise RuntimeError(
            f"{src.name}: section folder must be 'notes' or 'thoughts', got {section!r}"
        )
    return section, list(folders[1:])


def post_entry(src: Path, meta: dict) -> dict:
    """Expand a post's metadata into a full manifest entry, deriving the
    mechanical fields (url, output path, both date formats) so they can't
    drift out of sync. section/topic come from the folder path (post_location),
    not metadata."""
    try:
        date = datetime.date.fromisoformat(meta["date"])
    except (KeyError, ValueError):
        raise RuntimeError(f"{src.name}: <post-meta> needs a date as YYYY-MM-DD")
    section, categories = post_location(src)

    slug = meta.get("slug")
    if not slug:
        # Derive a URL-safe slug from the title: spaces -> hyphens, then drop any
        # character that isn't alnum/hyphen (e.g. "?", "(", ")", ",") so the
        # filename/URL can't break (a literal "?" would be read as a query string).
        slug = re.sub(r"[^A-Za-z0-9-]", "", meta["title"].replace(" ", "-"))
        slug = re.sub(r"-+", "-", slug).strip("-")
    out_rel = f"{date:%Y/%m/%d}/{slug}.html"
    entry = {
        "src": src.relative_to(TYPST).as_posix(),
        "out": out_rel,
        "url": "/" + out_rel,
        "slug": slug,
        "title": meta["title"],
        "section": section,
        "author": meta.get("author", "Stone Liu"),
        "date_meta": f"{date:%d %b %Y}",
        "date_list": f"{date:%B} {date.day}, {date:%Y}",
        "_date": date.isoformat(),
    }
    if categories:
        entry["categories"] = categories
    if meta.get("description"):
        entry["description"] = meta["description"]
    if meta.get("featured"):
        entry["featured"] = True
    return entry


def discover_posts() -> list:
    """Build the post manifest from typst/posts/**/*.typ (section/topic come from
    the folder each post lives in; see post_location), newest first."""
    posts = [post_entry(src, read_post_meta(src)) for src in sorted(POSTS.rglob("*.typ"))]
    posts.sort(key=lambda p: p["_date"], reverse=True)
    POST_MANIFEST.write_text(json.dumps(posts, indent=2) + "\n")
    return posts


# An <a href> pointing at an internal page (home "/" or a "/…/x.html").
# (The "#anchor" / query is stripped before matching.)
_HREF = re.compile(r'<a[^>]+href="(/[^"#?]*(?:\.html)?)(?:[#?][^"]*)?"')
_NAV = re.compile(r"<nav\b.*?</nav>", re.S)


def build_graph(posts: list) -> None:
    """Scan each page's compiled HTML for links to other pages and write the
    reference graph (nodes = home + posts, directed edges = "A links to B") to
    _site/_graph.json, consumed by the knowledge-graph renderer. The <nav> is
    stripped first so the global nav links don't connect everything together."""
    # The home page ("stone") is a node too; posts are the rest.
    url_of = {"/"} | {p["url"] for p in posts}
    nodes = [{"id": "/", "title": "stone", "section": "home"}]
    nodes += [
        {
            "id": p["url"],
            "title": p["title"],
            "section": p["section"],
            "categories": p.get("categories", []),
        }
        for p in posts
    ]
    pages = [("/", OUT / "index.html")] + [(p["url"], OUT / p["out"]) for p in posts]
    edges, seen = [], set()
    for src_url, path in pages:
        html = _NAV.sub("", path.read_text())  # drop nav so only in-content links count
        for href in _HREF.findall(html):
            if href in url_of and href != src_url and (src_url, href) not in seen:
                seen.add((src_url, href))
                edges.append({"source": src_url, "target": href})
    (OUT / "_graph.json").write_text(
        json.dumps({"nodes": nodes, "links": edges}, indent=2) + "\n"
    )
    print(f"  (generated) -> _site/_graph.json ({len(nodes)} nodes, {len(edges)} links)")


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
            },
        )
        emit(p["out"], html, p["title"])
        print(f"  {p['src']} -> _site/{p['out']}")

    # Interlinked: a reference graph of the posts, + its interactive page.
    build_graph(posts)
    html = compile_wrapper(
        '#import "/lib/web.typ": web-interlinked\n#web-interlinked()\n',
        {"current": "/explore.html"},
    )
    emit("explore.html", html, "explore")
    print("  (generated) -> _site/explore.html")

    print(f"Built site into {OUT}")


if __name__ == "__main__":
    try:
        build()
    except subprocess.CalledProcessError as exc:
        sys.stderr.write(exc.stderr or "")
        sys.exit(exc.returncode)
