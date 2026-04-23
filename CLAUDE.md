# terminaltom.com — Project Context

This is a personal website and blog for terminaltom.com, built with Hugo and a fully custom theme. It serves as a CV, project portfolio, and blog. Posts are written in Markdown and cross-posted to Dev.to and Medium, with terminaltom.com as the canonical source.

---

## Stack

- **Static site generator**: Hugo
- **Theme**: Custom theme located at `themes/terminal/` — no third-party theme
- **Serving**: Nginx (inside Docker container) proxied by host Nginx on EC2
- **TLS**: Handled by host Nginx/Certbot — already configured, do not touch
- **Fonts**: Self-hosted in `themes/terminal/static/fonts/` (VT323, Share Tech Mono) — no Google Fonts CDN

---

## Deployment

The site runs as a Docker container on an AWS EC2 instance alongside an existing app at `terminaltom.com/go-fish`.

```
terminaltom.com/          → Hugo container (port 8080, localhost only)
terminaltom.com/go-fish   → existing separate container (do not touch)
```

**Host Nginx** terminates TLS and proxies to the Hugo container. See `nginx-host.conf` for the snippet that lives inside the existing `server { }` block. Do not create a new server block — add to the existing one only.

**Container Nginx** (`nginx-container.conf`) serves the static files inside the container on port 80.

### Deploy commands

```bash
# First deploy
docker compose up -d --build

# Subsequent updates
git pull
docker compose up -d --build
```

Hugo is built inside the Docker container (multi-stage Dockerfile) — you do not need Hugo installed on the EC2 instance.

### Local development

Hugo must be installed locally for `hugo server`:

```bash
hugo server -D        # serves at http://localhost:1313 with draft posts visible
hugo --minify         # production build to public/
```

---

## Theme structure

```
themes/terminal/
├── layouts/
│   ├── index.html              # Homepage
│   ├── _default/
│   │   ├── baseof.html         # Base shell (header, nav, footer) for all pages
│   │   ├── list.html           # Blog/project listing pages
│   │   └── single.html        # Individual post/page
│   └── cv/
│       └── list.html           # CV page — structured HTML rows, not Markdown
└── static/
    ├── css/style.css           # All styles — single stylesheet
    └── fonts/                  # Self-hosted VT323 and Share Tech Mono
```

---

## CSS architecture

**Single stylesheet**: `themes/terminal/static/css/style.css`

### Custom properties (CSS variables)

All colours and font sizes are defined as variables in `:root`. Always use variables rather than hardcoded values.

**Colour variables** (dark mode terminal palette):
```css
--bg, --bg-off, --bg-hover  /* page and surface backgrounds */
--border, --border-light
--text, --text-muted, --text-faint
--accent, --accent-hover
--tag-bg, --tag-border
```

**Type scale** (modular scale, 1.2 ratio, rem-based):
```css
--text-xs     /* ~11px — tags, meta, faint labels */
--text-sm     /* ~13px — excerpts, secondary content */
--text-base   /* ~1rem  — body, nav */
--text-lg     /* ~19px — post titles in listings */
--text-xl     /* ~23px — subheadings */
--text-2xl    /* ~32px — post page headings */
--text-3xl    /* ~52px — site title */
```

Always use type scale variables for `font-size`, never hardcoded `px` values (except borders and hairlines).

**Font stacks**:
```css
--mono:     'Share Tech Mono', 'Courier New', monospace   /* body text */
--display:  'VT323', 'Courier New', monospace             /* title/headings */
```

### Global font scaling

Base size set on `html` with responsive breakpoints:
```css
html { font-size: 18px; }
```

Because type scale uses `rem`, all text scales automatically with these breakpoints.

### Key classes

