# Portfolio

A digital book about me, written entirely in [Typst](https://typst.app) and
compiled to static HTML.

## Structure

```
typst/
  pages.json      manifest of every page/post (title, output path, dates)
  lib/template.typ  shared layout: nav, page + post wrappers
  index.typ       home page
  thoughts.typ    post index (reads pages.json)
  posts/*.typ     blog posts
  assets/         css + images, copied verbatim into _site
build.py          compiles each Typst page to HTML and writes _site/
```

## Build & preview

```
make build    # compile typst/ -> _site/
make serve    # build, then serve _site at http://localhost:8000
```

Requires [Typst](https://github.com/typst/typst) 0.14+ and Python 3.

## Adding a post

1. Add `typst/posts/your-post.typ` starting with:

   ```typst
   #import "/lib/template.typ": post
   #show: post.with(title: "Your Title", date: "16 Jun 2026", author: "Stone Liu")
   ```

2. Register it at the top of the `"posts"` array in `typst/pages.json`
   (newest first) with its `out`/`url`, `title`, and the two date strings.

Math (`$...$`) and diagrams render automatically (laid out as inline SVG via
`html.frame`).

## Deploy

Pushing to `main` triggers `.github/workflows/deploy.yml`, which installs
Typst, runs `build.py`, and publishes `_site` to GitHub Pages.
