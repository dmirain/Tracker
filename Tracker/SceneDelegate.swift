import UIKit
import Swinject

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    private var container = Container()

    override init() {
        super.init()

        container.register(CreateTrackerView.self) { diResolver in
            CreateTrackerView()
        }
        container.register(CreateTrackerController.self) { diResolver in
            CreateTrackerController(contentView: diResolver.resolve(CreateTrackerView.self)!)
        }

        container.register(AddTrackerView.self) { diResolver in
            AddTrackerView()
        }
        container.register(AddTrackerController.self) { diResolver in
            AddTrackerController(
                contentView: diResolver.resolve(AddTrackerView.self)!,
                createTrackerController: diResolver.resolve(CreateTrackerController.self)!
            )
        }

        
        container.register(TrackerView.self) { diResolver in
            TrackerView()
        }
        container.register(TrackerViewController.self) { diResolver in
            TrackerViewController(
                contentView: diResolver.resolve(TrackerView.self)!,
                addTrackerController: diResolver.resolve(AddTrackerController.self)!
            )
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

