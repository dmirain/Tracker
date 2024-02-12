import UIKit
import Swinject

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    private var container = Container()

    override init() {
        super.init()
        container.register(TrackerRepository.self) { _ in
            TrackerRepository()
        }
        .inObjectScope(.container)

        container.register(TrackerRecordRepository.self) { _ in
            TrackerRecordRepository()
        }
        .inObjectScope(.container)

        container.register(SelectScheduleView.self) { _ in
            SelectScheduleView()
        }
        container.register(SelectScheduleController.self) { diResolver in
            SelectScheduleController(contentView: diResolver.resolve(SelectScheduleView.self)!)
        }

        container.register(EditTrackerView.self) { _ in
            EditTrackerView()
        }
        container.register(EditTrackerController.self) { diResolver in
            EditTrackerController(
                diResolver: diResolver,
                contentView: diResolver.resolve(EditTrackerView.self)!,
                trackerRepository: diResolver.resolve(TrackerRepository.self)!
            )
        }

        container.register(AddTrackerView.self) { _ in
            AddTrackerView()
        }
        container.register(AddTrackerController.self) { diResolver in
            AddTrackerController(
                contentView: diResolver.resolve(AddTrackerView.self)!,
                editTrackerController: diResolver.resolve(EditTrackerController.self)!
            )
        }
        .inObjectScope(.transient)

        container.register(TrackerListView.self) { _ in
            TrackerListView()
        }
        container.register(TrackerViewController.self) { diResolver in
            TrackerViewController(
                factory: self,
                contentView: diResolver.resolve(TrackerListView.self)!,
                trackerRepository: diResolver.resolve(TrackerRepository.self)!,
                trackerRecordRepository: diResolver.resolve(TrackerRecordRepository.self)!
            )
        }

        container.register(StatisticViewController.self) { _ in
            StatisticViewController()
        }

        container.register(TabBarController.self) { diResolver in
            TabBarController(
                trackerViewController: diResolver.resolve(TrackerViewController.self)!,
                statisticViewController: diResolver.resolve(StatisticViewController.self)!
            )
        }
    }

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
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

extension SceneDelegate: TrackerViewControllerFactoryDelegate {
    func getAddController(parentDelegate: AddParentDelegateProtocol, selectedDate: DateWoTime) -> AddTrackerController? {
        let addTrackerController = container.resolve(AddTrackerController.self)
        addTrackerController?.initData(parentDelegate: parentDelegate, selectedDate: selectedDate)
        return addTrackerController
    }
}
