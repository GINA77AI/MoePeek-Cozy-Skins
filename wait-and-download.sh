#!/bin/bash
# ============================================================
#  🌿 自动等待 CI 编译完成并下载 .app
# ============================================================

REPO="GINA77AI/MoePeek-Cozy-Skins"
RUN_ID="25473233275"
OUTPUT_DIR="$HOME/Desktop"

echo "🔄 正在监控 GitHub Actions 编译状态..."
echo "   仓库: $REPO"
echo "   构建: #$RUN_ID"
echo "   下载到: $OUTPUT_DIR"
echo ""

# Poll for completion (max 30 min)
for i in $(seq 1 60); do
    STATUS=$(gh run view "$RUN_ID" --repo "$REPO" --json status,conclusion --jq '.status // "unknown"')
    CONCLUSION=$(gh run view "$RUN_ID" --repo "$REPO" --json conclusion --jq '.conclusion // ""')
    
    if [ "$STATUS" = "completed" ]; then
        echo ""
        if [ "$CONCLUSION" = "success" ]; then
            echo "✅ 编译成功！正在下载..."
            
            # Get release download URL
            RELEASE_URL=$(gh release view v1.0.0 --repo "$REPO" --json assets --jq '.assets[0].url' 2>/dev/null)
            
            if [ -n "$RELEASE_URL" ]; then
                gh release download v1.0.0 --repo "$REPO" --dir "$OUTPUT_DIR" --pattern "*.zip" 2>&1
                
                ZIP_FILE=$(ls "$OUTPUT_DIR"/MoePeek*.zip 2>/dev/null | head -1)
                
                if [ -n "$ZIP_FILE" ]; then
                    # Extract
                    cd "$OUTPUT_DIR"
                    rm -rf MoePeek-Cozy-Skins.app
                    unzip -qo "$(basename "$ZIP_FILE")"
                    
                    # Move to Applications
                    if [ -d "MoePeek-Cozy-Skins.app/Contents/MacOS" ]; then
                        cp -R "MoePeek-Cozy-Skins.app" /Applications/
                        
                        echo ""
                        echo "╔══════════════════════════════════╗"
                        echo "║  🎉 搞定！MoePeek Cozy Skins 已安装！ ║"
                        echo "╠══════════════════════════════════╣"
                        echo "║                                    ║"
                        echo "║  已安装到 /Applications/          ║"
                        echo "║  现在可以打开使用了！              ║"
                        echo "║                                    ║"
                        echo "║  使用方法:                          ║"
                        echo "║  选中文字 → 按 ⌥D → 翻译结果出现  ║"
                        echo "╚══════════════════════════════════╝"
                        
                        open /Applications/
                    else
                        echo "⚠️ 解压后未找到完整 App（可能仍有打包问题）"
                        echo "   请查看: $ZIP_FILE"
                    fi
                else
                    echo "⚠️ 未找到下载文件"
                fi
            else
                echo "⚠️ 未找到 Release 资源"
                gh run view "$RUN_ID" --repo "$REPO" --log-failed 2>/dev/null | tail -20
            fi
        else
            echo "❌ 编译失败 ($CONCLUSION)"
            gh run view "$RUN_ID" --repo "$REPO" --log-failed 2>/dev/null | tail -30
        fi
        exit 0
    fi
    
    # Progress indicator
    SPIN='-\|/'
    printf "\r   %s 已等待 %d 分钟... (状态: %s)     " "${SPIN:$((i%4)):1}" $((i/2)) "$STATUS"
    
    sleep 10
done

echo ""
echo "⏰ 等待超时（10分钟），请手动检查："
echo "   https://github.com/$REPO/actions/runs/$RUN_ID"
