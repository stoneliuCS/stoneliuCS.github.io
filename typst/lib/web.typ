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
// still compiles to PDF on its own. Import it in a post (posts/ is nested, so
// use a path relative to the post — this resolves in the editor's LSP too,
// which doesn't know build.py's --root):
//   #import "../lib/web.typ": aside
#let aside(body) = {
  if _input("web") == "true" {
    html.elem("aside", attrs: (class: "sidenote"), body)
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

// Draw a fully-connected neural net. `layers` is a list whose entries are
// either an integer (draw that many neurons) or a dict (head: h, tail: t) that
// abbreviates a big layer as h neurons, a vertical ellipsis, then t neurons --
// "dot notation" for layers too large to draw in full (e.g. the 784 inputs of
// an MNIST net). Put the call inside a #figure(...) so the build embeds it as SVG.
//
//   #import "../lib/web.typ": draw-net   // relative path from a post in posts/
//   #figure(draw-net((3, 4, 2)))
//   #figure(draw-net(((head: 3, tail: 1), 16, 16, 10)))   // 784 -> 16 -> 16 -> 10
//
// Optional labels (indexed by VISIBLE neuron, top to bottom; the ellipsis is
// not a neuron and takes no index):
//   node-labels: an array parallel to `layers`; each entry is an array of
//     content drawn inside that layer's neurons. Missing entries are skipped.
//   edge-labels: a function (i, a, b) => content, called for the edge from
//     visible node `a` of layer `i` to visible node `b` of layer `i + 1`.
//
//   #figure(draw-net(
//     (3, 1),
//     node-labels: (($x_1$, $x_2$, $x_3$), ($y$,)),
//     edge-labels: (i, a, b) => $w_#(a + 1)$,
//   ))
#let draw-net(
  layers,
  node-labels: none,
  edge-labels: none,
  x-gap: 2.6,
  y-gap: 1.3,
  r: 0.45,
) = {
  import "@preview/cetz:0.3.4": canvas, draw
  canvas({
    import draw: *

    // Normalize each layer into an ordered list of slot kinds. An integer n is
    // n "node" slots; a dict (head: h, tail: t) is h nodes, a "dots" slot, then
    // t nodes (defaults head: 3, tail: 1).
    let slots-of(layer) = {
      if type(layer) == int {
        range(layer).map(_ => "node")
      } else {
        let head = layer.at("head", default: 3)
        let tail = layer.at("tail", default: 1)
        range(head).map(_ => "node") + ("dots",) + range(tail).map(_ => "node")
      }
    }

    // Place every slot at a centered (x, y), keeping its kind.
    let placed = ()
    for (i, layer) in layers.enumerate() {
      let slots = slots-of(layer)
      let offset = (slots.len() - 1) / 2
      let col = ()
      for (j, kind) in slots.enumerate() {
        col.push((pos: (i * x-gap, (offset - j) * y-gap), kind: kind))
      }
      placed.push(col)
    }

    // Visible-neuron positions per layer (ellipsis slots excluded), top to bottom.
    let nodes = ()
    for col in placed {
      let ps = ()
      for s in col {
        if s.kind == "node" { ps.push(s.pos) }
      }
      nodes.push(ps)
    }

    // Fully-connected edges between visible neurons (drawn first so neurons sit
    // on top), plus any weight labels nudged toward the source end.
    for i in range(nodes.len() - 1) {
      for (a, pa) in nodes.at(i).enumerate() {
        for (b, pb) in nodes.at(i + 1).enumerate() {
          line(pa, pb, stroke: 0.5pt + gray)
          if edge-labels != none {
            let lbl = (edge-labels)(i, a, b)
            if lbl != none {
              let mx = pa.at(0) + (pb.at(0) - pa.at(0)) * 0.35
              let my = pa.at(1) + (pb.at(1) - pa.at(1)) * 0.35
              content((mx, my), box(fill: white, inset: 1pt, lbl))
            }
          }
        }
      }
    }

    // Draw slots: neurons as circles (+ optional labels), ellipsis as a ⋮.
    for (i, col) in placed.enumerate() {
      let node-idx = 0
      for s in col {
        if s.kind == "dots" {
          content(s.pos, text(size: 1.3em, $dots.v$))
        } else {
          circle(s.pos, radius: r, fill: white, stroke: black)
          if node-labels != none {
            let lbl = node-labels.at(i, default: ()).at(node-idx, default: none)
            if lbl != none { content(s.pos, lbl) }
          }
          node-idx += 1
        }
      }
    }
  })
}

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
#let web-featured(title: "Featured Articles") = {
  let posts = json("/_posts.json").filter(p => p.at("featured", default: false))
  if posts.len() == 0 { return }
  aside({
    strong(title)
    list(..posts.map(p => link(p.url)[#p.title]))
  })
}

// An article: title + byline (from --input) above the body.
#let web-post(doc) = {
  nav(_input("current"))
  _article(
    {
      html.elem("h1", attrs: (class: "title"))[#_input("title")]
      // The " · N min read" suffix is appended to this byline by build.py, since
      // it depends on the rendered content.
      html.elem("p", attrs: (class: "byline"), {
        let modified = _input("modified")
        _input("date")
        if modified != "" { [ · updated #modified] }
        [ · ]
        _input("author")
      })
    },
    doc,
  )
}

// Which index a post belongs to. Set "section" explicitly in pages.json
// ("thoughts" or "notes"); if it's missing we fall back to the old rule
// (a "topic" means it's a note) so existing entries keep working.
#let _section(p) = p.at("section", default: if "topic" in p { "notes" } else { "thoughts" })

// Heading a note nests under on the Notes index. Notes without an explicit
// "topic" collect under "Misc" rather than vanishing.
#let _topic-of(p) = p.at("topic", default: "Misc")

#let _link-item(p) = html.elem("li", {
  html.elem("a", attrs: (href: p.url))[#p.title - #p.date_list]
  // Optional one-line blurb from the post's <post-meta> `description`.
  if "description" in p {
    html.elem("span", attrs: (class: "desc"), emph(p.description))
  }
})

// The Thoughts index: standalone takes — posts in section "thoughts".
#let web-thoughts() = {
  nav(_input("current"))
  html.elem("h1", attrs: (class: "underlined"))[Thoughts]
  html.elem("ul", attrs: (class: "toc"), {
    for p in json("/_posts.json").filter(p => _section(p) == "thoughts") {
      _link-item(p)
    }
  })
}

// The Notes index: posts in section "notes", grouped by topic
// (e.g. Deep Learning, Professional).
#let web-notes() = {
  let notes = json("/_posts.json").filter(p => _section(p) == "notes")

  let topic-names = ()
  for p in notes {
    let t = _topic-of(p)
    if not topic-names.contains(t) {
      topic-names.push(t)
    }
  }

  nav(_input("current"))
  html.elem("h1", attrs: (class: "underlined"))[Notes]
  html.elem("ul", attrs: (class: "toc"), {
    for t in topic-names {
      html.elem("li", {
        html.elem("strong")[#t]
        html.elem("ul", {
          for p in notes.filter(p => _topic-of(p) == t) {
            _link-item(p)
          }
        })
      })
    }
  })
}
