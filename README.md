# Claude Code 离线安装工具

将 Claude Code 二进制文件下载到本地，用于无法访问网络的离线环境安装。

## 目录结构

```
offline-claude/
├── .gitignore                      # Git 忽略配置
├── README.md                       # 本文件
├── download-offline-packages.sh     # 下载脚本（支持所有平台）
├── download-offline-packages.ps1    # Windows 下载脚本（备选）
├── install-offline.sh              # Linux/macOS 离线安装脚本
├── install-offline.ps1             # Windows 离线安装脚本
└── downloads/                      # 下载的文件目录（不提交到 Git）
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

### 步骤 1：在线环境下载包

```bash
cd offline-claude
bash download-offline-packages.sh
```

**运行示例：**

```
========================================
Claude Code 离线安装包下载工具
========================================

正在获取最新版本...
  URL: https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases/latest
最新版本: 2.1.87

正在下载 manifest.json...
  保存到: /path/to/offline-claude/downloads/manifest.json
  URL: https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases/2.1.87/manifest.json
manifest.json 下载完成

========================================
开始下载各平台二进制文件...
========================================

----------------------------------------
平台: linux-x64
  版本: 2.1.87
  保存到: /path/to/offline-claude/downloads/claude-2.1.87-linux-x64
  URL: https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases/2.1.87/linux-x64/claude
  期望Checksum: b1a5b89469862adee0e4dc28cab5a8314bc4d0117e19ab26a7b7ff7ce9b59bd5
  ✅ 文件已存在，Checksum 匹配，跳过下载

----------------------------------------
平台: win32-x64
  版本: 2.1.87
  保存到: /path/to/offline-claude/downloads/claude-2.1.87-win32-x64.exe
  URL: https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases/2.1.87/win32-x64/claude.exe
  期望Checksum: c722ff8836e7a90b5c62fd5cb6549887dc314e7e8d9551c01df1718d9198ecdf
  ✅ 下载完成 (228M)

...
========================================
✅ 下载完成！
========================================
```

**支持平台：**
- Linux: linux-x64 / linux-x64-musl / linux-arm64 / linux-arm64-musl
- macOS: darwin-x64 / darwin-arm64
- Windows: win32-x64 / win32-arm64

**增量下载**：再次运行时，仅下载缺失或变化的版本，Checksum 匹配的文件自动跳过。

### 步骤 2：拷贝到离线环境

```bash
scp -r offline-claude user@offline-server:/path/to/
```

### 步骤 3：离线环境安装

```bash
cd offline-claude
bash install-offline.sh
```

安装的版本由 `downloads/` 目录中已下载的文件决定（从 VERSION.txt 读取）。

---

## Windows 使用方法

### 步骤 1：在线环境下载包（PowerShell）

```powershell
cd offline-claude
.\download-offline-packages.ps1
```

**运行示例：**

```
========================================
Claude Code 离线安装包下载工具 (Windows)
========================================

正在获取最新版本...
  URL: https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases/latest
最新版本: 2.1.87

正在下载 manifest.json...
  保存到: C:\path\to\offline-claude\downloads\manifest.json
  URL: https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases/2.1.87/manifest.json
manifest.json 下载完成

========================================
开始下载 Windows 版二进制文件...
========================================

----------------------------------------
平台: win32-x64
  版本: 2.1.87
  保存到: C:\path\to\offline-claude\downloads\claude-2.1.87-win32-x64.exe
  URL: https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases/2.1.87/win32-x64/claude.exe
  期望Checksum: c722ff8836e7a90b5c62fd5cb6549887dc314e7e8d9551c01df1718d9198ecdf
  ✅ 下载完成 (227.32 MB)
...

========================================
✅ 下载完成！
========================================
```

### 步骤 2：拷贝到离线环境

直接拷贝 `offline-claude` 文件夹到目标 Windows 机器。

### 步骤 3：离线环境安装（PowerShell）

```powershell
cd offline-claude
.\install-offline.ps1
```

安装的版本由 `downloads\VERSION.txt` 中已下载的版本决定。

---

## 文件说明

| 文件 | 说明 |
|------|------|
| `download-offline-packages.sh` | 下载脚本（支持 Linux/macOS/Windows 所有平台） |
| `download-offline-packages.ps1` | Windows 下载脚本（备选） |
| `install-offline.sh` | Linux/macOS 离线安装脚本 |
| `install-offline.ps1` | Windows 离线安装脚本（PowerShell） |
| `downloads/VERSION.txt` | 当前下载的版本信息 |
| `downloads/manifest.json` | 各平台的二进制文件 Checksum 校验清单（含文件名、版本、SHA256） |

### manifest.json 说明

`manifest.json` 是 Claude Code 官方发布的校验清单文件，包含：
- `version`: 版本号
- `buildDate`: 构建日期
- `platforms`: 各平台的二进制文件名、checksum、大小

下载脚本使用此文件验证文件完整性，安装脚本也依赖此文件进行离线校验。

## 注意事项

- 下载目录约 2GB（包含所有 8 个平台）
- 二进制文件约 188-238MB 每个
- `downloads/` 目录不提交到 Git（大文件）
