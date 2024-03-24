import UIKit

protocol CreateCategoryControllerDelegate: AnyObject {
    func compliteCreate(category: TrackerCategory)
}

final class CreateCategoryController: UIViewController {
    weak var delegate: CreateCategoryControllerDelegate?

    private let contentView: CreateCategoryView

    var viewModel = CreateCategoryViewModel()

    init(contentView: CreateCategoryView) {
        self.contentView = contentView
        super.init(nibName: nil, bundle: nil)

        self.contentView.controller = self

        navigationItem.title = "CreateCategory.NavTitle"~
        navigationItem.hidesBackButton = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
       self.view = contentView
    }

    func compliteCreate() {
        delegate?.compliteCreate(category: viewModel.toCategory())
    }
}

class CreateCategoryViewModel {
    var name: String = ""

    func toCategory() -> TrackerCategory {
        TrackerCategory(
            id: UUID(),
            name: name
        )
    }
}
