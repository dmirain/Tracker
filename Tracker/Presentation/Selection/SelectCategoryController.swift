import Foundation
import UIKit

protocol SelectCategoryControllerDepsFactory {
    func getCreateCategoryController() -> CreateCategoryController?
}

protocol SelectCategoryControllerDelegate: AnyObject {
    func set(category: TrackerCategory)
}

final class SelectCategoryController: UIViewController {
    private let depsFactory: SelectCategoryControllerDepsFactory
    private var store: TrackerCategoryStore
    private let contentView: SelectCategoryView

    weak var delegate: SelectCategoryControllerDelegate?

    var currentCategory: TrackerCategory?

    init(
        depsFactory: SelectCategoryControllerDepsFactory,
        store: TrackerCategoryStore,
        contentView: SelectCategoryView
    ) {
        self.depsFactory = depsFactory
        self.store = store
        self.contentView = contentView
        super.init(nibName: nil, bundle: nil)

        self.store.delegate = self
        self.contentView.controller = self

        navigationItem.title = "Категория"
        navigationItem.hidesBackButton = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
       self.view = contentView
    }

    func initData(category: TrackerCategory?) {
        self.currentCategory = category

        do {
            try store.fetchData()
        } catch {
            assertionFailure(error.localizedDescription)
        }

        contentView.initData()
    }
}

extension SelectCategoryController: StoreDelegate {
    func store(didUpdate update: StoreUpdate) {
        contentView.update(update)
    }
}

extension SelectCategoryController: SelectCategoryViewDelegate {
    func numberOfRowsInSection(_ section: Int) -> Int {
        store.numberOfRowsInSection(section)
    }
    func category(byIndexPath indexPath: IndexPath) -> TrackerCategory? {
        store.object(atIndexPath: indexPath)
    }
    func completeSelect(withIndexPath indexPath: IndexPath) {
        guard let category = store.object(atIndexPath: indexPath) else { return }
        delegate?.set(category: category)
    }

    func createClicked() {
        let createCategoryController = depsFactory.getCreateCategoryController()
        guard let createCategoryController else { return }
        createCategoryController.delegate = self
        navigationController?.pushViewController(createCategoryController, animated: true)
    }
}

extension SelectCategoryController: CreateCategoryControllerDelegate {
    func compliteCreate(category: TrackerCategory) {
        store.add(category)
        navigationController?.popViewController(animated: true)
    }
}
