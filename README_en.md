# Claude Code Offline Installation Tool

> Download Claude Code binaries locally for offline installation in air-gapped environments.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Platforms](https://img.shields.io/badge/Platforms-Linux%20%7C%20macOS%20%7C%20Windows-blue.svg)](https://github.com)

**[中文](README.md)**

---

## Table of Contents

- [Features](#features)
- [Supported Platforms](#supported-platforms)
- [Directory Structure](#directory-structure)
- [Linux/macOS Usage](#linuxmacos-usage)
- [Windows Usage](#windows-usage)
- [File Description](#file-description)
- [Notes](#notes)

---

## Features

- Download **8 platforms** offline packages
- Incremental download - only fetches missing or changed files
- SHA256 checksum verification
- Auto-detects your platform

---

## Supported Platforms

| OS | Platform | Description |
|----|----------|-------------|
| Linux | `linux-x64` | glibc x86_64 |
| Linux | `linux-x64-musl` | musl x86_64 (Alpine) |
| Linux | `linux-arm64` | ARM64 |
| Linux | `linux-arm64-musl` | musl ARM64 |
| macOS | `darwin-x64` | Intel Mac |
| macOS | `darwin-arm64` | Apple Silicon |
| Windows | `win32-x64` | x86_64 |
| Windows | `win32-arm64` | ARM64 |

---

## Directory Structure

```
offline-claude/
├── .gitignore
├── LICENSE
├── README.md
├── README_en.md
├── download-offline-packages.sh     # Linux/macOS download script
├── download-offline-packages.ps1    # Windows download script
├── install-offline.sh               # Linux/macOS install script
├── install-offline.ps1              # Windows install script
└── downloads/                       # Downloaded files (not in Git)
    ├── VERSION.txt
    ├── manifest.json
    ├── claude-*-linux-x64
    ├── claude-*-linux-x64-musl
    ├── claude-*-linux-arm64
    ├── claude-*-linux-arm64-musl
    ├── claude-*-darwin-x64
    ├── claude-*-darwin-arm64
    ├── claude-*-win32-x64.exe
    └── claude-*-win32-arm64.exe
```

---

## Linux/macOS Usage

### 1. Download packages online

```bash
bash download-offline-packages.sh
```

> **Example output:**
>
> ```text
> ========================================
> Claude Code Offline Package Downloader
> ========================================
>
> Fetching latest version...
>   URL: https://storage.googleapis.com/claude-code-dist-...
> Latest version: 2.1.87
>
> Downloading manifest.json...
> manifest.json downloaded
>
> ========================================
> Downloading binaries for all platforms...
> ========================================
>
> Platform: linux-x64
>   ✅ File exists, checksum matches, skipping
>
> Platform: win32-x64
>   ✅ Downloaded (228M)
>
> ✅ Download complete!
> ```

### 2. Copy to offline environment

```bash
scp -r offline-claude user@offline-server:/path/to/
```

### 3. Offline installation

```bash
bash install-offline.sh
```

> Version is determined by `downloads/VERSION.txt`.

---

## Windows Usage

### 1. Download packages online

```powershell
.\download-offline-packages.ps1
```

> **Example output:**
>
> ```text
> ========================================
> Claude Code Offline Package Downloader (Windows)
> ========================================
>
> Fetching latest version...
> Latest version: 2.1.87
>
> Downloading manifest.json...
> manifest.json downloaded
>
> Platform: win32-x64
>   ✅ Downloaded (227.32 MB)
>
> ✅ Download complete!
> ```

### 2. Copy to offline environment

Copy the `offline-claude` folder to the target Windows machine.

### 3. Offline installation

```powershell
.\install-offline.ps1
```

> Version is determined by `downloads\VERSION.txt`.

---

## File Description

| File | Description |
|------|-------------|
| `download-offline-packages.sh` | Download script (all platforms) |
| `download-offline-packages.ps1` | Windows download script (alternative) |
| `install-offline.sh` | Linux/macOS install script |
| `install-offline.ps1` | Windows install script |
| `downloads/VERSION.txt` | Downloaded version info |
| `downloads/manifest.json` | Official checksum manifest (SHA256) |

### About manifest.json

Official checksum manifest containing:
- `version` - Version number
- `buildDate` - Build date
- `platforms` - Binary filename, checksum, size per platform

Automatically verified during download and installation.

---

## Notes

- Download folder ~**2GB** (all 8 platforms)
- Single binary ~188-238MB
- `downloads/` folder not committed to Git
- Claude Code binary copyrights belong to Anthropic
