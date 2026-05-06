#!/bin/bash
# QuickTranslate 启动脚本
# 一键安装依赖并启动

set -e

echo "🌐 QuickTranslate 启动器"
echo "========================"

# 检查 Python3
if ! command -v python3 &>/dev/null; then
    echo "❌ 需要先安装 Python3"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# 安装依赖
echo "📦 检查依赖..."
pip3 install -q rumps pyperclip 2>/dev/null || {
    echo "⏳ 正在安装依赖..."
    pip3 install rumps pyperclip
}

echo ""
echo "🚀 启动 QuickTranslate..."
echo "   • 菜单栏会出现 🌐 图标"
echo "   • 选中文字 → Cmd+C 即可自动翻译"
echo "   • 按 Ctrl+C 或菜单栏退出"
echo ""
echo "========================"

python3 quick_translate.py
