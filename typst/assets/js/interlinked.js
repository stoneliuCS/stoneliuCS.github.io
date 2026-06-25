// Interactive force-directed graph of how posts reference each other.
// Data comes from /_graph.json (emitted by build.py): { nodes: [{id,title,...}],
// links: [{source,target}] } where id is each post's URL. No dependencies.
(async function () {
  const wrap = document.getElementById("graph");
  if (!wrap) return;

  let data;
  try {
    data = await (await fetch("/_graph.json")).json();
  } catch (e) {
    wrap.textContent = "Could not load the link graph.";
    return;
  }

  const byId = {};
  const nodes = data.nodes.map((n) => {
    const o = { ...n, x: 0, y: 0, vx: 0, vy: 0 };
    byId[n.id] = o;
    return o;
  });
  const links = data.links
    .map((l) => ({ source: byId[l.source], target: byId[l.target] }))
    .filter((l) => l.source && l.target);

  // adjacency (degree drives node size; neighbours drive hover highlight)
  const nbr = new Map(nodes.map((n) => [n.id, new Set()]));
  links.forEach((l) => {
    nbr.get(l.source.id).add(l.target.id);
    nbr.get(l.target.id).add(l.source.id);
  });

  const canvas = document.createElement("canvas");
  wrap.appendChild(canvas);
  const ctx = canvas.getContext("2d");
  const DPR = window.devicePixelRatio || 1;
  let W = 0,
    H = 0;
  function resize() {
    W = wrap.clientWidth;
    // fill the viewport from the graph's top down to the bottom, so zoomed/panned
    // nodes have room and rarely reach the (faded) edges
    const top = wrap.getBoundingClientRect().top;
    H = Math.max(480, Math.round(window.innerHeight - top - 16));
    canvas.width = W * DPR;
    canvas.height = H * DPR;
    canvas.style.width = W + "px";
    canvas.style.height = H + "px";
    ctx.setTransform(DPR, 0, 0, DPR, 0, 0);
  }
  resize();
  window.addEventListener("resize", resize);

  // seed nodes on a circle around the centre
  nodes.forEach((n, i) => {
    const a = (i / Math.max(1, nodes.length)) * Math.PI * 2;
    const rad = Math.min(W, H) * 0.28;
    n.x = W / 2 + Math.cos(a) * rad;
    n.y = H / 2 + Math.sin(a) * rad;
  });

  // pan / zoom
  let scale = 1,
    ox = 0,
    oy = 0;
  const toWorld = (px, py) => ({ x: (px - ox) / scale, y: (py - oy) / scale });

  // Fill/stroke for a solid (note/home) node. Notes get a stable colour per
  // topic (their first category); untopiced notes keep the default tan; home is
  // the dark root. `on` = highlighted (vs dimmed on hover).
  function noteColors(n, on, isHome) {
    if (isHome)
      return on
        ? { fill: "#8a7f55", stroke: "#5a5230" }
        : { fill: "#bcb594", stroke: "#d3cdb2" };
    const topic = (n.categories && n.categories[0]) || null;
    if (!topic)
      return on
        ? { fill: "#b3ad8e", stroke: "#6f6535" }
        : { fill: "#e2dec9", stroke: "#d3cdb2" };
    let h = 0;
    for (const ch of topic) h = (h * 31 + ch.charCodeAt(0)) % 360;
    return on
      ? { fill: `hsl(${h},36%,60%)`, stroke: `hsl(${h},42%,36%)` }
      : { fill: `hsl(${h},20%,82%)`, stroke: `hsl(${h},18%,76%)` };
  }

  const radiusOf = (n) => 5 + Math.min(9, nbr.get(n.id).size * 1.6);
  // drawn radius includes the home node's size bump (kept in sync with the loop)
  const drawRadius = (n) => radiusOf(n) + (n.section === "home" ? 4 : 0);
  function nodeAt(px, py, slop = 6) {
    const w = toWorld(px, py);
    let best = null,
      bd = Infinity;
    for (const n of nodes) {
      const d = Math.hypot(n.x - w.x, n.y - w.y);
      if (d < bd) {
        bd = d;
        best = n;
      }
    }
    return best && bd <= drawRadius(best) + slop / scale ? best : null;
  }

  let hover = null,
    drag = null,
    dragMoved = false;

  // Cluster grouping: notes by topic (first category), others by section. Same
  // group -> pulled toward a shared centroid so related posts sit together.
  const groupKey = (n) => (n.categories && n.categories[0]) || n.section;
  const groupMembers = {};
  for (const n of nodes) {
    const k = groupKey(n);
    (groupMembers[k] = groupMembers[k] || []).push(n);
  }

  function step() {
    for (let i = 0; i < nodes.length; i++) {
      for (let j = i + 1; j < nodes.length; j++) {
        const a = nodes[i],
          b = nodes[j];
        let dx = a.x - b.x,
          dy = a.y - b.y;
        let d2 = dx * dx + dy * dy || 0.01;
        const f = 2600 / d2;
        const d = Math.sqrt(d2);
        const fx = (dx / d) * f,
          fy = (dy / d) * f;
        a.vx += fx;
        a.vy += fy;
        b.vx -= fx;
        b.vy -= fy;
      }
    }
    for (const l of links) {
      const a = l.source,
        b = l.target;
      let dx = b.x - a.x,
        dy = b.y - a.y;
      const d = Math.hypot(dx, dy) || 0.01;
      const f = (d - 110) * 0.015;
      const fx = (dx / d) * f,
        fy = (dy / d) * f;
      a.vx += fx;
      a.vy += fy;
      b.vx -= fx;
      b.vy -= fy;
    }
    // clustering: pull each node toward its group's centroid
    for (const k in groupMembers) {
      const arr = groupMembers[k];
      if (arr.length < 2) continue;
      let cx = 0,
        cy = 0;
      for (const n of arr) {
        cx += n.x;
        cy += n.y;
      }
      cx /= arr.length;
      cy /= arr.length;
      for (const n of arr) {
        n.vx += (cx - n.x) * 0.04;
        n.vy += (cy - n.y) * 0.04;
      }
    }
    for (const n of nodes) {
      n.vx += (W / 2 - n.x) * 0.0015;
      n.vy += (H / 2 - n.y) * 0.0015;
      if (n === drag) continue;
      n.x += n.vx * 0.85;
      n.y += n.vy * 0.85;
      n.vx *= 0.82;
      n.vy *= 0.82;
    }
  }

  function draw() {
    ctx.clearRect(0, 0, W, H);
    ctx.save();
    ctx.translate(ox, oy);
    ctx.scale(scale, scale);
    const active = hover ? new Set([hover.id, ...nbr.get(hover.id)]) : null;

    for (const l of links) {
      const a = l.source,
        b = l.target;
      const on = !active || (active.has(a.id) && active.has(b.id));
      const col = on ? "rgba(122,111,80,0.6)" : "rgba(122,111,80,0.1)";
      const dx = b.x - a.x,
        dy = b.y - a.y;
      const len = Math.hypot(dx, dy) || 1;
      const ux = dx / len,
        uy = dy / len;
      // stop the line just outside the target node so the arrowhead is visible
      const tx = b.x - ux * (drawRadius(b) + 2),
        ty = b.y - uy * (drawRadius(b) + 2);
      ctx.strokeStyle = col;
      ctx.lineWidth = on ? 1.3 : 0.8;
      ctx.beginPath();
      ctx.moveTo(a.x, a.y);
      ctx.lineTo(tx, ty);
      ctx.stroke();
      // arrowhead at the target end: A -> B means an arrow pointing at B only
      const ah = on ? 7 : 5;
      const ang = Math.atan2(dy, dx);
      ctx.beginPath();
      ctx.moveTo(tx, ty);
      ctx.lineTo(tx - ah * Math.cos(ang - 0.42), ty - ah * Math.sin(ang - 0.42));
      ctx.lineTo(tx - ah * Math.cos(ang + 0.42), ty - ah * Math.sin(ang + 0.42));
      ctx.closePath();
      ctx.fillStyle = col;
      ctx.fill();
    }

    ctx.textAlign = "center";
    for (const n of nodes) {
      const on = !active || active.has(n.id);
      const ethereal = n.section === "thoughts";
      const isHome = n.section === "home";
      const r = drawRadius(n);

      if (ethereal) {
        // thoughts: intangible — a soft glow, translucent core, faint dashed edge
        ctx.beginPath();
        ctx.arc(n.x, n.y, r + 7, 0, Math.PI * 2);
        ctx.fillStyle = on ? "rgba(124,148,196,0.13)" : "rgba(124,148,196,0.05)";
        ctx.fill();
        ctx.beginPath();
        ctx.arc(n.x, n.y, r, 0, Math.PI * 2);
        ctx.fillStyle = on ? "rgba(124,148,196,0.42)" : "rgba(124,148,196,0.16)";
        ctx.fill();
        ctx.setLineDash([2, 3]);
        ctx.lineWidth = 1;
        ctx.strokeStyle = on ? "rgba(96,120,172,0.55)" : "rgba(96,120,172,0.18)";
        ctx.stroke();
        ctx.setLineDash([]);
      } else {
        // notes (solid) and home (the solid, darker root). Notes are tinted by
        // their topic (first category) so each topic reads as its own colour.
        const c = noteColors(n, on, isHome);
        ctx.beginPath();
        ctx.arc(n.x, n.y, r, 0, Math.PI * 2);
        ctx.fillStyle = c.fill;
        ctx.fill();
        ctx.lineWidth = isHome ? 1.6 : 1.2;
        ctx.strokeStyle = c.stroke;
        ctx.stroke();
      }

      // labels only on hover (the hovered node + its neighbours), so dense
      // clusters stay clean. The hovered node's own label is drawn last (below)
      // so it sits on top of any overlapping neighbour labels.
      if (active && active.has(n.id) && n !== hover) {
        ctx.font =
          (ethereal ? "italic " : isHome ? "600 " : "") +
          "13px et-book, Palatino, Georgia, serif";
        ctx.fillStyle = ethereal ? "#6b7c9a" : "#333";
        ctx.fillText(n.title, n.x, n.y - r - 5);
      }
    }

    // the hovered node's name takes precedence: drawn on top, with a faint
    // page-coloured backing so it stays readable over any overlapping words
    if (hover) {
      const ethereal = hover.section === "thoughts";
      const isHome = hover.section === "home";
      const r = radiusOf(hover) + (isHome ? 4 : 0);
      const tx = hover.x,
        ty = hover.y - r - 5;
      ctx.font =
        (ethereal ? "italic " : isHome ? "600 " : "") +
        "13px et-book, Palatino, Georgia, serif";
      const tw = ctx.measureText(hover.title).width;
      ctx.fillStyle = "rgba(255,253,243,0.85)";
      ctx.fillRect(tx - tw / 2 - 3, ty - 12, tw + 6, 16);
      ctx.fillStyle = ethereal ? "#6b7c9a" : "#222";
      ctx.fillText(hover.title, tx, ty);
    }
    ctx.restore();
  }

  (function frame() {
    step();
    draw();
    requestAnimationFrame(frame);
  })();

  const rel = (e) => {
    const r = canvas.getBoundingClientRect();
    return [e.clientX - r.left, e.clientY - r.top];
  };
  let pan = null; // {sx, sy, ox, oy} when dragging empty space
  canvas.addEventListener("mousemove", (e) => {
    const [px, py] = rel(e);
    if (drag) {
      const w = toWorld(px, py);
      drag.x = w.x;
      drag.y = w.y;
      drag.vx = drag.vy = 0;
      dragMoved = true;
    } else if (pan) {
      ox = pan.ox + (px - pan.sx); // drag empty space -> pan the whole graph
      oy = pan.oy + (py - pan.sy);
      canvas.style.cursor = "grabbing";
    } else {
      hover = nodeAt(px, py);
      canvas.style.cursor = hover ? "pointer" : "grab";
    }
  });
  canvas.addEventListener("mousedown", (e) => {
    const [px, py] = rel(e);
    const n = nodeAt(px, py);
    if (n) {
      drag = n; // grab a node
      dragMoved = false;
    } else {
      pan = { sx: px, sy: py, ox, oy }; // grab the canvas
      canvas.style.cursor = "grabbing";
    }
  });
  window.addEventListener("mouseup", () => {
    if (drag && !dragMoved) window.location.href = drag.id; // click node = open post
    drag = null;
    pan = null;
  });
  canvas.addEventListener(
    "wheel",
    (e) => {
      e.preventDefault();
      const [px, py] = rel(e);
      const f = Math.exp(-e.deltaY * 0.001);
      const nx = (px - ox) / scale,
        ny = (py - oy) / scale;
      scale = Math.max(0.3, Math.min(3, scale * f));
      ox = px - nx * scale;
      oy = py - ny * scale;
    },
    { passive: false }
  );

  // ---- touch (mobile): 1 finger drags a node / pans; 2 fingers pinch-zoom;
  //      a tap selects a node (reveals its label) then a second tap opens it.
  let panMoved = false,
    pinch = null;
  const tpt = (t) => {
    const r = canvas.getBoundingClientRect();
    return [t.clientX - r.left, t.clientY - r.top];
  };
  canvas.addEventListener(
    "touchstart",
    (e) => {
      e.preventDefault();
      if (e.touches.length === 2) {
        drag = pan = null;
        const [ax, ay] = tpt(e.touches[0]);
        const [bx, by] = tpt(e.touches[1]);
        pinch = {
          d: Math.hypot(ax - bx, ay - by) || 1,
          mx: (ax + bx) / 2,
          my: (ay + by) / 2,
          scale,
          ox,
          oy,
        };
      } else if (e.touches.length === 1) {
        const [px, py] = tpt(e.touches[0]);
        const n = nodeAt(px, py, 18); // generous finger target
        if (n) {
          drag = n;
          dragMoved = false;
        } else {
          pan = { sx: px, sy: py, ox, oy };
          panMoved = false;
        }
      }
    },
    { passive: false }
  );
  canvas.addEventListener(
    "touchmove",
    (e) => {
      e.preventDefault();
      if (pinch && e.touches.length === 2) {
        const [ax, ay] = tpt(e.touches[0]);
        const [bx, by] = tpt(e.touches[1]);
        const d = Math.hypot(ax - bx, ay - by) || 1;
        const wx = (pinch.mx - pinch.ox) / pinch.scale;
        const wy = (pinch.my - pinch.oy) / pinch.scale;
        scale = Math.max(0.3, Math.min(3, pinch.scale * (d / pinch.d)));
        ox = pinch.mx - wx * scale;
        oy = pinch.my - wy * scale;
      } else if (drag && e.touches.length === 1) {
        const w = toWorld(...tpt(e.touches[0]));
        drag.x = w.x;
        drag.y = w.y;
        drag.vx = drag.vy = 0;
        dragMoved = true;
      } else if (pan && e.touches.length === 1) {
        const [px, py] = tpt(e.touches[0]);
        ox = pan.ox + (px - pan.sx);
        oy = pan.oy + (py - pan.sy);
        panMoved = true;
      }
    },
    { passive: false }
  );
  canvas.addEventListener("touchend", (e) => {
    if (e.touches.length < 2) pinch = null;
    if (e.touches.length === 0) {
      if (drag && !dragMoved) {
        if (hover === drag) window.location.href = drag.id; // 2nd tap opens
        else hover = drag; // 1st tap selects (shows label + links)
      } else if (pan && !panMoved) {
        hover = null; // tap empty space clears selection
      }
      drag = pan = null;
    }
  });
})();
