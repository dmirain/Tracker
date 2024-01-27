import Foundation
import UIKit

final class SelectScheduleController: UIViewController {
    private let contentView: SelectScheduleView

    init(contentView: SelectScheduleView) {
        self.contentView = contentView
        super.init(nibName: nil, bundle: nil)

        modalPresentationStyle = .popover
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
       self.view = contentView
    }
}
