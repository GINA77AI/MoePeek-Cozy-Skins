#!/bin/bash
# ============================================================
#  🌿 MoePeek Cozy Skins — 一键发布脚本
#  用法: bash quick-translate/publish.sh
# ============================================================

set -e
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$REPO_DIR"

echo ""
echo "  ╔══════════════════════════════════════════╗"
echo "  ║   🌿 MoePeek Cozy Skins 发布向导          ║"
echo "  ╚══════════════════════════════════════════╝"
echo ""

# Step 1: Check gh auth
echo "📋 步骤 1/4: 检查 GitHub 登录状态..."
if ! gh auth status 2>/dev/null; then
    echo ""
    echo "⚠️  需要先登录 GitHub（只需一次，之后自动记住）："
    echo "   正在打开浏览器..."
    gh auth login --web --git-protocol https 2>&1 || {
        echo "❌ 登录失败，请手动执行: gh auth login"
        exit 1
    }
fi
echo "✅ GitHub 已登录"
echo ""

# Step 2: Create repo
REPO_NAME="MoePeek-Cozy-Skins"
echo "📋 步骤 2/4: 创建 GitHub 仓库 [${REPO_NAME}]..."
if ! gh repo view "$REPO_NAME" &>/dev/null; then
    gh repo create "$REPO_NAME" \
        --public \
        --description "🌿 让 MoePeek 翻译工具变得好看一点 — 5 套治愈系主题皮肤" \
        --source="$REPO_DIR" \
        --push 2>&1 || {
            echo "⚠️  仓库可能已存在，尝试推送..."
            git remote add origin "git@github.com:$(gh api user --jq .login)/${REPO_NAME}.git" 2>/dev/null || true
            git push -u origin main 2>&1
        }
else
    echo "✅ 仓库已存在，推送到远程..."
    git remote set-url origin "https://github.com/$(gh api user --jq .login)/${REPO_NAME}.git" 2>/dev/null || true
    git push -u origin main 2>&1
fi
echo "✅ 代码已推送"
echo ""

# Step 3: Tag & Release
TAG="v1.0.0"
echo "📋 步骤 3/4: 创建发布版本 ${TAG}..."
if ! gh release view "$TAG" --repo "$(gh api user --jq .login)/${REPO_NAME}" &>/dev/null; then
    # Create tag locally first
    git tag "$TAG" 2>/dev/null || true
    git push origin "$TAG" 2>/dev/null || true
    
    # Create release (CI will attach the .app after building)
    gh release create "$TAG" \
        --title "🌿 MoePeek Cozy Skins v1.0.0 — First Release!" \
        --notes "## ✨ 首次发布

5 套治愈系主题皮肤：
- 🌿 **Forest Breath**（森林呼吸）— 默认皮肤
- 🌸 **Cherry Blossom**（春日樱花）
- 🎐 **Sunset Warmth**（日落暖光）
- ☁️ **Cloud Soft**（云朵软绵绵）
- ⚪ **Default**（原版 MoePeek）

### 📥 使用方法
1. 下载本页面 Assets 中的 \`MoePeek-Cozy-Skins.zip\`
2. 解压 → 拖入 /Applications
3. 系统设置 → 隐私与安全 → 辅助功能 → 添加 MoePeek ✅
4. 任意位置选中文字 → ⌥D → 完成！

### 🎨 切换皮肤
\`\`\`bash
defaults write com.coszone.MoePeek selectedSkin \"forest\"   # 森林呼吸
defaults write com.coszone.MoePeek selectedSkin \"cherry\"   # 春日樱花
defaults write com.coszone.MoePeek selectedSkin \"sunset\"   # 日落暖光
defaults write com.coszone.MoePeek selectedSkin \"cloud\"    # 云朵软绵绵
\`\`\`

### 🔧 自己编译
\`\`\`bash
brew install tuist
cd moepeek-src && tuist generate && open MoePeek.xcworkspace
\`\`\`

---
*基于 [MoePeek v0.13.1](https://github.com/cosZone/MoePeek) by cosZone*" \
        2>&1
fi
echo "✅ Release ${TAG} 创建成功！"
echo ""

# Step 4: Show result
GH_USER=$(gh api user --jq .login)
REPO_URL="https://github.com/${GH_USER}/${REPO_NAME}"
echo "📋 步骤 4/4: 完成！"
echo ""
echo "  ╔════════════════════════════════════════╗"
echo "  ║  🎉 发布完成！                           ║"
echo "  ╠════════════════════════════════════════╣"
echo "  ║  仓库地址:                               ║"
echo "  ║  ${REPO_URL} "
echo "  ║                                          ║"
echo "  ║  GitHub Actions 正在自动编译...           ║"
echo "  ║  编译完成后（~10 分钟），到 Releases 页面   ║"
echo "  ║  即可下载开箱即用的 .app 文件             ║"
echo "  ║                                          ║"
echo "  ║  查看 CI 进度:                            ║"
echo "  ║  ${REPO_URL}/actions"
echo "  ╚════════════════════════════════════════╝"
echo ""
echo "💡 提示：编译完成后会自动上传到 Release 页面的 Assets 中"
echo ""


