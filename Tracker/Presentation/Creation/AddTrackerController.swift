import Foundation
import UIKit

final class AddTrackerController: UIViewController {
    private let contentView: AddTrackerView
    private let editTrackerController: EditTrackerController

    private var selectedDate = DateWoTime()
    private weak var parentDelegat: AddParentDelegateProtocol?

    init(
        contentView: AddTrackerView,
        editTrackerController: EditTrackerController
    ) {
        self.contentView = contentView
        self.editTrackerController = editTrackerController

        super.init(nibName: nil, bundle: nil)

        contentView.controller = self

        navigationItem.title = "Создание трекера"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
       self.view = contentView
    }

    func initData(parentDelegat: AddParentDelegateProtocol, selectedDate: DateWoTime) {
        self.parentDelegat = parentDelegat
        self.selectedDate = selectedDate
    }
}

extension AddTrackerController: AddTrackerViewDelegat {
    func createClicked(type: TrackerType) {
        guard let parentDelegat else { return }
        editTrackerController.initData(
            parentDelegat: parentDelegat,
            editTrackerModel: EditTrackerViewModel(type: type, selectedDate: selectedDate)
        )
        navigationController?.pushViewController(editTrackerController, animated: true)
    }
}
