# Claude Code Offline Installation Tool

Download Claude Code binaries to your local machine for offline installation in environments without network access.

## Directory Structure

```
offline-claude/
├── .gitignore                      # Git ignore configuration
├── README.md                       # This file (Chinese)
├── README_en.md                    # English version
├── download-offline-packages.sh     # Download script (all platforms)
├── download-offline-packages.ps1    # Windows download script (alternative)
├── install-offline.sh              # Linux/macOS offline install script
├── install-offline.ps1             # Windows offline install script
└── downloads/                      # Downloaded files (not committed to Git)
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

### Step 1: Download packages online

```bash
cd offline-claude
bash download-offline-packages.sh
```

**Example output:**

```
========================================
Claude Code Offline Package Downloader
========================================

Fetching latest version...
  URL: https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases/latest
Latest version: 2.1.87

Downloading manifest.json...
  Save to: /path/to/offline-claude/downloads/manifest.json
  URL: https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases/2.1.87/manifest.json
manifest.json downloaded

========================================
Downloading binaries for all platforms...
========================================

----------------------------------------
Platform: linux-x64
  Version: 2.1.87
  Save to: /path/to/offline-claude/downloads/claude-2.1.87-linux-x64
  URL: https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases/2.1.87/linux-x64/claude
  Expected Checksum: b1a5b89469862adee0e4dc28cab5a8314bc4d0117e19ab26a7b7ff7ce9b59bd5
  ✅ File exists, checksum matches, skipping

----------------------------------------
Platform: win32-x64
  Version: 2.1.87
  Save to: /path/to/offline-claude/downloads/claude-2.1.87-win32-x64.exe
  URL: https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases/2.1.87/win32-x64/claude.exe
  Expected Checksum: c722ff8836e7a90b5c62fd5cb6549887dc314e7e8d9551c01df1718d9198ecdf
  ✅ Downloaded (228M)

...
========================================
✅ Download complete!
========================================
```

**Supported platforms (8):**
- Linux: linux-x64 / linux-x64-musl / linux-arm64 / linux-arm64-musl
- macOS: darwin-x64 / darwin-arm64
- Windows: win32-x64 / win32-arm64

**Incremental download**: Re-running only downloads missing or changed files. Files with matching checksum are skipped automatically.

### Step 2: Copy to offline environment

```bash
scp -r offline-claude user@offline-server:/path/to/
```

### Step 3: Offline installation

```bash
cd offline-claude
bash install-offline.sh
```

The installed version is determined by the files in `downloads/` (read from VERSION.txt).

---

## Windows Usage

### Step 1: Download packages online (PowerShell)

```powershell
cd offline-claude
.\download-offline-packages.ps1
```

**Example output:**

```
========================================
Claude Code Offline Package Downloader (Windows)
========================================

Fetching latest version...
  URL: https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases/latest
Latest version: 2.1.87

Downloading manifest.json...
  Save to: C:\path\to\offline-claude\downloads\manifest.json
  URL: https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases/2.1.87/manifest.json
manifest.json downloaded

========================================
Downloading Windows binaries...
========================================

----------------------------------------
Platform: win32-x64
  Version: 2.1.87
  Save to: C:\path\to\offline-claude\downloads\claude-2.1.87-win32-x64.exe
  URL: https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases/2.1.87/win32-x64/claude.exe
  Expected Checksum: c722ff8836e7a90b5c62fd5cb6549887dc314e7e8d9551c01df1718d9198ecdf
  ✅ Downloaded (227.32 MB)
...

========================================
✅ Download complete!
========================================
```

### Step 2: Copy to offline environment

Copy the `offline-claude` folder to the target Windows machine.

### Step 3: Offline installation (PowerShell)

```powershell
cd offline-claude
.\install-offline.ps1
```

The installed version is determined by the files in `downloads\VERSION.txt`.

---

## File Description

| File | Description |
|------|-------------|
| `download-offline-packages.sh` | Download script (supports Linux/macOS/Windows) |
| `download-offline-packages.ps1` | Windows download script (alternative) |
| `install-offline.sh` | Linux/macOS offline install script |
| `install-offline.ps1` | Windows offline install script (PowerShell) |
| `downloads/VERSION.txt` | Current downloaded version info |
| `downloads/manifest.json` | Binary checksum manifest (filename, version, SHA256) |

### About manifest.json

`manifest.json` is the official Claude Code checksum manifest containing:
- `version`: Version number
- `buildDate`: Build date
- `platforms`: Binary filename, checksum, size for each platform

Download scripts use this file to verify integrity. Install scripts also rely on it for offline verification.

## Notes

- Download folder ~2GB (all 8 platforms)
- Binary files ~188-238MB each
- `downloads/` folder not committed to Git (large files)

---

[中文版](README.md)
