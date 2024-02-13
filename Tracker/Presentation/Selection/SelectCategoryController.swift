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
    private let contentView: SelectCategoryView

    weak var delegate: SelectCategoryControllerDelegate?

    var category: TrackerCategory?

    init(
        depsFactory: SelectCategoryControllerDepsFactory,
        contentView: SelectCategoryView
    ) {
        self.depsFactory = depsFactory
        self.contentView = contentView
        super.init(nibName: nil, bundle: nil)

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
        self.category = category
        contentView.initData()
    }
}

extension SelectCategoryController: SelectCategoryViewDelegate {
    func numberOfRows() -> Int {
        categories.count
    }

    func category(byIndex index: Int) -> TrackerCategory {
        categories[index]
    }

    func createClicked() {}

    func completeSelect(withIndex index: Int) {
        let category = categories[index]
        delegate?.set(category: category)
    }
}

// TODO: убрать заглушку
private let categories: [TrackerCategory] = [
    TrackerCategory(name: "Home"),
    TrackerCategory(name: "Work")
]
