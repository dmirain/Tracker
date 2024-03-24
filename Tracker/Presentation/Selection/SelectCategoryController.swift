import UIKit

protocol SelectCategoryControllerDepsFactory {
    func getCreateCategoryController() -> CreateCategoryController?
}

protocol SelectCategoryControllerDelegate: AnyObject {
    func set(category: TrackerCategory)
}

final class SelectCategoryController: UIViewController {
    private let depsFactory: SelectCategoryControllerDepsFactory
    private var viewModel: SelectCategoryViewModel
    private let contentView: SelectCategoryView

    weak var delegate: SelectCategoryControllerDelegate?

    init(
        depsFactory: SelectCategoryControllerDepsFactory,
        viewModel: SelectCategoryViewModel,
        contentView: SelectCategoryView
    ) {
        self.depsFactory = depsFactory
        self.viewModel = viewModel
        self.contentView = contentView
        super.init(nibName: nil, bundle: nil)

        self.contentView.controller = self

        navigationItem.title = "SelectCategory.NavTitle"~
        navigationItem.hidesBackButton = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
       self.view = contentView
    }

    func initData(category: TrackerCategory?) {
        viewModel.categoriesBinding = { [weak self] _ in
            self?.contentView.reloadData()
        }
        viewModel.initData(category: category)
    }
}

extension SelectCategoryController: SelectCategoryViewDelegate {
    func numberOfRowsInSection(_ section: Int) -> Int {
        viewModel.categories.count
    }
    func rowViewModel(byIndexPath indexPath: IndexPath) -> SelectCategoryRowViewModel? {
        viewModel.categories[indexPath.row]
    }
    func completeSelect(withIndexPath indexPath: IndexPath) {
        guard let rowViewModel = rowViewModel(byIndexPath: indexPath) else { return }
        viewModel.selectedCategory = rowViewModel.category
        delegate?.set(category: rowViewModel.category)
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
        viewModel.add(category)
        navigationController?.popViewController(animated: true)
    }
}
