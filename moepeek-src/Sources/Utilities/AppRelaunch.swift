import AppKit

enum AppRelaunch {
    @MainActor
    static func relaunch() {
        let bundlePath = Bundle.main.bundlePath
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/open")
        task.arguments = ["-n", bundlePath]
        try? task.run()
        NSApplication.shared.terminate(nil)
    }
}
