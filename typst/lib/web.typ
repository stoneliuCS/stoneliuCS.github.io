// Web rendering library — used ONLY by build.py's generated wrappers.
//
// Your actual content files (index.typ, posts/*.typ) stay PLAIN Typst: normal
// headings, prose, math, images, code — nothing web-specific. Everything that
// HTML needs is resolved here and in build.py:
//   - headings keep their level (<hN>);
//   - math equations and images/diagrams become embedded SVG (HTML can't
//     represent them) — block math + images are centered via .math-block;
//   - article/page chrome (nav, paper styling, title/byline) is added here.
//
// Per-document metadata (title, date, author, current nav link) is passed in
// by build.py via `--input`, so the documents themselves carry none of it.

#let nav-items = (
  (name: "stone", link: "/"),
  (name: "thoughts", link: "/thoughts.html"),
  (name: "notes", link: "/notes.html"),
)

#let nav(current) = html.elem("nav", nav-items.map(item => {
  let attrs = if item.link == current {
    (href: item.link, class: "current")
  } else {
    (href: item.link)
  }
  html.elem("a", attrs: attrs)[#item.name]
}).join(" "))

#let _input(key, default: "") = sys.inputs.at(key, default: default)

// Margin aside for extra commentary. On the web it floats into the right
// margin as <aside class="sidenote">; compiled to PDF (no `web` input set by
// build.py) it degrades to an inline boxed callout, so a post that uses it
// still compiles to PDF on its own. Import it with a path RELATIVE to the post
// (resolves in the editor's LSP too, which doesn't know build.py's --root). The
// number of `../` depends on folder depth:
//   posts/<section>/<file>.typ          -> #import "../../lib/web.typ": aside
//   posts/<section>/<topic>/<file>.typ  -> #import "../../../lib/web.typ": aside
// `variant` appends an extra class (e.g. "reading-list") for a styled variant.
#let aside(body, variant: none) = {
  let classes = if variant != none { "sidenote " + variant } else { "sidenote" }
  if _input("web") == "true" {
    html.elem("aside", attrs: (class: classes), body)
  } else {
    block(
      width: 100%,
      inset: (x: 10pt, y: 8pt),
      radius: 4pt,
      fill: luma(246),
      stroke: (left: 2pt + luma(200)),
      text(size: 0.88em, body),
    )
  }
}

