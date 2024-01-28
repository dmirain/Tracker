import Foundation
import UIKit

protocol AddTrackerControllerDelegate: AnyObject {
    func compleateAdd(action: EditAction, controller: UIViewController)
}

final class AddTrackerController: UIViewController {
    private let contentView: AddTrackerView
    private let editTrackerController: EditTrackerController
    
    weak var delegate: AddTrackerControllerDelegate?
    
    init(
        contentView: AddTrackerView,
        editTrackerController: EditTrackerController
    ) {
        self.contentView = contentView
        self.editTrackerController = editTrackerController
        
        super.init(nibName: nil, bundle: nil)
        
        contentView.controller = self
        modalPresentationStyle = .popover
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
        editTrackerController.delegate = self
        editTrackerController.initData(editTrackerModel: EditTrackerViewModel(type: type))
        present(editTrackerController, animated: true)
    }
}

extension AddTrackerController: EditTrackerControllerDelegate {
    func compleateEdit(action: EditAction, controller: UIViewController) {
        controller.dismiss(animated: true)
        delegate?.compleateAdd(action: action, controller: self)
    }
}
