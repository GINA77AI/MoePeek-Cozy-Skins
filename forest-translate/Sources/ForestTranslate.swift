import SwiftUI
import AppKit
import Carbon
import Translation

// MARK: - App Entry Point

@main
struct ForestTranslateApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

// MARK: - App Delegate

class AppDelegate: NSObject, NSApplicationDelegate {
    var popupController: PopupController?
    var statusItem: NSStatusItem?
    var hotKeyRef: EventHotKeyRef?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Setup menu bar icon
        setupStatusBar()
        // Setup global hotkey (Option+D)
        setupHotKey()
        // Create popup controller
        popupController = PopupController()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }

    func setupStatusBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "leaf.fill", accessibilityDescription: "Forest Translate")
            button.image?.isTemplate = true
        }

        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Toggle Popup (⌥D)", action: #selector(togglePopup), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit ForestTranslate", action: #selector(quitApp), keyEquivalent: "q"))
        statusItem?.menu = menu
    }

    func setupHotKey() {
        var gMyHotKeyID = EventHotKeyID()
        gMyHotKeyID.signature = OSType(0x46545254) // 'FTRT'
        gMyHotKeyID.id = 1

        let status = RegisterEventHotKey(
            UInt32(kVK_ANSI_D),
            UInt32(optionKey),
            gMyHotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
        if status != noErr {
            print("Failed to register hotkey: \(status)")
        }
    }

    // Handle global hotkey
    func handleHotkey() {
        togglePopup(nil)
    }

    @objc func togglePopup(_ sender: Any?) {
        popupController?.toggle()
    }

    @objc func quitApp(_ sender: Any?) {
        if let ref = hotKeyRef {
            UnregisterEventHotKey(ref)
        }
        NSApplication.shared.terminate(nil)
    }
}

// MARK: - Hotkey Event Handler

func applicationEventHandler(_ nextHandler: EventHandler?, _ event: Event, _ targetData: UnsafeMutableRawPointer?) -> OSStatus {
    if event.getType() == .eventHotKey {
        DispatchQueue.main.async {
            if let delegate = NSApplication.shared.delegate as? AppDelegate {
                delegate.handleHotkey()
            }
        }
    }
    return noErr
}

// MARK: - Popup Controller

class PopupController: NSObject {
    private var popupWindow: NSPanel?
    private var translator: TranslationManager = TranslationManager()

    func toggle() {
        if let window = popupWindow, window.isVisible {
            hidePopup()
        } else {
            showPopup()
        }
    }

    func showPopup() {
        if popupWindow == nil {
            createPopupWindow()
        }

        // Get selected text from accessibility API
        let selectedText = getSelectedText()

        popupWindow?.contentViewController?.representedObject = selectedText
        popupWindow?.makeKeyAndOrderFront(nil)

        // Position near cursor
        if let window = popupWindow {
            let mouseLocation = NSEvent.mouseLocation
            var screenFrame = NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 800, height: 600)
            let windowSize = NSSize(width: 380, height: 280)

            var origin = NSPoint(
                x: mouseLocation.x + 15,
                y: mouseLocation.y - 20
            )

            // Keep within screen bounds
            if origin.x + windowSize.width > screenFrame.maxX {
                origin.x = screenFrame.maxX - windowSize.width - 10
            }
            if origin.y < screenFrame.minY {
                origin.y = screenFrame.minY + 10
            }

            window.setFrameOrigin(origin)
        }
    }

    func hidePopup() {
        popupWindow?.orderOut(nil)
    }

    private func createPopupWindow() {
        let contentView = PopupContentView()
            .environment(\.translator, translator)

        let vc = NSHostingController(rootView: contentView)

        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 380, height: 280),
            styleMask: [.nonactivatingPanel, .titled, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        panel.contentViewController = vc
        panel.isFloatingPanel = true
        panel.hidesOnDeactivate = false
        panel.becomesKeyOnlyIfNeeded = true
        panel.level = .floating
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        panel.isMovableByWindowBackground = true
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        // Apply Forest Breath appearance
        panel.backgroundColor = NSColor(red: 0.95, green: 0.97, blue: 0.93, alpha: 0.96)

        popupWindow = panel
    }

    /// Try to get selected text via Accessibility API
    private func getSelectedText() -> String {
        // Method 1: Accessibility API
        if let text = getSelectedTextViaAccessibility(), !text.isEmpty {
            return text
        }

        // Method 2: Clipboard fallback
        return getSelectedTextViaClipboard()
    }

    private func getSelectedTextViaAccessibility() -> String? {
        guard let frontmost = NSWorkspace.shared.frontmostApplication else { return nil }

        let source = AXUIElementCreateApplication(frontmost.processIdentifier)
        var focusedElement: AXUIElement?
        AXUIElementCopyAttributeValue(source, kAXFocusedUIElementAttribute as CFString, &focusedElement)

        guard let focused = focusedElement else { return nil }

        var selectionValue: AnyObject?
        AXUIElementCopyAttributeValue(focused, kAXSelectedTextAttribute as CFString, &selectionValue)

        return selectionValue as? String
    }

    private func getSelectedTextViaClipboard() -> String -> String {
        return NSPasteboard.general.string(forType: .string) ?? ""
    }
}

// MARK: - Translation Manager

@Observable
class TranslationManager {
    var sourceText: String = ""
    var translatedText: String = ""
    var isTranslating: Bool = false
    var error: String?
    var sourceLanguage: String = "auto"
    var targetLanguage: String = "zh-Hans"

    func translate() async {
        guard !sourceText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        isTranslating = true
        error = nil
        translatedText = ""

        do {
            let configuration = TranslationConfiguration(source: Language(sourceLanguage), target: Language(targetLanguage))
            let session = TranslationSession(configuration: configuration)
            let response = try await session.translate(sourceText)
            translatedText = response.targetText
        } catch {
            self.error = error.localizedDescription
        }

        isTranslating = false
    }
}