// A dated "edit" banner: a full-width note in the text flow marking that the
// article was revised. Same banner style as #bookmark / #update (tinted blue),
// NOT a margin sidenote. Web -> <div class="edit-note">; standalone PDF -> a
// styled block.
//   #edit[Reworked this section.]
//   #edit(date: "22 Jun 2026")[Reworked this section.]
#let edit(body, date: none) = {
  if _input("web") == "true" {
    html.elem("div", attrs: (class: "edit-note"), {
      html.elem("p", attrs: (class: "edit-meta"), {
        [Edit]
        if date != none { [ · #date] }
      })
      html.elem("div", attrs: (class: "edit-body"), body)
    })
  } else {
    block(
      width: 100%,
      inset: (x: 10pt, y: 8pt),
      radius: 4pt,
      fill: rgb("#eef2f7"),
      stroke: (left: 2pt + rgb("#6f8fb8")),
      {
        text(size: 0.78em, weight: "bold", fill: rgb("#6f8fb8"))[
          EDIT#if date != none [ · #date]
        ]
        parbreak()
        text(size: 0.95em, body)
      },
    )
  }
}

// A labelled definition block: a term and its definition. On the web it renders
// as <div class="definition"> (term label + body); in standalone PDF it degrades
// to a styled block. Import it like `aside` (path relative to the post).
//   #definition("Perceptron")[A neuron mapping inputs to a binary output via a
//     weighted threshold.]
#let definition(term, body) = {
  if _input("web") == "true" {
    html.elem("div", attrs: (class: "definition"), {
      html.elem("p", attrs: (class: "def-term"), term)
      html.elem("div", attrs: (class: "def-body"), body)
    })
  } else {
    block(
      width: 100%,
      inset: (x: 10pt, y: 8pt),
      radius: 4pt,
      fill: rgb("#f1f4ee"),
      stroke: (left: 2pt + rgb("#7a9a6f")),
      {
        text(weight: "bold", style: "italic")[#term]
        parbreak()
        text(size: 0.95em, body)
      },
    )
  }
}

// A "bookmark": a marker that the article pauses here while you go explore a
// related topic (a WIP / continuation flag). `body` says where you're headed (and
// can hold a #link to the related post); `date` is shown in the header. Web ->
// <div class="bookmark">; standalone PDF -> a styled block.
//   #bookmark(date: "24 Jun 2026")[
//     Pausing here to first understand convolutions — see #link("/...")[this post].
//   ]
#let bookmark(body, date: none) = {
  if _input("web") == "true" {
    html.elem("div", attrs: (class: "bookmark"), {
      html.elem("p", attrs: (class: "bookmark-meta"), {
        [Bookmark — paused here]
        if date != none { [ · #date] }
      })
      html.elem("div", attrs: (class: "bookmark-body"), body)
    })
  } else {
    block(
      width: 100%,
      inset: (x: 10pt, y: 8pt),
      radius: 4pt,
      fill: rgb("#fbf3df"),
      stroke: (left: 2pt + rgb("#c99a2e")),
      {
        text(size: 0.78em, weight: "bold", fill: rgb("#9a7a1e"))[
          BOOKMARK — PAUSED HERE#if date != none [ · #date]
        ]
        parbreak()
        text(size: 0.95em, body)
      },
    )
  }
}

// Resolve a post's slug to its full URL (looked up from the manifest at build
// time), with an optional #section anchor. Lets posts cross-reference by short
// slug instead of the dated path, so links don't break if a date/path changes.
//   #post-url("informatons")                      -> "/2026/06/18/informatons.html"
//   #post-url("nn", anchor: "backpropogation")    -> ".../...#backpropogation"
#let post-url(slug, anchor: none) = {
  // build.py's metadata-bootstrap pass (read_post_meta -> `typst query`, no
  // --input) runs before /_posts.json is written, since discover_posts()
  // must evaluate every post's content to find its <post-meta> label before
  // it can build and write that very manifest. Any post using #link-post
  // gets compiled during that pass too, so reading the not-yet-written file
  // would hard-crash the whole build. Only the real web render (build.py
  // always passes --input web=true, after the manifest is written) needs the
  // resolved URL, so short-circuit otherwise.
  if _input("web") != "true" {
    return "#" + if anchor != none { anchor } else { "" }
  }
  let hits = json("/_posts.json").filter(p => p.at("slug", default: none) == slug)
  if hits.len() == 0 {
    panic("link-post: no post with slug '" + slug + "'")
  }
  hits.first().url + if anchor != none { "#" + anchor } else { "" }
}

// Link to another post by slug: #link-post("informatons")[Non-Things ...]
// Deep-link to a section: #link-post("nn", anchor: "backpropogation")[backprop]
#let link-post(slug, body, anchor: none) = link(post-url(slug, anchor: anchor), body)

// Wrap document content in <article class="paper">, applying the show rules
// that translate plain-Typst layout content into web-friendly output. The
// rules must be active where `doc` is realized, so the wrapping happens here.
// Lay content out as an SVG, rendering any math/images/figures inside it
// NATIVELY rather than re-applying the web rules (which would nest html.frame
// calls and crash — e.g. math labels inside a diagram).
#let _framed(it) = html.elem("div", attrs: (class: "math-block"), html.frame({
  show math.equation: e => e
  show image: e => e
  show figure: e => e
  it
}))

// Plain text of a heading body, so we can slugify it into an anchor id.
#let _text-of(it) = {
  if type(it) == str { it } else if it.func() == text { it.text } else if it.has(
    "children",
  ) { it.children.map(_text-of).join("") } else if it.has("body") {
    _text-of(it.body)
  } else { "" }
}

// "The Chain Rule" -> "the-chain-rule" (matches the #fragment in a link).
#let _slug(it) = {
  let s = lower(_text-of(it))
  s = s.replace(regex("[^a-z0-9\s-]"), "").trim()
  s.replace(regex("[\s-]+"), "-").trim("-")
}

