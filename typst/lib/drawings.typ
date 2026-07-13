// Reusable CeTZ drawing helpers (diagrams, not page/article chrome — that lives
// in web.typ). Each returns a self-contained `cetz.canvas(...)`; put the call
// inside a #figure(...) so build.py embeds it as SVG. Import with a path RELATIVE
// to the post (so the editor LSP resolves it too); the number of `../` depends on
// folder depth:
//   posts/<section>/<file>.typ          -> #import "../../lib/drawings.typ": draw-net
//   posts/<section>/<topic>/<file>.typ  -> #import "../../../lib/drawings.typ": draw-net

// Draw a fully-connected neural net. `layers` is a list whose entries are
// either an integer (draw that many neurons) or a dict (head: h, tail: t) that
// abbreviates a big layer as h neurons, a vertical ellipsis, then t neurons --
// "dot notation" for layers too large to draw in full (e.g. the 784 inputs of
// an MNIST net).
//
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

// Draw one or more rows of boxed numbers, stacked vertically. Each row may be
// shifted horizontally by `offset` cells, so columns line up across rows --
// useful for visualizing a convolution (flip one array and slide it). `rows` is
// a list of dicts: (values: (..), offset: <int, default 0>, fill: <color>,
// label: <content shown to the left of the row>).
//   #figure(draw-arrays((
//     (values: (1, 2, 3, 4, 5, 6)),
//     (values: (6, 5, 4, 3, 2, 1), offset: 2, fill: rgb("#eef2f7")),
//   )))
#let draw-arrays(rows, cell: 0.9, gap: 0.14) = {
  import "@preview/cetz:0.3.4": canvas, draw
  let step = cell + gap
  canvas({
    import draw: *
    for (r, row) in rows.enumerate() {
      let y = -r * step // first row on top, stack downward
      let off = row.at("offset", default: 0)
      let fill = row.at("fill", default: white)
      let label = row.at("label", default: none)
      if label != none {
        content((off * step - 0.35, y + cell / 2), label, anchor: "east")
      }
      for (i, v) in row.values.enumerate() {
        let x = (off + i) * step
        rect(
          (x, y), (x + cell, y + cell),
          fill: fill, stroke: 0.7pt + black, radius: 0.06,
        )
        content((x + cell / 2, y + cell / 2), [#v])
      }
    }
  })
}

// Draw a 2D grid of cells, like a matrix: `data` is a list of rows (each a list
// of cell values), rendered with row 0 on top and shared borders (no axes). A
// cell value of `none` leaves that cell blank, so an all-`none` grid is an empty
// lattice. `highlight` is a list of (row, col) pairs to shade -- handy for
// marking a kernel / receptive field over a feature map.
//
// Returns content already wrapped in a #figure (so build.py embeds it as SVG),
// so call it directly -- no #figure(...) needed:
//   #draw-matrix((
//     (1, 0, 2),
//     (0, 3, 1),
//     (4, 1, 0),
//   ))
//   // shade the top-left 2x2 window:
//   #draw-matrix(grid-values, highlight: ((0,0), (0,1), (1,0), (1,1)))
#let draw-matrix(
  data,
  cell: 0.9,
  gap: 0,
  fill: white,
  highlight: (),
  highlight-fill: rgb("#eef2f7"),
) = {
  import "@preview/cetz:0.3.4": canvas, draw
  let step = cell + gap
  let rows = data.len()
  // Capture params into locals BEFORE `import draw: *`, which pulls cetz's own
  // `fill` function into scope and would otherwise shadow the `fill` parameter.
  let base-fill = fill
  let mark-fill = highlight-fill
  let marked = highlight
  figure(canvas({
    import draw: *
    for (r, row) in data.enumerate() {
      let y = (rows - 1 - r) * step // row 0 on top, rows stack downward
      for (c, v) in row.enumerate() {
        let x = c * step
        let cell-fill = if (r, c) in marked { mark-fill } else { base-fill }
        rect((x, y), (x + cell, y + cell), fill: cell-fill, stroke: 0.7pt + black)
        if v != none { content((x + cell / 2, y + cell / 2), [#v]) }
      }
    }
  }))
}

// Lay several matrices out in a ROW inside a single canvas (so it exports as one
// SVG and actually sits side-by-side on the web -- a #grid of separate figures
// is dropped by Typst's HTML export). `matrices` is a list of 2D data (each like
// `draw-matrix`'s `data`), drawn left-to-right, vertically centred on a common
// axis so matrices of different heights line up. `sep` is an optional symbol
// drawn in the gap between each adjacent pair (e.g. $times$ for A x B, $+$ for a
// sum); omit it for plain spacing. `highlight` is a list PARALLEL to `matrices`,
// each entry a list of (row, col) pairs to shade in that matrix.
//
// Returns content already wrapped in a #figure (so build.py embeds it as SVG),
// so call it directly -- no #figure(...) needed:
//   #draw-matrix-row(((( 1,0),(0,1)), ((2,3),(4,5))), sep: $times$)
//   #draw-matrix-row((A, B), highlight: (((0,0),), ()))  // mark A[0,0]
#let draw-matrix-row(
  matrices,
  sep: none,
  cell: 0.9,
  gap: 0.7,
  fill: white,
  highlight: (),
  highlight-fill: rgb("#eef2f7"),
) = {
  import "@preview/cetz:0.3.4": canvas, draw
  // Capture params into locals BEFORE `import draw: *` (it pulls in cetz's own
  // `fill` function, which would otherwise shadow the `fill` parameter).
  let base-fill = fill
  let mark-fill = highlight-fill
  let all-marks = highlight
  let sep-sym = sep
  let heights = matrices.map(m => m.len() * cell)
  let max-h = calc.max(..heights)
  figure(canvas({
    import draw: *
    let x = 0
    for (mi, m) in matrices.enumerate() {
      // gap (and separator) sit BEFORE every matrix except the first
      if mi > 0 {
        if sep-sym != none { content((x + gap / 2, max-h / 2), sep-sym) }
        x += gap
      }
      let rows = m.len()
      let y0 = (max-h - rows * cell) / 2 // bottom edge, so every matrix centres on max-h/2
      let marks = all-marks.at(mi, default: ())
      for (r, row) in m.enumerate() {
        let y = y0 + (rows - 1 - r) * cell
        for (c, v) in row.enumerate() {
          let cx = x + c * cell
          let cell-fill = if (r, c) in marks { mark-fill } else { base-fill }
          rect((cx, y), (cx + cell, y + cell), fill: cell-fill, stroke: 0.7pt + black)
          if v != none { content((cx + cell / 2, y + cell / 2), [#v]) }
        }
      }
      x += m.at(0).len() * cell
    }
  }))
}

// Circle layout: place every node evenly spaced around a circle, starting at the
// top and going clockwise (id order). Simple, deterministic, and always tidy --
// nodes never overlap or drift, whatever the edges are. The radius is chosen so
// adjacent nodes sit `spacing` apart. Returns a dict id -> (x, y). Internal
// helper for `draw-graph`.
#let _graph-layout(ids, spacing: 2.4) = {
  let n = ids.len()
  if n == 0 { return (:) }
  if n == 1 { return (ids.at(0): (0.0, 0.0)) }
  // adjacent chord on a circle of radius r is 2*r*sin(pi/n); solve for r.
  let r = spacing / (2 * calc.sin(calc.pi / n))
  let pos = (:)
  for (i, id) in ids.enumerate() {
    let a = calc.pi / 2 - i / n * 2 * calc.pi // start at top, go clockwise
    pos.insert(id, (calc.cos(a) * r, calc.sin(a) * r))
  }
  pos
}

// Draw a graph -- nodes and edges -- in a single cetz canvas, with the layout
// done FOR you (nodes placed evenly around a circle): you don't supply any
// positions. Minimal setup: pass just a list of edges; nodes are collected from
// them automatically.
//
// `edges` entries are either a 2-tuple ("a", "b") or a dict
// (from: "a", to: "b", label: <content>) when you want a weight/label on the
// edge. `directed: true` adds arrowheads. Node labels default to the id; override
// any via `labels` (id -> content). Pass `nodes:` only to fix the id set/order or
// to include an isolated node that no edge mentions.
//
// Returns content already wrapped in a #figure (so build.py embeds it as SVG),
// so call it directly -- no #figure(...) needed:
//   #draw-graph((("a", "b"), ("b", "c"), ("c", "a")))              // triangle
//   #draw-graph((("s", "t"), (from: "s", to: "u", label: $7$)), directed: true)
//   #draw-graph(("0", "1"), nodes: ("0", "1", "2", "3"))           // one edge + isolated
#let draw-graph(
  edges,
  nodes: none,
  directed: false,
  labels: (:),
  radius: 0.42,
  node-fill: white,
  node-stroke: black,
  edge-stroke: 0.7pt + black,
) = {
  import "@preview/cetz:0.3.4": canvas, draw
  // Tolerate a single edge passed WITHOUT the wrapping list, so both
  //   draw-graph(("0", "1"))          <- one bare edge, or (("0","1")) which is
  //                                      the same thing (redundant parens)
  //   draw-graph((from: "a", to: "b"))
  // work like the normal list form. A real edge element is an array or a dict;
  // if the first item is neither (a bare node id), the whole value is one edge.
  let edge-list = if type(edges) == dictionary {
    (edges,)
  } else if edges.len() > 0 and type(edges.at(0)) != array and type(edges.at(0)) != dictionary {
    (edges,)
  } else {
    edges
  }
  // Normalize every edge to (from, to, label).
  let norm = edge-list.map(e => if type(e) == dictionary {
    (e.from, e.to, e.at("label", default: none))
  } else {
    (e.at(0), e.at(1), e.at(2, default: none))
  })
  // Node ids: use `nodes` if given, else collect from edges in first-seen order.
  let ids = if nodes != none { nodes } else {
    let seen = ()
    for (u, v, _) in norm {
      if u not in seen { seen.push(u) }
      if v not in seen { seen.push(v) }
    }
    seen
  }
  let pos = _graph-layout(ids)
  figure(canvas({
    import draw: *
    // Edges first, so the node circles sit on top of the line ends.
    for (from, to, label) in norm {
      let pa = pos.at(from)
      let pb = pos.at(to)
      let dx = pb.at(0) - pa.at(0)
      let dy = pb.at(1) - pa.at(1)
      let d = calc.max(calc.sqrt(dx * dx + dy * dy), 0.0001)
      let (ux, uy) = (dx / d, dy / d)
      // shrink the segment to each node's rim so circles/arrowheads aren't hidden
      let start = (pa.at(0) + ux * radius, pa.at(1) + uy * radius)
      let end = (pb.at(0) - ux * radius, pb.at(1) - uy * radius)
      line(
        start, end,
        stroke: edge-stroke,
        ..if directed { (mark: (end: ">")) } else { (:) },
      )
      if label != none {
        content(
          ((start.at(0) + end.at(0)) / 2, (start.at(1) + end.at(1)) / 2),
          box(fill: white, inset: 1pt, label),
        )
      }
    }
    // Nodes on top: a circle plus its label (the id unless overridden).
    for id in ids {
      circle(pos.at(id), radius: radius, fill: node-fill, stroke: node-stroke)
      content(pos.at(id), labels.at(id, default: [#id]))
    }
  }))
}
