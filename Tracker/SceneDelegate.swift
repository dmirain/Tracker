import UIKit
import Swinject

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    private var container = Container()

    override init() {
        super.init()
        container.register(TrackerRepository.self) { diResolver in
            TrackerRepository()
        }
        
        container.register(SelectScheduleView.self) { diResolver in
            SelectScheduleView()
        }
        container.register(SelectScheduleController.self) { diResolver in
            SelectScheduleController(contentView: diResolver.resolve(SelectScheduleView.self)!)
        }
                
        container.register(EditTrackerView.self) { diResolver in
            EditTrackerView()
        }
        container.register(EditTrackerController.self) { diResolver in
            EditTrackerController(
                contentView: diResolver.resolve(EditTrackerView.self)!,
                selectScheduleController: diResolver.resolve(SelectScheduleController.self)!,
                trackerRepository: diResolver.resolve(TrackerRepository.self)!
            )
        }

        container.register(AddTrackerView.self) { diResolver in
            AddTrackerView()
        }
        container.register(AddTrackerController.self) { diResolver in
            AddTrackerController(
                contentView: diResolver.resolve(AddTrackerView.self)!,
                editTrackerController: diResolver.resolve(EditTrackerController.self)!
            )
        }
        container.register(AddTrackerNavControllet.self) { diResolver in
            AddTrackerNavControllet(
                rootViewController: diResolver.resolve(AddTrackerController.self)!
            )
        }
        
        container.register(TrackerListView.self) { diResolver in
            TrackerListView()
        }
        container.register(TrackerViewController.self) { diResolver in
            TrackerViewController(
                contentView: diResolver.resolve(TrackerListView.self)!,
                addTrackerNavControllet: diResolver.resolve(AddTrackerNavControllet.self)!,
                trackerRepository: diResolver.resolve(TrackerRepository.self)!
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

