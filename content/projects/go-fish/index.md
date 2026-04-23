---
title: "go-fish"
date: 2025-01-15
tags: ["go", "web", "game"]
description: "A web-based card game written in Go. Deployed at terminaltom.com/go-fish."
---

A terminal-based implementation of the card game Go Fish, written in Rust with a WebSocket backend. 
The game state lives server-side; a TUI client written in [Ratatui](https://github.com/ratatui/ratatui) 
can be used either in your terminal or in the browser as a WASM target.

Live at [terminaltom.com/go-fish](https://terminaltom.com/go-fish).

![A screen grab of the go-fish tui client](go-fish-tui.png)
![A screen grab of a running go fish game](go-fish-game.png)
