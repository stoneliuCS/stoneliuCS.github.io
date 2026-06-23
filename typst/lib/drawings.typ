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
