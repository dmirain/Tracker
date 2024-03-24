import UIKit

final class AddTrackerController: UIViewController {
    private let contentView: AddTrackerView
    private let editTrackerController: EditTrackerController

    private var selectedDate = DateWoTime()
    private weak var parentDelegate: AddParentDelegateProtocol?

    init(
        contentView: AddTrackerView,
        editTrackerController: EditTrackerController
    ) {
        self.contentView = contentView
        self.editTrackerController = editTrackerController

        super.init(nibName: nil, bundle: nil)

        contentView.controller = self

        navigationItem.title = "AddTracker.NavTitle"~
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
       self.view = contentView
    }

    func initData(parentDelegate: AddParentDelegateProtocol, selectedDate: DateWoTime) {
        self.parentDelegate = parentDelegate
        self.selectedDate = selectedDate
    }
}

extension AddTrackerController: AddTrackerViewDelegate {
    func createClicked(type: TrackerType) {
        guard let parentDelegate else { return }
        editTrackerController.initData(
            parentDelegate: parentDelegate,
            editTrackerModel: EditTrackerViewModel(type: type, selectedDate: selectedDate)
        )
        navigationController?.pushViewController(editTrackerController, animated: true)
    }
}
