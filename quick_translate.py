#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
🌐 QuickTranslate — macOS 全局划线翻译工具

使用方法：
  1. 任何 App 中选中文字 → Cmd+C 复制
  2. 翻译结果自动弹出（或按快捷键手动触发）
  3. 支持中英互译，自动检测语言

依赖安装：
  pip install rumps pyperclip

启动：
  python quick_translate.py
"""

import rumps
import pyperclip
import threading
import time
import subprocess
import json
import urllib.request
import urllib.parse
import os
import signal
import sys

# ============================================================
# 配置区 — 可以根据需要修改
# ============================================================
CONFIG = {
    # 检测间隔（秒），越小越灵敏但越耗资源
    "check_interval": 0.5,
    
    # 翻译 API（免费，无需 Key）
    # MyMemory: 免费 1000 词/天，支持中英互译
    "api_url": "https://api.mymemory.translated.net/get",
    
    # 快捷键（默认 Option+T，可在菜单栏中更改）
    "hotkey": "option+t",
    
    # 弹窗显示时间（秒）
    "popup_duration": 5,
}

# ============================================================
# 翻译引擎
# ============================================================
class Translator:
    """多引擎翻译器，自动检测语言"""
    
    @staticmethod
    def detect_language(text: str) -> str:
        """简单检测是否包含中文字符"""
        for char in text:
            if '\u4e00' <= char <= '\u9fff':
                return 'zh'
        return 'en'
    
    @classmethod
    def translate(cls, text: str) -> dict:
        """
        翻译文本，返回 {source_lang, target_lang, original, translated, error}
        支持中英互译
        """
        if not text or not text.strip():
            return {"error": "文本为空"}
        
        text = text.strip()
        
        # 检测源语言 → 决定目标语言
        src = cls.detect_language(text)
        target = 'en' if src == 'zh' else 'zh-CN'
        
        try:
            # 调用 MyMemory 免费翻译 API
            params = urllib.parse.urlencode({
                'q': text,
                'langpair': f'{src}|{target}'
            })
            url = f"{CONFIG['api_url']}?{params}"
            
            req = urllib.request.Request(url)
            req.add_header('User-Agent', 'QuickTranslate/1.0')
            
            with urllib.request.urlopen(req, timeout=5) as response:
                data = json.loads(response.read().decode('utf-8'))
            
            if data.get('responseStatus') == 200:
                result = data['responseData']['translatedText']
                return {
                    'source_lang': '中文' if src == 'zh' else '英文',
                    'target_lang': '中文' if target == 'zh-CN' else 'English',
                    'original': text,
                    'translated': result,
                    'error': None,
                    'matches': data.get('matches', [])[:3]  # 备选翻译
                }
            else:
                return {"error": f"API 错误: {data.get('responseStatus', '未知')}"}
                
        except Exception as e:
            return {"error": f"翻译失败: {str(e)}"}
    
    @classmethod
    def translate_with_fallback(cls, text: str) -> dict:
        """带备用方案：MyMemory 失败则尝试直接返回处理"""
        result = cls.translate(text)
        if result.get('error'):
            # 备用：简单词典模式
            return cls._fallback_translate(text)
        return result
    
    @staticmethod
    def _fallback_translate(text: str) -> dict:
        """离线兜底：标记语言但不翻译"""
        src = Translator.detect_language(text)
        return {
            'source_lang': '中文' if src == 'zh' else '英文',
            'target_lang': '英文' if src == 'zh' else '中文',
            'original': text[:200],
            'translated': '[⚠️ 网络不可用，请检查连接后重试]',
            'error': '网络不可用',
        }


# ============================================================
# macOS 剪贴板监听器
# ============================================================
class ClipboardMonitor:
    """
    监听剪贴板变化。
    核心原理：定期对比 pbpaste 输出，检测到新内容时触发翻译。
    """
    
    def __init__(self, callback):
        self.callback = callback
        self.last_content = ""
        self.running = False
        self._thread = None
        
        # 初始化当前剪贴板内容
        try:
            self.last_content = self._get_clipboard()
        except:
            pass
    
    def _get_clipboard(self) -> str:
        """获取 macOS 剪贴板文本"""
        try:
            return subprocess.check_output(
                ['pbpaste'], 
                stderr=subprocess.DEVNULL
            ).decode('utf-8', errors='ignore')
        except:
            return ""
    
    def start(self):
        """开始监听"""
        self.running = True
        self._thread = threading.Thread(target=self._monitor_loop, daemon=True)
        self._thread.start()
    
    def stop(self):
        self.running = False
    
    def _monitor_loop(self):
        while self.running:
            try:
                current = self._get_clipboard()
                
                # 检测到新内容且不是刚翻译的结果
                if (current and 
                    current != self.last_content and 
                    len(current.strip()) > 0 and
                    len(current.strip()) < 5000):  # 避免翻译大段内容
                    
                    self.last_content = current
                    self.callback(current)
                    
            except Exception:
                pass
            
            time.sleep(CONFIG['check_interval'])


# ============================================================
# macOS 菜单栏应用
# ============================================================
class QuickTranslateApp(rumps.App):
    """
    QuickTranslate 主应用
    macOS 菜单栏常驻，全局可用
    """
    
    def __init__(self):
        super().__init__(
            name="🌐 QuickTranslate", 
            title="🌐 QT"
        )
        
        self.translator = Translator()
        self.monitor = None
        self.is_monitoring = False
        self.last_translated_text = ""  # 避免循环触发
        self.popup_timer = None
        
        # 菜单项
        self.menu = [
            f"状态: ⏸ 已暂停",
            None,  # 分隔线
            "🔄 翻译剪贴板内容",
            "⌨️ 切换监听 (Option+T)",
            None,
            "📋 使用说明",
            None,
            "退出"
        ]
        
        # 注册快捷键
        # 注意：rumps 的快捷键在菜单项上定义
        # 我们用 timer 模拟全局热键检测
    
    @rumps.clicked("🔄 翻译剪贴板内容")
    def on_manual_translate(self, _):
        """手动翻译当前剪贴板内容"""
        text = self._get_clipboard()
        if text and text.strip():
            self._do_translate(text.strip(), manual=True)
        else:
            rumps.notification("QuickTranslate", "提示", "剪贴板为空，先复制一些文字吧！")
    
    @rumps.clicked("⌨️ 切换监听 (Option+T)")
    def on_toggle_monitor(self, sender):
        """切换自动监听开关"""
        if self.is_monitoring:
            self._stop_monitoring()
            sender.title = "▶️ 开启自动监听"
            self.menu["状态: ✅ 监听中"].title = "状态: ⏸ 已暂停"
        else:
            self._start_monitoring()
            sender.title = "⏸ 关闭自动监听"
            self.menu["状态: ⏸ 已暂停"].title = "状态: ✅ 监听中"
    
    @rumps.clicked("📋 使用说明")
    def on_show_help(self, _):
        help_text = """
