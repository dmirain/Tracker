import UIKit
import Swinject
import CoreData

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    private var container = Container()

    override init() {
        super.init()

        container.register(Settings.self) { _ in
            SettingsProd()
        }
        .inObjectScope(.container)

        container.register(NSManagedObjectContext.self) { diResolver in
            let settings = diResolver.resolve(Settings.self)!

            let container = NSPersistentContainer(name: settings.storeName)
            container.loadPersistentStores(completionHandler: { _, error in
                if let error = error as NSError? {
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            })
            return container.viewContext
        }
        .inObjectScope(.container)

        container.register(TrackerRepository.self) { _ in
            TrackerRepository()
        }
        .inObjectScope(.container)

        container.register(TrackerRecordRepository.self) { _ in
            TrackerRecordRepository()
        }
        .inObjectScope(.container)

        container.register(TrackerCategoryDataProvider.self) { diResolver in
            TrackerCategoryDataProviderCD(
                cdContext: diResolver.resolve(NSManagedObjectContext.self)!
            )
        }

        container.register(CreateCategoryController.self) { _ in
            CreateCategoryController(contentView: CreateCategoryView())
        }

        container.register(SelectCategoryController.self) { diResolver in
            SelectCategoryController(
                depsFactory: self,
                dataProvider: diResolver.resolve(TrackerCategoryDataProvider.self)!,
                contentView: SelectCategoryView()
            )
        }

        container.register(SelectScheduleController.self) { _ in
            SelectScheduleController(contentView: SelectScheduleView())
        }

        container.register(EditTrackerController.self) { diResolver in
            EditTrackerController(
                depsFactory: self,
                contentView: EditTrackerView(),
                trackerRepository: diResolver.resolve(TrackerRepository.self)!
            )
        }

        container.register(AddTrackerController.self) { diResolver in
            AddTrackerController(
                contentView: AddTrackerView(),
                editTrackerController: diResolver.resolve(EditTrackerController.self)!
            )
        }
        .inObjectScope(.transient)

        container.register(TrackerViewController.self) { diResolver in
            TrackerViewController(
                depsFactory: self,
                contentView: TrackerListView(),
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

extension SceneDelegate: TrackerViewControllerDepsFactory {
    func getAddController(
        parentDelegate: AddParentDelegateProtocol,
        selectedDate: DateWoTime
    ) -> AddTrackerController? {
        let addTrackerController = container.resolve(AddTrackerController.self)
        addTrackerController?.initData(parentDelegate: parentDelegate, selectedDate: selectedDate)
        return addTrackerController
    }
}

extension SceneDelegate: EditTrackerControllerDepsFactory {
    func getSelectScheduleController() -> SelectScheduleController? {
        container.resolve(SelectScheduleController.self)
    }

    func getSelectCategoryController() -> SelectCategoryController? {
        container.resolve(SelectCategoryController.self)
    }
}

extension SceneDelegate: SelectCategoryControllerDepsFactory {
    func getCreateCategoryController() -> CreateCategoryController? {
        container.resolve(CreateCategoryController.self)
    }
}
