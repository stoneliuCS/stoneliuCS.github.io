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

#let _article(head, doc) = {
  show heading: it => html.elem("h" + str(it.level), it.body)
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

// An article: title + byline (from --input) above the body.
#let web-post(doc) = {
  nav(_input("current"))
  _article(
    {
      html.elem("h1", attrs: (class: "title"))[#_input("title")]
      html.elem("p", attrs: (class: "byline"))[#_input("date") · #_input("author")]
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

#let _link-item(p) = html.elem(
  "li",
  html.elem("a", attrs: (href: p.url))[#p.title - #p.date_list],
)

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