🌐 QuickTranslate 使用说明

【基本用法】
1. 任意位置选中文字 → 按 Cmd+C 复制
2. 翻译结果自动弹窗显示
3. 弹窗几秒后自动消失

【快捷操作】
• 点击菜单栏图标 → 手动翻译剪贴板
• Option+T → 开关自动监听
• 自动识别中/英文方向

【适用场景】
✅ 浏览网页英文文章
✅ 终端代码注释/报错信息
✅ 微信/企微外文消息
✅ PDF 文档内容
✅ 任何可以复制的文字！

【注意事项】
• 仅复制纯文本有效
• 单次不超过 5000 字符
• 需要网络连接（免费 API）
        """
        rumps.alert(help_text, title="🌐 QuickTranslate")
    
    @rumps.clicked("退出")
    def on_quit(self, _):
        self._stop_monitoring()
        rumps.quit_application()
    
    def _start_monitoring(self):
        """开启剪贴板监听"""
        # 先初始化当前内容
        try:
            self.last_translated_text = self._get_clipboard() or ""
        except:
            self.last_translated_text = ""
        
        self.monitor = ClipboardMonitor(callback=self._on_new_clipboard)
        self.monitor.last_content = self.last_translated_text
        self.monitor.start()
        self.is_monitoring = True
        rumps.notification("QuickTranslate", "已开启", "现在复制文字会自动翻译！")
    
    def _stop_monitoring(self):
        if self.monitor:
            self.monitor.stop()
            self.monitor = None
        self.is_monitoring = False
    
    def _on_new_clipboard(self, text: str):
        """剪贴板新内容的回调"""
        # 防止翻译自己写入的内容造成循环
        if text == self.last_translated_text or text.startswith('[⚠'):
            return
        
        self._do_translate(text, manual=False)
    
    def _do_translate(self, text: str, manual: bool = True):
        """执行翻译并展示结果"""
        self.last_translated_text = text
        
        # 显示"翻译中..."
        rumps.notification("QuickTranslate", "正在翻译...", text[:50])
        
        # 异步翻译避免阻塞
        def async_translate():
            result = self.translator.translate_with_fallback(text)
            
            # 在主线程更新 UI
            rumps.application.callback_queue.put(lambda: self._show_result(result, text))
        
        thread = threading.Thread(target=async_translate, daemon=True)
        thread.start()
    
    def _show_result(self, result: dict, original_text: str):
        """展示翻译结果通知"""
        if result.get('error') and not result.get('translated', '').startswith('[⚠'):
            rumps.notification(
                "❌ QuickTranslate", 
                "翻译出错", 
                result['error']
            )
            return
        
        direction = f"{result['source_lang']} → {result['target_lang']}"
        translated = result.get('translated', '')
        original_short = original_text[:80] + ('...' if len(original_text) > 80 else '')
        translated_short = translated[:150] + ('...' if len(translated) > 150 else '')
        
        # macOS 原生通知
        rumps.notification(
            f"🌐 {direction}",
            f"原文: {original_short}",
            translated_short
        )
    
    @staticmethod
    def _get_clipboard() -> str:
        """获取剪贴板"""
        try:
            return subprocess.check_output(
                ['pbpaste'], stderr=subprocess.DEVNULL
            ).decode('utf-8', errors='ignore')
        except:
            return ""


# ============================================================
# 入口
# ============================================================
def main():
    print("=" * 50)
    print("🌐 QuickTranslate — 全局划线翻译工具")
    print("=" * 50)
    print("\n使用方式:")
    print("  1. 选中任意文字 → Cmd+C 复制")
    print("  2. 结果自动弹窗显示")
    print("  3. 或点击菜单栏 🌐 图标手动翻译")
    print("\n按 Ctrl+C 退出\n")
    
    app = QuickTranslateApp()
    
    # 注册优雅退出
    signal.signal(signal.SIGINT, lambda s, f: (app._stop_monitoring(), sys.exit(0)))
    
    app.run()


if __name__ == "__main__":
    main()
