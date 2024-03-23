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

        container.register(TrackerStore.self) { diResolver in
            TrackerStoreCD(
                cdContext: diResolver.resolve(NSManagedObjectContext.self)!
            )
        }
        .inObjectScope(.container)

        container.register(TrackerCategoryStore.self) { diResolver in
            TrackerCategoryStoreCD(
                cdContext: diResolver.resolve(NSManagedObjectContext.self)!
            )
        }

        container.register(CreateCategoryController.self) { _ in
            CreateCategoryController(contentView: CreateCategoryView())
        }

        container.register(SelectFilterController.self) { _ in
            SelectFilterController(
                contentView: SelectFilterView()
            )
        }

        container.register(SelectCategoryViewModel.self) { diResolver in
            SelectCategoryViewModelImpl(
                store: diResolver.resolve(TrackerCategoryStore.self)!
            )
        }

        container.register(SelectCategoryController.self) { diResolver in
            SelectCategoryController(
                depsFactory: self,
                viewModel: diResolver.resolve(SelectCategoryViewModel.self)!,
                contentView: SelectCategoryView()
            )
        }

        container.register(SelectScheduleController.self) { _ in
            SelectScheduleController(contentView: SelectScheduleView())
        }

        container.register(EditTrackerController.self) { _ in
            EditTrackerController(
                depsFactory: self,
                contentView: EditTrackerView()
            )
        }

        container.register(AddTrackerController.self) { diResolver in
            AddTrackerController(
                contentView: AddTrackerView(),
                editTrackerController: diResolver.resolve(EditTrackerController.self)!
            )
        }
        .inObjectScope(.transient)

        container.register(TrackerListViewController.self) { diResolver in
            TrackerListViewController(
                depsFactory: self,
                contentView: TrackerListView(),
                trackerStore: diResolver.resolve(TrackerStore.self)!
            )
        }

        container.register(StatisticViewController.self) { _ in
            StatisticViewController()
        }

        container.register(TabBarController.self) { diResolver in
            TabBarController(
                trackerViewController: diResolver.resolve(TrackerListViewController.self)!,
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

        if let controller = OnboardingManager(storage: OnboardingStorageImpl()).forShow() {
            controller.flowDelegate = self
            window?.rootViewController = controller
            window?.makeKeyAndVisible()
        } else {
            showMainController()
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}

    private func showMainController() {
        window?.rootViewController = container.resolve(TabBarController.self)
        window?.makeKeyAndVisible()
    }
}

extension SceneDelegate: OnboardingControllerDelegate {
    func close() {
        showMainController()
    }
}

extension SceneDelegate: TrackerViewControllerDepsFactory {
    func editTrackerController(
        parentDelegate: AddParentDelegateProtocol,
        editTrackerModel: EditTrackerViewModel
    ) -> EditTrackerController? {
        let editTrackerController = container.resolve(EditTrackerController.self)
        editTrackerController?.initData(parentDelegate: parentDelegate, editTrackerModel: editTrackerModel)
        return editTrackerController
    }

    func getAddController(
        parentDelegate: AddParentDelegateProtocol,
        selectedDate: DateWoTime
    ) -> AddTrackerController? {
        let addTrackerController = container.resolve(AddTrackerController.self)
        addTrackerController?.initData(parentDelegate: parentDelegate, selectedDate: selectedDate)
        return addTrackerController
    }

    func selectFilterController(delegate: SelectFilterControllerDelegate, currentFilter: TrackerFilter) -> SelectFilterController? {
        let selectFilterController = container.resolve(SelectFilterController.self)
        selectFilterController?.initData(currentFilter: currentFilter)
        selectFilterController?.delegate = delegate
        return selectFilterController
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
