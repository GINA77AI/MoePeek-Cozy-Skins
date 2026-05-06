# 🌐 macOS 划词翻译工具 — 竞品调研 & 方案选型

> 调研时间：2026-04-28 | 目标：找到"划词即译、1秒出结果、不打断视线"的最佳方案

---

## 一、你的核心需求（原话还原）

| # | 用户原话 | 技术含义 |
|---|---------|---------|
| 1 | "随时随地划词之后1s内就能显示结果" | **低延迟 + 即时响应** |
| 2 | "不用到处点视线被转移打扰" | **浮动面板 + 不抢焦点** |
| 3 | "不受任何工具权限限制" | **全 App 可用** |
| 4 | "终端/微信/企微/谷歌/CodeBuddy" | **全局通用** |
| 5 | "主要是中英文互相翻译" | **双语自动检测翻转** |

---

## 二、竞品全景对比

### 🏆 总览表

| 维度 | **MoePeek ⭐推荐** | Pot Desktop | Bob | 我之前的方案 |
|------|-------------------|-------------|-----|------------|
| **Stars** | 637 🔥 | 17.8k | 9.6k | — |
| **开源协议** | AGPL-3.0 ✅ | GPL-3.0 ✅ | ❌ 闭源 | ✅ |
| **技术栈** | 纯 Swift 6 | Tauri (Rust+WebView) | ObjC/Swift | Python+rumps |
| **安装体积** | **~5MB** 🏆 | ~120MB | ~50MB | <1MB |
| **内存占用** | **~50MB** 🏆 | ~300MB+ | ~150MB | ~40MB |
| **划词方式** | ⌥D 快捷键 | ⌥D 快捷键 / 复制监听 | ⌥D 快捷键 | 复制监听 ❌ |
| **结果显示** | **非激活浮动面板** | WKWebView 浮窗 | 浮动窗口 | **系统通知** ❌ |
| **是否打断焦点** | **否** 🏆 | 否 | 否 | **是** ❌ |
| **文本获取方式** | **三级降级** | Accessibility | Accessibility | 仅剪贴板 ❌ |
| **翻译引擎** | **Apple 设备端(免费)** | 多引擎(可配) | 多引擎(可配) | MyMemory 免费 |
| **需要权限** | 辅助功能(可选) | 辅助功能 | 辅助功能 | 无 ✅ |
| **平台支持** | macOS 14+ | Win/Mac/Linux | macOS | macOS |
| **维护状态** | 活跃(2026.3) | 活跃 | 停更(2022.7) | — |

---

## 三、深度解析 Top 3

### 🥇 MoePeek — 最符合你的需求

