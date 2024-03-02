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
    private var dataProvider: TrackerCategoryDataProvider
    private let contentView: SelectCategoryView

    weak var delegate: SelectCategoryControllerDelegate?

    var currentCategory: TrackerCategory?

    init(
        depsFactory: SelectCategoryControllerDepsFactory,
        dataProvider: TrackerCategoryDataProvider,
        contentView: SelectCategoryView
    ) {
        self.depsFactory = depsFactory
        self.dataProvider = dataProvider
        self.contentView = contentView
        super.init(nibName: nil, bundle: nil)

        self.dataProvider.delegate = self
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
            try dataProvider.fetchData()
        } catch {
            assertionFailure(error.localizedDescription)
        }

        contentView.initData()
    }
}

extension SelectCategoryController: DataProviderDelegate {
    func dataProvider(didUpdate update: DataProviderUpdate) {
        contentView.update(update)
    }
}

extension SelectCategoryController: SelectCategoryViewDelegate {
    func numberOfRowsInSection(_ section: Int) -> Int {
        dataProvider.numberOfRowsInSection(section)
    }
    func category(byIndexPath indexPath: IndexPath) -> TrackerCategory? {
        dataProvider.object(atIndexPath: indexPath)
    }
    func completeSelect(withIndexPath indexPath: IndexPath) {
        guard let category = dataProvider.object(atIndexPath: indexPath) else { return }
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
        dataProvider.add(category)
        navigationController?.popViewController(animated: true)
    }
}
