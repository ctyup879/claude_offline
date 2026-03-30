#!/bin/bash
#
# 下载 Claude Code 所有平台版本到本地（用于离线安装）
# 运行一次即可，下载的文件可供离线安装脚本使用
#

set -e

GCS_BUCKET="https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOWNLOAD_DIR="$SCRIPT_DIR/downloads"
CREDENTIALS_FILE="$SCRIPT_DIR/credentials.json"

# 支持的平台列表
PLATFORMS=(
    "linux-x64"
    "linux-x64-musl"
    "linux-arm64"
    "linux-arm64-musl"
    "darwin-x64"
    "darwin-arm64"
    "win32-x64"
    "win32-arm64"
)

mkdir -p "$DOWNLOAD_DIR"

# 检查 curl
if ! command -v curl >/dev/null 2>&1; then
    echo "curl is required but not installed" >&2
    exit 1
fi

echo "========================================"
echo "Claude Code 离线安装包下载工具"
echo "========================================"
echo ""

# 获取最新版本号
echo "正在获取最新版本..."
version_url="$GCS_BUCKET/latest"
echo "  URL: $version_url"
VERSION=$(curl -fsSL "$version_url")
if [ -z "$VERSION" ]; then
    echo "获取版本号失败" >&2
    exit 1
fi
echo "最新版本: $VERSION"
echo ""

# 下载 manifest.json
echo "正在下载 manifest.json..."
manifest_url="$GCS_BUCKET/$VERSION/manifest.json"
manifest_path="$DOWNLOAD_DIR/manifest.json"
echo "  保存到: $manifest_path"
echo "  URL: $manifest_url"
curl -fsSL -o "$manifest_path" "$manifest_url"
echo "manifest.json 下载完成"
echo ""

# 提取所有平台的 checksum
echo "========================================"
echo "开始下载各平台二进制文件..."
echo "========================================"
echo ""

for platform in "${PLATFORMS[@]}"; do
    echo "----------------------------------------"
    echo "平台: $platform"

    # 从 manifest 中提取 checksum
    checksum=$(grep -A5 "\"$platform\"" "$DOWNLOAD_DIR/manifest.json" | \
        grep "checksum" | grep -o '"[a-f0-9]\{64\}"' | tr -d '"' || echo "")

    if [ -z "$checksum" ]; then
        echo "  ⚠️  跳过（该平台 manifest 中无记录）"
        continue
    fi

    # Windows 平台需要 .exe 后缀
    if [[ "$platform" == win32-* ]]; then
        output_file="$DOWNLOAD_DIR/claude-$VERSION-$platform.exe"
        download_url="$GCS_BUCKET/$VERSION/$platform/claude.exe"
    else
        output_file="$DOWNLOAD_DIR/claude-$VERSION-$platform"
        download_url="$GCS_BUCKET/$VERSION/$platform/claude"
    fi
    echo "  版本: $VERSION"
    echo "  保存到: $output_file"
    echo "  URL: $download_url"
    echo "  期望Checksum: $checksum"

    # 检查是否需要下载
    SKIP_DOWNLOAD=false
    if [ -f "$output_file" ]; then
        # 文件已存在，验证 checksum
        actual=$(sha256sum "$output_file" 2>/dev/null | cut -d' ' -f1)
        if [ "$actual" = "$checksum" ]; then
            echo "  ✅ 文件已存在，Checksum 匹配，跳过下载"
            SKIP_DOWNLOAD=true
        else
            echo "  ⚠️  文件已存在但 Checksum 不匹配，将重新下载"
            echo "    旧: $actual"
            rm -f "$output_file"
        fi
    fi

    if [ "$SKIP_DOWNLOAD" = false ]; then
        # 下载二进制文件
        echo "  正在下载..."
        if curl -fsSL -o "$output_file" "$download_url"; then
            # 验证 checksum
            actual=$(sha256sum "$output_file" | cut -d' ' -f1)
            if [ "$actual" = "$checksum" ]; then
                chmod +x "$output_file"
                size=$(du -h "$output_file" | cut -f1)
                echo "  ✅ 下载完成 ($size)"
            else
                echo "  ❌ Checksum 验证失败（下载的文件损坏）"
                rm -f "$output_file"
            fi
        else
            echo "  ❌ 下载失败"
            rm -f "$output_file"
        fi
    fi
    echo ""
done

# 下载 install.sh 源码（参考用）
echo "----------------------------------------"
echo "下载原始 install.sh..."
curl -fsSL -o "$DOWNLOAD_DIR/install-original.sh" "$GCS_BUCKET/install.sh" 2>/dev/null || true

# 创建版本信息文件
cat > "$DOWNLOAD_DIR/VERSION.txt" << EOF
VERSION=$VERSION
DOWNLOAD_DATE="$(date '+%Y-%m-%d %H:%M:%S')"
PLATFORMS="${PLATFORMS[*]}"
EOF

echo ""
echo "========================================"
echo "✅ 下载完成！"
echo "========================================"
echo ""
echo "下载目录: $DOWNLOAD_DIR"
echo "版本号: $VERSION"
echo ""
echo "文件状态:"
ls -lh "$DOWNLOAD_DIR"/claude-* 2>/dev/null || echo "  (无二进制文件)"
echo ""
echo "说明:"
echo "  - 再次运行时，仅会下载缺失或变化的版本"
echo "  - Checksum 匹配的文件会自动跳过，无需重复下载"
echo ""
echo "下一步："
echo "  1. 将整个 offline-claude 目录拷贝到离线环境中"
echo "  2. 在离线环境中运行 install-offline.sh"
echo ""