**GitHub**: [cosZone/MoePeek](https://github.com/cosZone/MoePeek)

```
作者自述："A lightweight macOS selection translator built with pure Swift 6,
featuring on-device Apple Translate for privacy, only 5MB install size 
and stable ~50MB memory usage."
```

#### 核心亮点

| 特性 | 详情 |
|------|------|
| **🎯 非激活浮动面板** | 翻译结果以浮窗出现在选中文本旁边，**不抢占当前 App 焦点**，不打断你的操作流 |
| **⚡ 三级文本抓取** | `Accessibility API` → `AppleScript` → `剪贴板兜底`，层层降级保证可用 |
| **🍎 Apple Translation** | 使用 macOS 15+ 内置的 Translation framework，**设备端运行，免费无限制，无需网络** |
| **🪶 极致轻量** | 5MB 安装包，50MB 内存，纯原生无 Electron/WebView |
| **🔒 隐私优先** | 设备端翻译 + 可选本地 LLM (Ollama/LM Studio) |

#### 工作流程

```
用户选中文字（任何App内）
        ↓
按快捷键 ⌥ D（或自定义）
        ↓
┌───────────────────────────┐
│  第一层: Accessibility API │ ← 最快最准
│    ↓ 失败                  │
│  第二层: AppleScript       │ ← 兼容备选
│    ↓ 失败                  │
│  第三层: Clipboard Fallback│ ← 最终兜底
└───────────────────────────┘
        ↓
自动检测语言方向 (中↔英)
        ↓
Apple Translation API (本地)
        ↓
浮动面板弹出（跟随光标位置）
        ↓
几秒自动消失 或 点击复制
```

#### 支持的翻译服务

| 类别 | 服务列表 |
|------|---------|
| **设备端(免费)** | Apple Translation (macOS 15+) |
| **免费云端** | Google, DeepL, Bing, 百度, 有道, 彩云... |
| **AI/LLM** | OpenAI, Anthropic, DeepSeek, GLM, Ollama(本地), LM Studio(本地) |

#### 安装方式

```bash
# 方法1: Homebrew（如果有的话）
brew install --cask moepeek

# 方法2: GitHub Release 下载 .dmg
# https://github.com/cosZone/MoePeek/releases

# 方法3: 从源码编译（Xcode 16+）
git clone https://github.com/cosZone/MoePeek.git
cd MoePeek
tuist generate && xcodebuild
```

#### 首次配置（必须）

```bash
# 1️⃣ 授予辅助功能权限
# 设置 → 隐私与安全 → 辅助功能 → 添加 MoePeek

# 2️⃣ 如果提示"已损坏"
sudo xattr -r -d com.apple.quarantine /Applications/MoePeek.app
```

---

### 🥈 Pot Desktop — 功能最全

**GitHub**: [pot-app/pot-desktop](https://github.com/pot-app/pot-desktop) | **17.8k Stars**

#### 特点

- **跨平台**: Windows / macOS / Linux 全支持
- **Tauri 架构**: Rust 后端 + Web 前端（比 Electron 轻量）
- **多引擎并行**: 可同时用多个翻译源对比
- **插件系统**: `.potext` 扩展格式
- **OCR 截图**: 内置截图识别翻译
- **HTTP API**: 本地 127.0.0.1:60828 供外部调用
- **生词本导出**: Anki、欧路词典等

#### 适合谁？

如果你还需要 Windows/Linux 支持、或者需要 OCR 截图翻译、多引擎对比等功能，Pot 是更好的选择。但如果只想要一个**纯粹的划词翻译工具**，它偏重了（~300MB内存）。

---

### 🥉 Bob — macOS 经典（已停更）

**GitHub**: [ripperhe/Bob](https://github.com/ripperhe/Bob) | **9.6k Stars**

- ⚠️ **闭源软件**（免费使用）
- ⚠️ **最后更新 2022年7月**，已停止维护
- 曾经是 macOS 上最好的翻译工具之一
- 如果你在找替代品，MoePeek 就是它的精神续作

---

## 四、我之前方案的问题诊断

| 问题 | 根因 | 正确方案 |
|------|------|---------|
| **交互流程隔离** | 只用了剪贴板监听，需要手动 ⌘C 触发 | 用 **Accessibility API** 直接读取选中文字 + **快捷键触发** |
| **没看到结果** | 用了 macOS 系统通知，容易被忽略/误关 | 用 **NSPanel 非激活浮动窗口**，显示在光标旁 |
| **打断视线** | 通知弹窗会抢占注意力 | **非激活窗口不抢焦点**，看或不看都行 |
| **不够即时** | 复制→检测变化→API调用→通知，链路长 | **快捷键直达**，省掉中间环节 |

**一句话总结我的方案问题：用了最原始的"剪贴板+通知"方案，而成熟的方案都是"Accessibility+浮动面板"架构。**

---

## 五、最终推荐方案

### 👑 推荐：直接用 MoePeek（开箱即用）

**理由：**
1. ✅ 完美匹配你"划词即译、不打断视线"的需求
2. ✅ 纯 Swift 原生，性能极致（5MB / 50MB）
3. ✅ Apple 设备端翻译，免费且无需网络
4. ✅ 开源代码可以学习借鉴
5. ✅ 活跃维护（2026年3月还在更新）

### 📋 安装步骤（3 分钟搞定）

```bash
# Step 1: 下载最新版
# 访问 https://github.com/cosZone/MoePeek/releases
# 下载 MoePeek-x.x.x.dmg

# Step 2: 拖入 Applications

# Step 3: 打开并授权
# 设置 → 隐私与安全 → 辅助功能 → 添加 MoePeek ✓

# Step 4: 开始使用
# 在任何地方选中文字 → 按 ⌥D → 翻译结果浮窗出现！
```

### 🛠️ 如果想自己开发/定制

从 MoePeek 源码中学习的关键技术：

```
核心技术栈:
├── NSPanel (非激活浮动窗口)     ← 不抢焦点的关键
├── NSEvent.addGlobalMonitor     ← 全局快捷键监听
├── AXUIElementCreateApplication  ← Accessibility 文本获取
├── NSAppleScript                ← AppleScript 兼容层
├── NSPasteboard.general         ← 剪贴板兜底
├── TranslationFramework          ← Apple 设备端翻译 API
└── NSUserNotificationCenter      ← 可选通知补充
```

---

*资料来源: MoePeek GitHub README、Pot Desktop GitHub、Bob GitHub、linux.do 社区讨论、80aj 技术博客*