// A table of contents, auto-built from the article's own headings (levels 2-3),
// linking to each section's anchor (the same #slug the heading rule emits). Drop
// `#toc()` near the top of a post. On the web it's a <nav class="toc-box">; in
// standalone PDF it falls back to Typst's native outline().
#let toc(title: "Contents") = {
  if _input("web") != "true" {
    return outline(title: title, depth: 3, indent: auto)
  }
  context {
    // Nest headings (any depth, h2 > h3 > h4 > ...) using a stack keyed by
    // heading level: a heading closes out every open node at its level or
    // deeper, then attaches to whatever's left open above it.
    let roots = ()
    let stack = ()
    for h in query(heading).filter(h => h.level >= 2) {
      while stack.len() > 0 and stack.last().level >= h.level {
        let popped = stack.pop()
        let node = (h: popped.h, children: popped.children)
        if stack.len() > 0 {
          let parent = stack.pop()
          parent.children.push(node)
          stack.push(parent)
        } else {
          roots.push(node)
        }
      }
      stack.push((level: h.level, h: h, children: ()))
    }
    while stack.len() > 0 {
      let popped = stack.pop()
      let node = (h: popped.h, children: popped.children)
      if stack.len() > 0 {
        let parent = stack.pop()
        parent.children.push(node)
        stack.push(parent)
      } else {
        roots.push(node)
      }
    }
    if roots.len() == 0 { return }
    let link-to(h) = html.elem("a", attrs: (href: "#" + _slug(h.body)), h.body)
    let render(items) = html.elem("ol", items.map(it => html.elem("li", {
      link-to(it.h)
      if it.children.len() > 0 { render(it.children) }
    })).join())
    html.elem("nav", attrs: (class: "toc-box"), {
      html.elem("p", attrs: (class: "toc-title"))[#title]
      render(roots)
    })
  }
}

// An "update": a note that a specific article has been updated. `body` describes
// what changed; `date` is shown in the header. Web -> <div class="update-note">;
// standalone PDF -> a styled block.
//   #update(date: "30 Jun 2026")[
//     Added a new section on backpropagation.
//   ]
#let update(body, date: none) = {
  if _input("web") == "true" {
    html.elem("div", attrs: (class: "update-note"), {
      html.elem("p", attrs: (class: "update-meta"), {
        [Update]
        if date != none { [ · #date] }
      })
      html.elem("div", attrs: (class: "update-body"), body)
    })
  } else {
    block(
      width: 100%,
      inset: (x: 10pt, y: 8pt),
      radius: 4pt,
      fill: rgb("#eef5ee"),
      stroke: (left: 2pt + rgb("#6a9a6a")),
      {
        text(size: 0.78em, weight: "bold", fill: rgb("#4a7a4a"))[
          UPDATE#if date != none [ · #date]
        ]
        parbreak()
        text(size: 0.95em, body)
      },
    )
  }
}


#let _article(head, doc) = {
  // Give every heading an id so other pages (and a table of contents) can
  // deep-link to a section, e.g. /…/Automatic-Differentiation.html#the-chain-rule
  show heading: it => html.elem(
    "h" + str(it.level),
    attrs: (id: _slug(it.body)),
    it.body,
  )
  show math.equation: it => if it.block { _framed(it) } else { html.frame(it) }
  // Anything visual that HTML export can't represent (images, and drawn
  // diagrams from diagraph/fletcher/cetz/...) is embedded as an SVG by wrapping
  // it in #figure(...). We deliberately do NOT hook `image` directly: diagrams
  // build their own internal images, and reframing those crashes the layout.
  // So the convention is: put images and diagrams in a #figure(...).
  show figure: _framed
  html.elem("article", attrs: (class: "paper"), {
    head
    doc
  })
}

// A plain content page (the home page).
#let web-page(doc) = {
  nav(_input("current"))
  _article([], doc)
}

