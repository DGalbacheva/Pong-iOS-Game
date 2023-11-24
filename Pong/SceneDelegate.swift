import UIKit

/// This class handles the application's display "scene" states
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    /// In this function we could customize the main application display window
    /// If you decided to design the UI in code rather than in Storyboard
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let _ = (scene as? UIWindowScene) else { return }
    }
}

