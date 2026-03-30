# Claude Code 离线安装脚本 (Windows PowerShell)
# 使用本地下载的包进行安装，无需网络连接
#
# 使用方法:
#   .\install-offline.ps1
#
# 版本由 downloads\VERSION.txt 中已下载的版本决定

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

# 检查 32-bit Windows
if (-not [Environment]::Is64BitProcess) {
    Write-Error "Claude Code 不支持 32 位 Windows。请使用 64 位 Windows。"
    exit 1
}

$SCRIPT_DIR = $PSScriptRoot
$DOWNLOAD_DIR = Join-Path $SCRIPT_DIR "downloads"

# 检测平台
if ($env:PROCESSOR_ARCHITECTURE -eq "ARM64") {
    $platform = "win32-arm64"
} else {
    $platform = "win32-x64"
}

Write-Host "========================================"
Write-Host "Claude Code 离线安装脚本 (Windows)"
Write-Host "========================================"
Write-Host ""
Write-Host "检测平台: $platform"
Write-Host ""

# 读取版本信息
$version_file = Join-Path $DOWNLOAD_DIR "VERSION.txt"
if (-not (Test-Path $version_file)) {
    Write-Error "错误: VERSION.txt 不存在"
    Write-Error "请确保已运行 download-offline-packages.ps1 下载离线包"
    exit 1
}

$version_content = Get-Content $version_file -Raw
$version = ($version_content -replace '.*VERSION=(\S+).*', '$1')
$download_date = ($version_content -replace '.*DOWNLOAD_DATE="([^"]+)".*', '$1')

Write-Host "安装版本: $version (下载日期: $download_date)"
Write-Host ""

# 查找本地二进制文件
$binary_path = Join-Path $DOWNLOAD_DIR "claude-$version-$platform.exe"

if (-not (Test-Path $binary_path)) {
    Write-Error "错误: 本地二进制文件不存在"
    Write-Error "路径: $binary_path"
    Write-Host ""
    Write-Error "该平台 ($platform) 可能尚未下载。"
    Write-Error "请在有网络的环境中运行 download-offline-packages.ps1 下载所需的平台包。"
    exit 1
}

# 验证 checksum (可选)
$manifest_file = Join-Path $DOWNLOAD_DIR "manifest.json"
if (Test-Path $manifest_file) {
    Write-Host "验证文件完整性..."
    $manifest = Get-Content $manifest_file -Raw | ConvertFrom-Json

    $expected = $manifest.platforms.$platform.checksum
    if ($expected) {
        $actual = (Get-FileHash -Path $binary_path -Algorithm SHA256).Hash.ToLower()
        if ($actual -ne $expected) {
            Write-Error "Checksum 验证失败"
            Write-Error "期望: $expected"
            Write-Error "实际: $actual"
            exit 1
        }
        Write-Host "Checks验证通过"
    }
    Write-Host ""
}

# 复制到本地安装目录
$local_install_dir = Join-Path $env:LOCALAPPDATA "claude\offline-bin"
if (-not (Test-Path $local_install_dir)) {
    New-Item -ItemType Directory -Force -Path $local_install_dir | Out-Null
}
$local_binary = Join-Path $local_install_dir "claude-$version-$platform.exe"
Copy-Item $binary_path $local_binary -Force
Write-Host "二进制文件已复制到: $local_binary"
Write-Host ""

# 运行安装
Write-Host "========================================"
Write-Host "正在安装 Claude Code..."
Write-Host "========================================"
Write-Host ""

& $local_binary install

Write-Host ""
Write-Host "========================================"
Write-Host "离线安装完成！"
Write-Host "========================================"
Write-Host ""
Write-Host "提示: 如果安装成功，二进制文件已安装到系统路径"
Write-Host "      无需保留离线包目录"
Write-Host ""
