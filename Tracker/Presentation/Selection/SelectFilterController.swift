import UIKit

protocol SelectFilterControllerDelegate: AnyObject {
    func set(filter: TrackerFilter)
}

final class SelectFilterController: UIViewController {
    private let contentView: SelectFilterView
    var currentFilter = TrackerFilter.all

    weak var delegate: SelectFilterControllerDelegate?

    init(contentView: SelectFilterView) {
        self.contentView = contentView
        super.init(nibName: nil, bundle: nil)

        self.contentView.controller = self

        navigationItem.title = "Фильтры"
        navigationItem.hidesBackButton = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
       self.view = contentView
    }

    func initData(currentFilter: TrackerFilter) {
        self.currentFilter = currentFilter
    }
}

extension SelectFilterController: SelectFilterViewDelegate {
    func completeSelect(withIndexPath indexPath: IndexPath) {
        let filter = TrackerFilter.allCases[indexPath.row]
        delegate?.set(filter: filter)
    }
}
