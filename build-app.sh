#!/bin/bash
# ============================================================
#  🌿 MoePeek Cozy Skins — 本地一键编译脚本
#  用法: bash quick-translate/build-app.sh
#
#  前提：已安装完整版 Xcode（App Store 搜索 Xcode 安装）
# ============================================================

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC_DIR="${SCRIPT_DIR}/moepeek-src"
BUILD_DIR="${SCRIPT_DIR}/build"

echo ""
echo "  ╔═══════════════════════════════════════╗"
echo "  ║  🌿 MoePeek Cozy Skins 编译器         ║"
echo "  ╚═══════════════════════════════════════╝"
echo ""

# Step 1: Check Xcode
echo "📋 步骤 1/5: 检查 Xcode..."
XCODE_PATH="/Applications/Xcode.app"
if [ ! -d "$XCODE_PATH" ]; then
    echo "❌ 未找到完整版 Xcode！"
    echo ""
    echo "  请先安装："
    echo "  ① 打开 App Store"
    echo "  ② 搜索 'Xcode'"
    echo "  ③ 点击「获取」/「安装」（约 12GB）"
    echo "  ④ 安装完成后，重新运行本脚本"
    echo ""
    open "macappstore://itunes.apple.com/app/id497799835"
    exit 1
fi

# Accept license if needed (non-interactive)
sudo xcodebuild -license accept 2>/dev/null || true
xcode-select -p 2>/dev/null || sudo xcode-select -s "$XCODE_PATH/Contents/Developer" 2>/dev/null || true
echo "✅ Xcode 已就绪: $(xcodebuild -version | head -1)"
echo ""

# Step 2: Check Tuist
echo "📋 步骤 2/5: 检查 Tuist 构建工具..."
if ! command -v tuist &>/dev/null; then
    echo "   正在安装 Tuist..."
    curl -Ls https://install.tuist.sh | bash 2>&1 || {
        echo "⚠️ Tuist 自动安装失败，尝试使用 Homebrew..."
        brew install tuist 2>/dev/null || true
    }
fi
echo "✅ Tuist: $(tuist version 2>/dev/null || echo '已安装')"
echo ""

# Step 3: Generate project
echo "📋 步骤 3/5: 生成 Xcode 项目..."
cd "$SRC_DIR"
tuist generate 2>&1
if [ ! -f "MoePeek.xcworkspace/contents.xcworkspacedata" ]; then
    echo "⚠️ tuist generate 未找到 workspace，尝试其他方式..."
    # Fallback: look for any .xcworkspace or .xcodeproj
    WORKSPACE=$(find . -maxdepth 1 -name "*.xcworkspace" 2>/dev/null | head -1)
    PROJECT=$(find . -maxdepth 1 -name "*.xcodeproj" 2>/dev/null | head -1)
else
    WORKSPACE="MoePeek.xcworkspace"
fi
echo "✅ 项目生成完成"
echo ""

# Step 4: Build
echo "📋 步骤 4/5: 开始编译（这需要几分钟...）"
echo "   正在编译 MoePeek Cozy Skins..."
echo ""

BUILD_TARGET=""
if [ -n "$WORKSPACE" ] && [ -d "$WORKSPACE" ]; then
    BUILD_TARGET="-workspace $WORKSPACE"
elif [ -n "$PROJECT" ] && [ -d "$PROJECT" ]; then
    BUILD_TARGET="-project $PROJECT"
fi

# Clean build directory
rm -rf "${BUILD_DIR}"
mkdir -p "${BUILD_DIR}"

# Build with xcodebuild
xcodebuild $BUILD_TARGET \
    -scheme MoePeek \
    -configuration Release \
    -derivedDataPath "${BUILD_DIR}/DerivedData" \
    CODE_SIGN_IDENTITY="-" \
    CODE_SIGNING_ALLOWED=NO \
    build 2>&1 | tail -20

echo ""
echo "✅ 编译完成!"
echo ""

# Step 5: Find and package the .app
echo "📋 步骤 5/5: 打包 App..."

APP_PATH=$(find "${BUILD_DIR}" -name "MoePeek.app" -type d 2>/dev/null | head -1)

if [ -z "$APP_PATH" ] || [ ! -d "$APP_PATH" ]; then
    echo "⚠️ 在 DerivedData 中未找到 MoePeek.app，尝试搜索..."
    APP_PATH=$(find "${BUILD_DIR}/DerivedData" -name "*.app" -type d 2>/dev/null | grep -i moe | head -1)
fi

if [ -z "$APP_PATH" ] || [ ! -d "$APP_PATH" ]; then
    echo ""
    echo "❌ 未找到编译产物。可能的原因："
    echo "  1. macOS 版本过低（需要 macOS 15+）"
    echo "  2. Swift 编译错误"
    echo ""
    echo "  请查看上方编译日志中的错误信息"
    exit 1
fi

# Copy to output dir
OUTPUT_APP="${SCRIPT_DIR}/MoePeek-Cozy-Skins.app"
rm -rf "${OUTPUT_APP}"
cp -R "${APP_PATH}" "${OUTPUT_APP}"

# Create zip for easy sharing
OUTPUT_ZIP="${SCRIPT_DIR}/MoePeek-Cozy-Skins.zip"
rm -f "${OUTPUT_ZIP}"
ditto -ck --keepParent "${OUTPUT_APP}" "${OUTPUT_ZIP}"

APP_SIZE=$(du -sh "${OUTPUT_APP}" | cut -f1)
ZIP_SIZE=$(du -sh "${OUTPUT_ZIP}" | cut -f1)

echo ""
echo "  ╔════════════════════════════════════════╗"
echo "  ║  🎉 编译成功！                           ║"
echo "  ╠════════════════════════════════════════╣"
echo "  ║                                          ║"
echo "  ║  📦 App 文件:                             ║"
echo "  ║  ${OUTPUT_APP} "
echo "  ║  大小: ${APP_SIZE}                        "
echo "  ║                                          ║"
echo "  ║  📦 分发包:                               ║"
echo "  ║  ${OUTPUT_ZIP}          "
echo "  ║  大小: ${ZIP_SIZE}                         "
echo "  ║                                          ║"
echo "  ║  使用方法:                                ║"
echo "  ║  1. 双击 MoePeek-Cozy-Skins.app           ║"
echo "  ║  2. 或拖入 /Applications                 ║"
echo "  ║  3. 系统设置 → 辅助功能 → 添加 ✅        ║"
echo "  ║  4. 选中文字 → ⌥D → 翻译！              ║"
echo "  ╚════════════════════════════════════════╝"
echo ""

# Auto-open Finder to show the app
open -R "${OUTPUT_APP}"

echo "✨ Finder 已打开，显示编译好的 App"
