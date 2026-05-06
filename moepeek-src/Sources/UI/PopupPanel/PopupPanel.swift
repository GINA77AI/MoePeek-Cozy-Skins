import AppKit
import Defaults
import SwiftUI

// MARK: - Environment Key

private struct PopupPanelKey: EnvironmentKey {
    static let defaultValue: PopupPanel? = nil
}

extension EnvironmentValues {
    var popupPanel: PopupPanel? {
        get { self[PopupPanelKey.self] }
        set { self[PopupPanelKey.self] = newValue }
    }
}

/// A floating, non-activating panel for showing translation results near the cursor.
final class PopupPanel: NSPanel {
    init(contentRect: NSRect) {
        super.init(
            contentRect: contentRect,
            styleMask: [.nonactivatingPanel, .fullSizeContentView, .borderless, .resizable],
            backing: .buffered,
            defer: true
        )

        level = .floating
        isOpaque = false
        backgroundColor = .clear
        hidesOnDeactivate = false
        isMovableByWindowBackground = false
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        isReleasedWhenClosed = false
        minSize = CGSize(width: 280, height: 200)
        maxSize = CGSize(width: 800, height: 800)

        // Rounded corners — read from active theme
        let t = ThemeManager.shared.current
        contentView?.wantsLayer = true
        contentView?.layer?.cornerRadius = t.panelCornerRadius
        contentView?.layer?.masksToBounds = true
    }

    // Allow becoming key window so users can select/copy text within the panel.
    override var canBecomeKey: Bool { true }

    // MARK: - Selective Window Dragging

    /// Intercepts left-mouse-down on non-interactive areas to start a window drag,
    /// while letting interactive controls (text views, buttons, gesture views) handle events normally.
    override func sendEvent(_ event: NSEvent) {
        if event.type == .leftMouseDown {
            if shouldStartWindowDrag(for: event) {
                performDrag(with: event)
                return
            }
            // Make panel key so text selection and other interactions work.
            if !isKeyWindow { makeKey() }
        }
        super.sendEvent(event)
    }

    private func shouldStartWindowDrag(for event: NSEvent) -> Bool {
        guard let contentView else { return true }
        let point = contentView.convert(event.locationInWindow, from: nil)
        guard let hitView = contentView.hitTest(point) else { return true }

        // Walk up the view hierarchy: any standard AppKit control that refuses
        // mouseDownCanMoveWindow means the user is interacting with it.
        var view: NSView? = hitView
        while let v = view, v !== contentView {
            if !v.mouseDownCanMoveWindow { return false }
            view = v.superview
        }

        // Check if the click lands on an InteractiveMarkerView (SwiftUI gesture views).
        let windowPoint = event.locationInWindow
        return !hasInteractiveMarker(in: contentView, containing: windowPoint)
    }

    private func hasInteractiveMarker(in view: NSView, containing point: NSPoint) -> Bool {
        if let marker = view as? InteractiveMarkerView {
            let rect = marker.convert(marker.bounds, to: nil)
            if rect.contains(point) { return true }
        }
        for subview in view.subviews {
            if hasInteractiveMarker(in: subview, containing: point) { return true }
        }
        return false
    }
}
