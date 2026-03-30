# Claude Code 离线下载脚本 (Windows PowerShell)
# 下载 Windows 版 Claude Code 二进制文件到本地，用于离线安装
#
# 使用方法:
#   .\download-offline-packages.ps1
#
# 管理员权限运行 PowerShell

param(
    [Parameter(Position=0)]
    [ValidatePattern('^(stable|latest|\d+\.\d+\.\d+(-[^\s]+)?)$')]
    [string]$TargetVersion = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

# 检查 32-bit Windows
if (-not [Environment]::Is64BitProcess) {
    Write-Error "Claude Code 不支持 32 位 Windows。请使用 64 位 Windows。"
    exit 1
}

$GCS_BUCKET = "https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases"
$DOWNLOAD_DIR = "$PSScriptRoot\downloads"

# 支持的平台
$PLATFORMS = @("win32-x64", "win32-arm64")

# 检测平台
if ($env:PROCESSOR_ARCHITECTURE -eq "ARM64") {
    $current_platform = "win32-arm64"
} else {
    $current_platform = "win32-x64"
}

Write-Host "========================================"
Write-Host "Claude Code 离线安装包下载工具 (Windows)"
Write-Host "========================================"
Write-Host ""

# 获取最新版本号
Write-Host "正在获取最新版本..."
$version_url = "$GCS_BUCKET/latest"
Write-Host "  URL: $version_url"

try {
    $version = Invoke-RestMethod -Uri $version_url -ErrorAction Stop
} catch {
    Write-Error "获取版本号失败: $_"
    exit 1
}
Write-Host "最新版本: $version"
Write-Host ""

# 如果指定了版本，覆盖
if ($TargetVersion) {
    $version = $TargetVersion
    Write-Host "使用指定版本: $version"
    Write-Host ""
}

# 创建下载目录
if (-not (Test-Path $DOWNLOAD_DIR)) {
    New-Item -ItemType Directory -Force -Path $DOWNLOAD_DIR | Out-Null
}

# 下载 manifest.json
Write-Host "正在下载 manifest.json..."
$manifest_url = "$GCS_BUCKET/$version/manifest.json"
$manifest_path = "$DOWNLOAD_DIR\manifest.json"
Write-Host "  保存到: $manifest_path"
Write-Host "  URL: $manifest_url"

try {
    Invoke-WebRequest -Uri $manifest_url -OutFile $manifest_path -ErrorAction Stop
} catch {
    Write-Error "下载 manifest.json 失败: $_"
    exit 1
}
Write-Host "manifest.json 下载完成"
Write-Host ""

# 读取 manifest
$manifest = Get-Content $manifest_path -Raw | ConvertFrom-Json

# 下载各平台二进制文件
Write-Host "========================================"
Write-Host "开始下载 Windows 版二进制文件..."
Write-Host "========================================"
Write-Host ""

foreach ($platform in $PLATFORMS) {
    Write-Host "----------------------------------------"
    Write-Host "平台: $platform"

    # 获取 checksum
    $checksum = $manifest.platforms.$platform.checksum
    if (-not $checksum) {
        Write-Host "  跳过（该平台 manifest 中无记录）"
        continue
    }

    $output_file = "$DOWNLOAD_DIR\claude-$version-$platform.exe"
    $download_url = "$GCS_BUCKET/$version/$platform/claude.exe"

    Write-Host "  版本: $version"
    Write-Host "  保存到: $output_file"
    Write-Host "  URL: $download_url"
    Write-Host "  期望Checksum: $checksum"

    # 检查是否需要下载
    $skip_download = $false
    if (Test-Path $output_file) {
        $actual_checksum = (Get-FileHash -Path $output_file -Algorithm SHA256).Hash.ToLower()
        if ($actual_checksum -eq $checksum) {
            Write-Host "  文件已存在，Checksum 匹配，跳过下载"
            $skip_download = $true
        } else {
            Write-Host "  文件已存在但 Checksum 不匹配，将重新下载"
            Write-Host "    旧: $actual_checksum"
            Remove-Item -Force $output_file
        }
    }

    if (-not $skip_download) {
        Write-Host "  正在下载..."
        try {
            Invoke-WebRequest -Uri $download_url -OutFile $output_file -ErrorAction Stop

            # 验证 checksum
            $actual_checksum = (Get-FileHash -Path $output_file -Algorithm SHA256).Hash.ToLower()
            if ($actual_checksum -eq $checksum) {
                $size = (Get-Item $output_file).Length / 1MB
                Write-Host "  下载完成 ($([math]::Round($size, 2)) MB)"
            } else {
                Write-Host "  Checksum 验证失败（下载的文件损坏）"
                Remove-Item -Force $output_file
            }
        } catch {
            Write-Host "  下载失败: $_"
            if (Test-Path $output_file) {
                Remove-Item -Force $output_file
            }
        }
    }
    Write-Host ""
}

# 创建版本信息文件
$version_file = "$DOWNLOAD_DIR\VERSION.txt"
$date_str = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
@"
VERSION=$version
DOWNLOAD_DATE="$date_str"
PLATFORMS="$($PLATFORMS -join ' ')"
"@ | Set-Content $version_file -Encoding UTF8

Write-Host "========================================"
Write-Host "下载完成！"
Write-Host "========================================"
Write-Host ""
Write-Host "下载目录: $DOWNLOAD_DIR"
Write-Host "版本号: $version"
Write-Host ""
Write-Host "已下载的文件:"
Get-ChildItem $DOWNLOAD_DIR -File | Where-Object { $_.Name -like "claude-*" } | ForEach-Object {
    $size_mb = [math]::Round($_.Length / 1MB, 2)
    Write-Host "  $($_.Name) ($size_str MB)" -f $size_mb
}
Write-Host ""
Write-Host "下一步："
Write-Host "  1. 将 offline-claude 目录拷贝到离线 Windows 机器"
Write-Host "  2. 在离线机器上运行 .\install-offline.ps1"
Write-Host ""
