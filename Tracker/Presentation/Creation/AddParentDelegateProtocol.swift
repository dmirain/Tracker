import UIKit

protocol AddParentDelegateProtocol: AnyObject {
    func compleateAdd(action: EditAction, newTracker: Tracker?)
}
