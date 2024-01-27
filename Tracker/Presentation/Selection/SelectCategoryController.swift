import Foundation
import UIKit

final class SelectCategoryController: UIViewController {
    private let contentView: SelectCategoryView

    init(contentView: SelectCategoryView) {
        self.contentView = contentView
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
       self.view = contentView
    }
}
