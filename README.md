<p align="center">
  <img src="assets/icon.png" width="128" height="128" alt="Pastdown Icon">
</p>

<h1 align="center">Pastdown</h1>

<p align="center">A lightweight macOS menu bar clipboard manager built with SwiftUI.</p>

<p align="center">
  <a href="#features">English</a> · <a href="#功能介绍">中文</a>
</p>

Pastdown lives in your menu bar, silently monitoring your clipboard and keeping a searchable history of everything you copy — text, images, files, HTML, colors, and more.

## Features

- **Menu Bar App** — Runs quietly in the menu bar, always one click away
- **Auto-Save** — Automatically captures clipboard changes in the background
- **Multi-Format Support** — Handles text, URLs, images, files, HTML/RTF, and colors
- **Smart Detection** — Identifies content types from the pasteboard and stores them appropriately
- **Search** — Quickly filter your clipboard history
- **HTML to Markdown** — Converts copied HTML to readable Markdown with syntax highlighting
- **Privacy-Aware** — Skips concealed content from password managers (1Password, etc.)
- **Deduplication** — SHA256-based hashing prevents duplicate entries
- **Pin Items** — Manually pin important clips to keep them around
- **Copy in Multiple Formats** — HTML items can be copied as Markdown, plain text, raw HTML, or original rich text
- **Launch at Login** — Optional auto-start when you log in
- **Lightweight** — Local SQLite database, no cloud, no telemetry

## 功能介绍

Pastdown 是一款轻量的 macOS 菜单栏剪贴板管理工具。它静静地运行在菜单栏中，自动记录你复制的一切内容，随时可用。

- **菜单栏常驻** — 不占 Dock 位置，点击菜单栏图标即可打开
- **自动记录** — 后台监听剪贴板变化，无需手动操作
- **多格式支持** — 文本、URL、图片、文件、HTML、RTF、颜色全部支持
- **智能识别** — 自动判断剪贴板内容类型并分类存储
- **快速搜索** — 输入关键词即可过滤历史记录
- **HTML 转 Markdown** — 复制的网页内容自动转换为 Markdown，支持语法高亮预览
- **隐私保护** — 自动跳过密码管理器（如 1Password）的隐藏内容
- **去重机制** — 基于 SHA256 哈希，相同内容不会重复保存
- **置顶收藏** — 重要内容可以置顶，方便反复使用
- **多格式复制** — HTML 内容可选择以 Markdown、纯文本、原始 HTML 或富文本格式复制
- **开机自启** — 支持登录时自动启动
- **本地存储** — 数据保存在本地 SQLite 数据库，无云端同步，无数据追踪

## Screenshots

| Main View | HTML Detail | Settings |
|:---------:|:-----------:|:--------:|
| ![Main](assets/screenshot-main.png) | ![HTML Detail](assets/screenshot-html-detail.png) | ![Settings](assets/screenshot-settings.png) |

## Supported Content Types

| Type | Detection | Preview |
|------|-----------|---------|
| Text | `.string` pasteboard type | Text preview |
| URL | Auto-detected from text | Text preview |
| Image | `.png` / `.tiff` pasteboard types | Thumbnail |
| File | Finder file copy detection | Filename + icon |
| HTML | `.html` pasteboard type | Markdown rendering |
| RTF | `.rtf` pasteboard type | Text preview |
| Color | Color picker pasteboard type | Color swatch + hex |

## Requirements

- macOS 14.0 (Sonoma) or later
- Xcode 15+ to build from source

## Build

```bash
git clone https://github.com/wuwe1/pastdown.git
cd pastdown
open Pastdown.xcodeproj
```

Build and run from Xcode (⌘R).

## Architecture

```
Pastdown/
├── App/           → App entry point (MenuBarExtra)
├── Models/        → ClipboardItem, AppSettings
├── ViewModels/    → ClipboardViewModel
├── Views/         → SwiftUI views
├── Services/      → ClipboardService, ClipboardMonitor
├── Database/      → GRDB (SQLite) persistence
└── Utilities/     → HTMLToMarkdown, MarkdownHighlighter
```

## Data Storage

- **Database:** `~/.pastdown/pastdown.db` (SQLite via GRDB)
- **Settings:** UserDefaults

## License

[MIT](LICENSE)