| Class | Purpose |
|---|---|
| `.site-title` | VT323 display font, `--text-3xl`, glow `text-shadow`, `::after` blink cursor |
| `.site-subtitle` | `display: block`, `--text-base` — always on new line below title |
| `.site-nav a` | Mono font, bracket notation `[home]`, border on hover/active (accent-coloured) |
| `.prompt-line` | Faint colour, terminal command text — no `::before` prefix |
| `.section-label` | `// ` prefix via `::before`, uppercase, letter-spaced — section headings |
| `.post-entry` | Blog post row — left accent border on hover, full card clickable via `.post-entry-link` |
| `.post-entry-link` | Wraps entire post card as `<a>` — handles navigation, hover colour on `.post-title` |
| `.header-rule` | Standalone `<div>` that renders the border below the header — hidden during boot animation on homepage |
| `.content-block` | Homepage intro prose only — not reused elsewhere |
| `.home-intro` | Wraps prompt and `.content-block` |
| `.cv-row` | Two-column grid (`110px 1fr`) for CV entries |
| `.tag` | Inline tag pill — border, small font, accent colour on hover |
| `body::before` | Fixed vignette overlay — `radial-gradient`, `pointer-events: none`, `z-index: 9998` |
| `body::after` | Fixed scanline overlay — `repeating-linear-gradient`, `pointer-events: none`, `z-index: 9999` |
| `.boot-hidden` | `opacity: 0`, used to hide elements before boot animation reveals them |
| `.boot-visible` | Triggers `fadeIn` animation — added by `reveal()` in boot script |
| `.nav-locked` | Applied to `site-nav` during boot — dims nav and disables pointer events |

### Site title cursor

The blinking cursor is a CSS `::after` pseudo-element on `.site-title`, using a non-breaking space (`\00a0`) with `background-color: currentColor` so its width comes from VT323's own space metrics — consistent across platforms without depending on a specific Unicode glyph:
```css
.site-title::after {
  content: '\00a0';
  font-family: var(--display);
  font-size: var(--text-3xl);
  background-color: currentColor;
  vertical-align: baseline;
  animation: blink 1s step-end infinite;
}
@keyframes blink { 50% { opacity: 0; } }
```

### Boot animation

A sequential reveal animation runs on the homepage for first-time visitors. The script lives in `baseof.html` just before `</body>`. The sequence is:

1. `whoami` prompt types out
2. 500ms pause — title fades in and `TERMINAL TOM` types out character by character
3. 500ms pause — everything else fades in together (subtitle, nav, rule, about prompt, about content, recent posts, footer)

`localStorage` keys control behaviour:
- `tt-visited` — set on first load; animation skips on return visits
- `tt-boot-override` — `'on'` always animates, `'off'` never animates, absent = auto

A `[boot: auto/always/never]` toggle in the footer cycles between these states.

The animation only runs on the homepage (detected via presence of `#about-content`). Elements on inner pages are never hidden. On the homepage, `boot-hidden` is applied via `{{ if .IsHome }}` conditionals in `baseof.html` and directly in `index.html`.

---

## Content

```
content/
├── _index.md           # Homepage about blurb (Markdown prose)
├── posts/              # Blog posts — one .md file per post
├── projects/           # Project write-ups — one .md file per project
└── cv/
    └── _index.md       # Stub only — CV content lives in the layout template
```

### Post front matter

```yaml
---
title: "Post Title"
date: 2025-04-20
tags: ["tag1", "tag2"]
description: "One sentence for listings and meta tags."
canonicalUrl: "https://terminaltom.com/posts/slug/"  # set when cross-posting
draft: false
---
```

### CV

The CV content lives directly in `themes/terminal/layouts/cv/list.html` as structured HTML — not in a Markdown file. This gives precise control over the two-column layout. Edit the HTML rows there to update experience, skills, and education. `content/cv/_index.md` is a stub that just sets `type: cv` and `layout: cv`.

---

## Cross-posting workflow

1. Write and publish on terminaltom.com first.
2. **Dev.to**: paste Markdown, set canonical URL to `https://terminaltom.com/posts/<slug>/` in post settings.
3. **Medium**: use the import-from-URL feature — Medium sets the canonical automatically.

The `canonicalUrl` front matter field is rendered as `<link rel="canonical">` in the base template, which is useful if a cross-posted version needs to point back explicitly.

---

## Hugo config (`hugo.toml`)

```toml
baseURL = "https://terminaltom.com/"
languageCode = "en-gb"
title = "Terminal Tom"
theme = "terminal"
paginate = 10

[params]
  subtitle = "engineer / tinkerer / documenter of things"
  email = "tom@terminaltom.com"
  github = "https://github.com/terminaltom"

[taxonomies]
  tag = "tags"
```

---

## Things to leave alone

- **`/go-fish` app and its container** — separate project, separate container, separate Nginx location block. Do not modify.
- **Host Nginx TLS config** — Certbot-managed, already working.
- **`nginx-host.conf`** — documents the snippet inside the host Nginx server block. The `location /` block proxies to the Hugo container; the `location /go-fish` block is the existing app.
