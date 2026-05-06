import Combine
import Sparkle

@MainActor
@Observable
final class UpdaterController {
    private let sparkleController: SPUStandardUpdaterController
    private var cancellable: AnyCancellable?

    private(set) var canCheckForUpdates = false

    var automaticallyChecksForUpdates: Bool = false {
        didSet {
            sparkleController.updater.automaticallyChecksForUpdates = automaticallyChecksForUpdates
        }
    }

    init() {
        sparkleController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: nil
        )
        automaticallyChecksForUpdates = sparkleController.updater.automaticallyChecksForUpdates
        canCheckForUpdates = sparkleController.updater.canCheckForUpdates

        cancellable = sparkleController.updater
            .publisher(for: \.canCheckForUpdates)
            .sink { [weak self] value in
                Task { @MainActor in
                    self?.canCheckForUpdates = value
                }
            }
    }

    func checkForUpdates() {
        sparkleController.checkForUpdates(nil)
    }
}