// Featured articles for the home page: any post whose <post-meta> sets
// `featured: true`, newest first (manifest order). Rendered through `aside` so
// it floats into the right margin with the sidenote styling (and folds inline
// on narrow screens). Renders nothing if none are marked. Uses native
// list/link so index.typ still compiles to PDF on its own.
// Call it from index.typ: `#import "/lib/web.typ": web-featured`.
#let web-featured(title: "author picks") = {
  let posts = json("/_posts.json").filter(p => p.at("featured", default: false))
  if posts.len() == 0 { return }
  aside({
    strong(title)
    list(..posts.map(p => link(p.url)[#p.title]))
  })
}

// A photo for the home page. On the web it emits a real <img> (class for CSS
// placement) so the browser loads the JPEG directly; standalone PDF falls back
// to a right-aligned native image. `src` is a site-absolute path under /assets.
#let home-photo(src, alt: "", caption: none) = {
  if _input("web") == "true" {
    html.elem("figure", attrs: (class: "home-photo"), {
      html.elem("img", attrs: (src: src, alt: alt))
      if caption != none { html.elem("figcaption", caption) }
    })
  } else {
    align(right, image(src, width: 200pt))
  }
}

// An article: title + byline (from --input) above the body, followed by an
// auto-generated table of contents built from the article's own headings (see
// `toc`). No post needs to call `#toc()` itself; it renders nothing for posts
// with no level-2+ headings.
#let web-post(doc) = {
  nav(_input("current"))
  _article(
    {
      html.elem("h1", attrs: (class: "title"))[#_input("title")]
      if _input("wip") != "" {
        html.elem("p", attrs: (class: "wip-badge"))[Work in progress]
      }
      html.elem("p", attrs: (class: "byline"))[#_input("date") · #_input("author")]
      toc()
    },
    doc,
  )
}

// Which index a post belongs to. Set "section" explicitly in pages.json
// Which index a post belongs to ("notes"/"thoughts"); set by build.py.
#let _section(p) = p.at("section", default: "thoughts")

#let _link-item(p) = html.elem("li", {
  html.elem("a", attrs: (href: p.url))[#p.title - #p.date_list]
  // Optional one-line blurb from the post's <post-meta> `description`.
  if "description" in p {
    html.elem("span", attrs: (class: "desc"), emph(p.description))
  }
})

// Build a nested tree from posts' `categories` (the folder chain under the
// section). A post with no categories is standalone and lands at the root.
//   node = (posts: (..), subs: (name: node, ..))
#let _tree-insert(node, cats, post) = {
  if cats.len() == 0 {
    return (posts: node.posts + (post,), subs: node.subs)
  }
  let head = cats.first()
  let child = node.subs.at(head, default: (posts: (), subs: (:)))
  let subs = node.subs
  subs.insert(head, _tree-insert(child, cats.slice(1), post))
  (posts: node.posts, subs: subs)
}

#let _build-tree(posts) = {
  let root = (posts: (), subs: (:))
  for p in posts {
    root = _tree-insert(root, p.at("categories", default: ()), p)
  }
  root
}

// Render a node's children as <li>s: each subdirectory is a category bullet with
// its own nested <ul> (recursively); standalone posts are plain leaf bullets.
// Directories first (newest-post-first order), then standalone posts.
#let _render-node(node) = {
  for (name, child) in node.subs {
    html.elem("li", {
      html.elem("strong")[#name]
      html.elem("ul", _render-node(child))
    })
  }
  for p in node.posts {
    _link-item(p)
  }
}

// An index page: every folder under the section becomes a (possibly nested)
// category bullet; posts directly in the section folder are standalone bullets.
// The post listing for the current section (read from --input by build.py),
// grouped by topic folder. Call this from a section's own index.typ — e.g.
// posts/notes/index.typ — to drop the list in wherever the author wants it:
//   #import "../../lib/web.typ": section-list
//   = Notes
//   #section-list()
#let section-list() = {
  let section = _input("section")
  let posts = json("/_posts.json").filter(p => _section(p) == section)
  html.elem("ul", attrs: (class: "toc"), _render-node(_build-tree(posts)))
}

// The Interlinked page: an interactive force-directed graph of how posts
// reference each other. The graph data (/_graph.json) and the renderer
// (/assets/js/interlinked.js) are produced/served by build.py; this just lays
// out the container + script. (Web-only; never compiled to PDF.)
#let web-interlinked() = {
  nav(_input("current"))
  html.elem("div", attrs: (id: "graph", class: "graph-wrap"))[]
  html.elem(
    "script",
    attrs: (src: "/assets/js/interlinked.js", defer: "defer"),
  )[]
}
