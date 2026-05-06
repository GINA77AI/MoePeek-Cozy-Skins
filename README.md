# 🌿 MoePeek Cozy Skins

> **让 MoePeek 翻译工具变得好看一点** — 5 套治愈系主题皮肤，开箱即用

[![License: AGPL-3.0](https://img.shields.io/badge/License-AGPL--3.0-blue.svg)](./LICENSE)
[![MoePeek](https://img.shields.io/badge/Forked%20from-MoePeek-purple)](https://github.com/cosZone/MoePeek)

---

## ✨ 这是什么？

**MoePeek** 是一个优秀的 macOS 全局划词翻译工具（选中文本 → ⌥D → 翻译弹出），但它长得有点……朴素。

这个项目 fork 了 MoePeek 源码，给它加上了 **5 套治愈系皮肤主题**：

| 皮肤 | 预览 | 关键词 |
|------|------|--------|
| 🌿 **Forest Breath（森林呼吸）** | ![forest] | 苔藓绿 + 奶油白 + 橡树下的安静 |
| 🌸 **Cherry Blossom（春日樱花）** | ![cherry] | 樱花粉 + 玫瑰墨 + 温柔便签 |
| 🎐 **Sunset Warmth（日落暖光）** | ![sunset] | 暖琥珀 + 象牙白 + 台灯光晕 |
| ☁️ **Cloud Soft（云朵软绵绵）** | ![cloud] | 天蓝 + 薰衣草紫 + 躺在云端 |
| ⚪ **Default（原版）** | | MoePeek 默认外观（保留作为 fallback） |

> 👉 [**在线交互式预览（五主题切换 + 配色板）**](./forest-translate/preview.html)

---

## 🚀 开箱即用（推荐）

### 方法一：直接下载编译好的 App（无需 Xcode）

1. 进入 [Releases](../../releases) 页面
2. 下载最新 `Mopeek-Cozy-Skins.zip`（~10MB）
3. 解压 → 拖入 `/Applications`
4. 打开 **系统设置 → 隐私与安全→ 辅助功能** → 添加 MoePeek ✅
5. 任何地方选中文字 → **⌥Option+D** → 完成！🎉

### 方法二：自己编译

```bash
# 1. 需要 Xcode (App Store 安装) 和 Tuist
brew install tuist   # 或: curl -Ls https://install.tuist.io | bash

# 2. 克隆 & 构建
git clone <this-repo>.git
cd moepeek-src
tuist generate
open MoePeek.xcworkspace    # 按 ⌘R Build & Run
```

> **默认皮肤**：Forest Breath（森林呼吸）。切换皮肤见下方说明。

---

## 🎨 切换皮肤

打开 **终端**，执行：

```bash
# 查看当前皮肤
defaults read com.coszone.MoePeek selectedSkin

# 切换皮肤（改完重启 MoePeek 生效）
defaults write com.coszone.MoePeek selectedSkin "forest"     # 森林呼吸（默认）
defaults write com.coszone.MoePeek selectedSkin "cherry"      # 春日樱花
defaults write com.coszone.MoePeek selectedSkin "sunset"      # 日落暖光
defaults write com.coszone.MoePeek selectedSkin "cloud"       # 云朵软绵绵
defaults write com.coszone.MoePeek selectedSkin "default"     # 原版
```

然后重新启动 MoePeek 即可看到新皮肤。

---

## 🏗️ 项目架构

```
moepeek-src/
├── Sources/UI/Themes/
│   └── Theme.swift              ← 🔑 核心：所有皮肤参数集中定义（~300 行）
│                                · Theme 结构体（40+ 视觉参数/皮肤）
│                                · ThemeManager 单例（@Published + UserDefaults）
│                                · 5 个内置皮肤定义
│
├── Sources/UI/PopupPanel/
│   ├── PopupView.swift          ← 面板背景/渐变/阴影（从 Theme 读取）
│   ├── ProviderResultCard.swift ← 结果卡片：底色/边框/文字层级/状态色
│   ├── SourceInputView.swift    ← 输入区：背景/TTS按钮/hint 文字
│   ├── LanguageBarView.swift    ← 语言栏：交换按钮/背景条
│   ├── PopupPanel.swift         ← 圆角尺寸
│   ├── TriggerIconController.swift ← 🔘 悬浮入口按钮绘制（draw()）
│   └── TriggerIconPanel.swift   ← 悬浮按钮尺寸
│
├── Tuist/                       ← 构建配置（Tuist Project Manager）
├── Makefile                     ← 快捷命令
└── ...                          （其余文件 = 上游 MoePeek 原版代码）
```

**设计原则**：
- **Theme 层 与 业务逻辑完全分离** — 新增皮肤只需 ~30 行代码
- **0 业务逻辑改动** — 不碰翻译引擎 / Accessibility / 快捷键等核心功能
- **上游兼容** — MoePeek 更新后只需重应用 Theme 引用即可

---

## ✍️ 自定义你的皮肤

在 `Theme.swift` 的 `Theme` 结构体中添加一个新 static：

```swift
static let myCustomSkin = Theme(
    name: "My Skin",
    
    // === 面板 ===
    cornerRadius: 18,
    panelBaseColor: Color(red: 0.95, green: 0.95, blue: 1.0),
    panelShadowColor: Color.black.opacity(0.08),
    // ... 所有参数都可以调
    
    triggerIconBgTop: NSColor(red: 1.0, green: 0.98, blue: 0.95),
    triggerIconBgBottom: NSColor(red: 0.96, green: 0.94, blue: 0.99),
    // ...
)
```

然后在 `ThemeManager.allSkins` 数组中注册它。

完整参数列表见 [Theme.swift](./moepeek-src/Sources/UI/Themes/Theme.swift) 中的注释。

---

## 📸 截图对比

| 原版 MoePeek | 🌿 Forest Breath |
|-------------|-------------------|
| *灰白、硬朗、工具感* | *温暖、柔和、治愈感* |
|  |  |

> 更多截图和实时预览 → [点此查看交互 Demo](./forest-translate/preview.html)

---

## 🙏 致谢

- **[MoePeek](https://github.com/cosZone/MoePeek)** by [cosZone](https://github.com/cosZone) — 优秀的 macOS 全局翻译工具
- **Apple Translation framework** — 设备端翻译，免费且保护隐私
- 所有喜欢「好看的工具」的人 💛

---

## 📄 许可证

[AGPL-3.0](./LICENSE) — 与上游 MoePeek 保持一致。

---

*Made with ☕ by Gina · 2026*
