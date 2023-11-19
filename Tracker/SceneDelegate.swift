import UIKit
import Swinject

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    private var container = Container()

    override init() {
        super.init()

        container.register(TrackerViewController.self) { diResolver in
            TrackerViewController()
        }
        
        container.register(StatisticViewController.self) { diResolver in
            StatisticViewController()
        }

        container.register(TabBarController.self) { diResolver in
            TabBarController(
                trackerViewController: diResolver.resolve(TrackerViewController.self)!,
                statisticViewController: diResolver.resolve(StatisticViewController.self)!
            )
        }
    }

    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = container.resolve(TabBarController.self)
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
}

