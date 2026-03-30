#!/bin/bash
#
# Claude Code 离线安装脚本
# 使用本地下载的包进行安装，无需网络连接
#
# 使用方法:
#   ./install-offline.sh
#
# 版本由 downloads/VERSION.txt 中已下载的版本决定
#

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOWNLOAD_DIR="$SCRIPT_DIR/downloads"

# Detect platform
case "$(uname -s)" in
    Darwin) os="darwin" ;;
    Linux) os="linux" ;;
    MINGW*|MSYS*|CYGWIN*) echo "Windows is not supported." >&2; exit 1 ;;
    *) echo "Unsupported OS: $(uname -s)" >&2; exit 1 ;;
esac

case "$(uname -m)" in
    x86_64|amd64) arch="x64" ;;
    arm64|aarch64) arch="arm64" ;;
    *) echo "Unsupported architecture: $(uname -m)" >&2; exit 1 ;;
esac

# Detect Rosetta 2 on macOS
if [ "$os" = "darwin" ] && [ "$arch" = "x64" ]; then
    if [ "$(sysctl -n sysctl.proc_translated 2>/dev/null)" = "1" ]; then
        arch="arm64"
    fi
fi

# Adjust for musl on Linux
if [ "$os" = "linux" ]; then
    if [ -f /lib/libc.musl-x86_64.so.1 ] || [ -f /lib/libc.musl-aarch64.so.1 ] || ldd /bin/ls 2>&1 | grep -q musl; then
        platform="linux-${arch}-musl"
    else
        platform="linux-${arch}"
    fi
else
    platform="${os}-${arch}"
fi

echo "========================================"
echo "Claude Code 离线安装脚本"
echo "========================================"
echo ""
echo "检测平台: $platform"
echo ""

# 读取版本信息
if [ ! -f "$DOWNLOAD_DIR/VERSION.txt" ]; then
    echo "❌ 错误: VERSION.txt 不存在" >&2
    echo "请确保已运行 download-offline-packages.sh 下载离线包" >&2
    exit 1
fi

source "$DOWNLOAD_DIR/VERSION.txt"
echo "安装版本: $VERSION (下载日期: $DOWNLOAD_DATE)"
echo ""

# 查找本地二进制文件
binary_path="$DOWNLOAD_DIR/claude-$VERSION-$platform"

if [ ! -f "$binary_path" ]; then
    echo "❌ 错误: 本地二进制文件不存在" >&2
    echo "路径: $binary_path" >&2
    echo "" >&2
    echo "该平台 ($platform) 可能尚未下载。" >&2
    echo "请在有网络的环境中运行 download-offline-packages.sh 下载所需的平台包。" >&2
    exit 1
fi

# 验证 checksum
echo "验证文件完整性..."
if [ -f "$DOWNLOAD_DIR/manifest.json" ]; then
    expected=$(grep -A5 "\"$platform\"" "$DOWNLOAD_DIR/manifest.json" | \
        grep "checksum" | grep -o '"[a-f0-9]\{64\}"' | tr -d '"' | head -1)

    if [ -n "$expected" ]; then
        actual=$(sha256sum "$binary_path" | cut -d' ' -f1)
        if [ "$actual" != "$expected" ]; then
            echo "❌ Checksum 验证失败" >&2
            echo "期望: $expected" >&2
            echo "实际: $actual" >&2
            exit 1
        fi
        echo "✅ Checksum 验证通过"
    fi
fi
echo ""

# 设置执行权限
chmod +x "$binary_path"

# 可选：复制到本地目录
LOCAL_INSTALL_DIR="$HOME/.claude/offline-bin"
mkdir -p "$LOCAL_INSTALL_DIR"
LOCAL_BINARY="$LOCAL_INSTALL_DIR/claude-$VERSION-$platform"
cp "$binary_path" "$LOCAL_BINARY"
chmod +x "$LOCAL_BINARY"

echo "二进制文件已复制到: $LOCAL_BINARY"
echo ""

# 运行安装
echo "========================================"
echo "正在安装 Claude Code..."
echo "========================================"
echo ""

"$LOCAL_BINARY" install

echo ""
echo "========================================"
echo "✅ 离线安装完成！"
echo "========================================"
echo ""
echo "提示: 如果安装成功，二进制文件已安装到系统路径"
echo "      无需保留离线包目录"
echo ""
