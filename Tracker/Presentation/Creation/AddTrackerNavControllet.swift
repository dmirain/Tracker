import UIKit

protocol AddTrackerNavControlletDelegate: AnyObject {
    func compleateAdd(action: EditAction)
}

class AddTrackerNavControllet: UINavigationController {
    weak var parentDelegate: AddTrackerNavControlletDelegate?

    func compleateEdit(action: EditAction) {
        parentDelegate?.compleateAdd(action: action)
    }
}
