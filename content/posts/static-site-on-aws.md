---
title: "Setting up a static site on AWS"
date: 2025-04-10
tags: ["aws", "hugo", "devops"]
description: "Notes on getting Hugo running, pointing a domain at EC2, and keeping the whole thing under $1/month in hosting costs."
---

A quick write-up of how I set up this site — partly as documentation for future me, partly in case it's useful to anyone else.

## Why Hugo

I wanted something I could write in plain Markdown, build to static files, and deploy without a runtime. Hugo fits that exactly. It's a single binary, builds in milliseconds, and the output is just HTML and CSS.

## The build

```bash
hugo new site terminaltom
cd terminaltom
hugo new posts/first-post.md
hugo --minify
```

The `public/` directory is everything you need to serve.

## Deployment

Since I already had an EC2 instance running Nginx, I just synced the output there:

```bash
rsync -avz --delete public/ user@my-ec2:/var/www/terminaltom/
```

Added a new `server` block to Nginx, reloaded, done. TLS was already handled by Certbot.

## Cost

The EC2 instance was already running. Adding a static site to it costs nothing extra beyond the domain renewal (~£10/year).