// MARK: - Translation Environment Key

private struct TranslationEnvironmentKey: EnvironmentKey {
    static let defaultValue = TranslationManager()
}

extension EnvironmentValues {
    var translator: TranslationManager {
        get { self[TranslationEnvironmentKey.self] }
        set { self[TranslationEnvironmentKey.self] = newValue }
    }
}

// MARK: - Popup Content View (Forest Breath Theme)

struct PopupContentView: View {
    @Environment(\.translator) private var translator
    @State private var isExpanded: Bool = true

    // Forest Breath Color Palette
    private let forestCream = Color(red: 0.95, green: 0.97, blue: 0.93)
    private let forestGreenLight = Color(red: 0.88, green: 0.94, blue: 0.87)
    private let forestGreenMid = Color(red: 0.72, green: 0.84, blue: 0.68)
    private let forestGreenDark = Color(red: 0.45, green: 0.62, blue: 0.40)
    private let forestTextDark = Color(red: 0.20, green: 0.28, blue: 0.18)
    private let forestTextMid = Color(red: 0.40, green: 0.52, blue: 0.36)
    private let forestOlive = Color(red: 0.55, green: 0.65, blue: 0.52)
    private let forestHint = Color(red: 0.70, green: 0.78, blue: 0.68)
    private let shadowColor = Color.black.opacity(0.06)

    var body: some View {
        VStack(spacing: 0) {
            // ===== Header / Drag Area =====
            HStack {
                Image(systemName: "leaf.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(forestGreenDark)

                Text("Forest Translate")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(forestOlive)

                Spacer()

                Button(action: { /* close */ }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(forestHint)
                        .frame(width: 20, height: 20)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .help("Close")
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)

            Divider()
                .background(forestGreenLight.opacity(0.5))

            // ===== Source Input =====
            VStack(alignment: .leading, spacing: 6) {
                TextEditor(text: $translator.sourceText)
                    .font(.system(size: 14))
                    .scrollContentBackground(.hidden)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(forestGreenLight.opacity(0.4))
                    )
                    .frame(minHeight: 60, maxHeight: 120)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(forestGreenMid.opacity(0.15), lineWidth: 0.5)
                    )

                HStack(spacing: 6) {
                    // Language indicators
                    HStack(spacing: 4) {
                        Text("Auto")
                            .font(.caption2.bold())
                            .foregroundStyle(forestTextMid)
                        Image(systemName: "arrow.right")
                            .font(.caption2)
                            .foregroundStyle(forestGreenDark)
                        Text("中文")
                            .font(.caption2.bold())
                            .foregroundStyle(forestTextMid)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(forestGreenLight.opacity(0.5))
                    )

                    Spacer()

                    Text("↵ 翻译")
                        .font(.caption2)
                        .foregroundStyle(forestHint)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)

            // ===== Result Card =====
            VStack(alignment: .leading, spacing: 0) {
                // Result header
                HStack(spacing: 6) {
                    Image(systemName: "character.bubble")
                        .font(.system(size: 11))
                        .foregroundStyle(forestGreenDark)

                    Text("Apple Translation")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(forestTextMid)

                    Spacer()

                    if translator.isTranslating {
                        ProgressView()
                            .controlSize(.mini)
                            .scaleEffect(0.8)
                    } else if !translator.translatedText.isEmpty {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(forestGreenDark)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 7)

                Divider()
                    .padding(.horizontal, 10)
                    .background(forestGreenLight.opacity(0.3))

                // Translated text
                Group {
                    if translator.isTranslating {
                        HStack {
                            ProgressView("翻译中...")
                                .font(.system(size: 13))
                                .foregroundStyle(forestOlive)
                            Spacer()
                        }
                        .padding(.vertical, 16)
                    } else if let errorMsg = translator.error {
                        HStack(spacing: 4) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 12))
                            Text(errorMsg)
                                .font(.system(size: 13))
                        }
                        .foregroundStyle(Color.red.opacity(0.7))
                        .padding(.vertical, 12)
                    } else if translator.translatedText.isEmpty {
                        Text("翻译结果将显示在这里…")
                            .font(.system(size: 13))
                            .italic()
                            .foregroundStyle(forestHint)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 16)
                    } else {
                        Text(translator.translatedText)
                            .font(.system(size: 14))
                            .foregroundStyle(forestTextDark)
                            .textSelection(.enabled)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .lineSpacing(3)
                            .padding(.vertical, 10)

                        // Action buttons
                        HStack {
                            Spacer()

                            Button(action: copyResult) {
                                Label("复制", systemImage: "doc.on.doc")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundStyle(forestGreenDark)
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.mini)
                            .tint(forestGreenLight)
                        }
                        .padding(.bottom, 6)
                    }
                }
                .padding(.horizontal, 12)
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.5))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(forestGreenMid.opacity(0.18), lineWidth: 0.5)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
        }
        // ===== Main Container Background =====
        .background(
            ZStack {
                // Base: warm cream
                forestCream.opacity(0.97)
                // Subtle gradient for depth
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.25),
                        forestGreenLight.opacity(0.12),
                        Color.clear
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        )
        .shadow(color: shadowColor, radius: 20, y: 6)
        .onAppear {
            // If there's initial text from clipboard/accessibility, auto-translate
            if !translator.sourceText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Task { await translator.translate() }
            }
        }
        .onChange(of: translator.sourceText) {
            // Auto-translate on paste (with debounce would be better)
        }
    }

    private func copyResult() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(translator.translatedText, forType: .string)
    }
}
