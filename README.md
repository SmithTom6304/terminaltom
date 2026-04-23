# terminaltom.com

Personal site — built with [Hugo](https://gohugo.io), served via Nginx + Docker on AWS EC2.

## Local development

```bash
# Install Hugo (if not already)
brew install hugo           # macOS
sudo apt install hugo       # Debian/Ubuntu

# Serve locally with live reload
hugo server -D

# Visit http://localhost:1313
```

## Writing a new post

```bash
hugo new posts/my-post-title.md
# Edit content/posts/my-post-title.md
# Set draft: false when ready to publish
```

### Front matter reference

```yaml
---
title: "Your Post Title"
date: 2025-04-20
tags: ["tag1", "tag2"]
description: "One sentence shown in listings and meta tags."
canonicalUrl: "https://terminaltom.com/posts/your-post-title/"  # optional, for cross-posts
draft: false
---
```

### Cross-posting

1. Publish here first.
2. On **Dev.to**: Settings → Publishing → set canonical URL to `https://terminaltom.com/posts/your-post/`.
3. On **Medium**: Import story → paste URL. Medium will set the canonical automatically.

This ensures search engines treat terminaltom.com as the original source.

## Deployment

### First time: set up the container on EC2

```bash
# On EC2 — clone the repo
git clone https://github.com/you/terminaltom.git
cd terminaltom

# Build and start the container
docker compose up -d --build

# Add the nginx-host.conf snippet to your existing Nginx server block
sudo nano /etc/nginx/sites-available/terminaltom.com
# (paste contents of nginx-host.conf inside the existing server { } block)

sudo nginx -t && sudo systemctl reload nginx
```

### Deploying updates

```bash
git pull
docker compose up -d --build
```

Or, if you prefer to build locally and rsync (no Docker):

```bash
hugo --minify
rsync -avz --delete public/ user@your-ec2-ip:/var/www/terminaltom/
```

## File structure

```
terminaltom/
├── hugo.toml                 # Site config
├── Dockerfile                # Multi-stage: Hugo build → Nginx serve
├── docker-compose.yml        # Runs container on port 8080 (localhost only)
├── nginx-container.conf      # Nginx config inside the container
├── nginx-host.conf           # Snippet to add to your EC2 Nginx server block
├── content/
│   ├── _index.md             # Homepage content (about blurb)
│   ├── posts/                # Blog posts (Markdown)
│   ├── projects/             # Project write-ups
│   └── cv/                   # CV page
└── themes/
    └── terminal/
        ├── layouts/          # HTML templates
        └── static/css/       # Stylesheet
```

## Updating the CV

Edit `themes/terminal/layouts/cv/list.html` directly — it's structured HTML rather than Markdown, which gives cleaner control over the two-column layout.
