# Claude Code 离线安装工具

> 将 Claude Code 二进制文件下载到本地，用于无法访问网络的离线环境安装。

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Platforms](https://img.shields.io/badge/Platforms-Linux%20%7C%20macOS%20%7C%20Windows-blue.svg)](https://github.com)

**[English](README_en.md)**

---

## 目录

- [特性](#特性)
- [支持平台](#支持平台)
- [目录结构](#目录结构)
- [Linux/macOS 使用方法](#linuxmacos-使用方法)
- [Windows 使用方法](#windows-使用方法)
- [文件说明](#文件说明)
- [注意事项](#注意事项)

---

## 特性

- 支持 **8 个平台**的离线安装包下载
- 增量下载，仅下载缺失或变化的文件
- SHA256 校验，确保文件完整性
- 自动检测平台，无手动配置

---

## 支持平台

| 操作系统 | 平台 | 说明 |
|---------|------|------|
| Linux | `linux-x64` | glibc x86_64 |
| Linux | `linux-x64-musl` | musl x86_64 (Alpine) |
| Linux | `linux-arm64` | ARM64 |
| Linux | `linux-arm64-musl` | musl ARM64 |
| macOS | `darwin-x64` | Intel Mac |
| macOS | `darwin-arm64` | Apple Silicon |
| Windows | `win32-x64` | x86_64 |
| Windows | `win32-arm64` | ARM64 |

---

## 目录结构

```
offline-claude/
├── .gitignore
├── LICENSE
├── README.md
├── README_en.md
├── download-offline-packages.sh     # Linux/macOS 下载脚本
├── download-offline-packages.ps1     # Windows 下载脚本
├── install-offline.sh                # Linux/macOS 安装脚本
├── install-offline.ps1               # Windows 安装脚本
└── downloads/                        # 下载文件（不提交到 Git）
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

## Linux/macOS 使用方法

### 1. 在线环境下载包

```bash
bash download-offline-packages.sh
```

> **示例输出：**
>
> ```text
> ========================================
> Claude Code 离线安装包下载工具
> ========================================
>
> 正在获取最新版本...
>   URL: https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases/latest
> 最新版本: 2.1.87
>
> 正在下载 manifest.json...
>   保存到: /path/to/offline-claude/downloads/manifest.json
>   URL: https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases/2.1.87/manifest.json
> manifest.json 下载完成
>
> ========================================
> 开始下载各平台二进制文件...
> ========================================
>
> ----------------------------------------
> 平台: linux-x64
>   版本: 2.1.87
>   保存到: /path/to/offline-claude/downloads/claude-2.1.87-linux-x64
>   URL: https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases/2.1.87/linux-x64/claude
>   期望Checksum: b1a5b89469862adee0e4dc28cab5a8314bc4d0117e19ab26a7b7ff7ce9b59bd5
>   ✅ 文件已存在，Checksum 匹配，跳过下载
>
> ----------------------------------------
> 平台: win32-x64
>   版本: 2.1.87
>   保存到: /path/to/offline-claude/downloads/claude-2.1.87-win32-x64.exe
>   URL: https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases/2.1.87/win32-x64/claude.exe
>   期望Checksum: c722ff8836e7a90b5c62fd5cb6549887dc314e7e8d9551c01df1718d9198ecdf
>   ✅ 下载完成 (228M)
>
> ...
> ========================================
> ✅ 下载完成！
> ========================================
> ```

### 2. 拷贝到离线环境

```bash
scp -r offline-claude user@offline-server:/path/to/
```

### 3. 离线环境安装

```bash
bash install-offline.sh
```

> 安装版本由 `downloads/VERSION.txt` 决定。

---

## Windows 使用方法

### 1. 在线环境下载包

```powershell
.\download-offline-packages.ps1
```

> **示例输出：**
>
> ```text
> ========================================
> Claude Code 离线安装包下载工具 (Windows)
> ========================================
>
> 正在获取最新版本...
>   URL: https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases/latest
> 最新版本: 2.1.87
>
> 正在下载 manifest.json...
>   保存到: C:\path\to\offline-claude\downloads\manifest.json
>   URL: https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases/2.1.87/manifest.json
> manifest.json 下载完成
>
> ========================================
> 开始下载 Windows 版二进制文件...
> ========================================
>
> ----------------------------------------
> 平台: win32-x64
>   版本: 2.1.87
>   保存到: C:\path\to\offline-claude\downloads\claude-2.1.87-win32-x64.exe
>   URL: https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases/2.1.87/win32-x64/claude.exe
>   期望Checksum: c722ff8836e7a90b5c62fd5cb6549887dc314e7e8d9551c01df1718d9198ecdf
>   ✅ 下载完成 (227.32 MB)
>
> ...
> ========================================
> ✅ 下载完成！
> ========================================
> ```

### 2. 拷贝到离线环境

直接拷贝 `offline-claude` 文件夹到目标 Windows 机器。

### 3. 离线环境安装

```powershell
.\install-offline.ps1
```

> 安装版本由 `downloads\VERSION.txt` 决定。

---

## 文件说明

| 文件 | 说明 |
|------|------|
| `download-offline-packages.sh` | 下载脚本（支持所有平台） |
| `download-offline-packages.ps1` | Windows 下载脚本（备选） |
| `install-offline.sh` | Linux/macOS 安装脚本 |
| `install-offline.ps1` | Windows 安装脚本 |
| `downloads/VERSION.txt` | 下载版本信息 |
| `downloads/manifest.json` | 官方校验清单（含 SHA256） |

### manifest.json 说明

官方发布的校验清单，包含：
- `version` - 版本号
- `buildDate` - 构建日期
- `platforms` - 各平台二进制文件名、checksum、大小

下载和安装时自动校验文件完整性。

---

## 注意事项

- 下载目录约 **2GB**（包含所有 8 个平台）
- 单个二进制文件约 188-238MB
- `downloads/` 目录不提交到 Git
- Claude Code 二进制文件版权归 Anthropic 所有
