import Foundation
import UIKit

final class AddTrackerController: UIViewController {
    private let contentView: AddTrackerView
    private let editTrackerController: EditTrackerController

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
}

extension AddTrackerController: AddTrackerViewDelegat {
    func createClicked(type: TrackerType) {
        editTrackerController.initData(editTrackerModel: EditTrackerViewModel(type: type))
        navigationController?.pushViewController(editTrackerController, animated: true)
    }
}
