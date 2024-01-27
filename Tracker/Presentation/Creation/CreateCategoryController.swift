import Foundation
import UIKit

final class CreateCategoryController: UIViewController {
    private let contentView: CreateCategoryView

    init(contentView: CreateCategoryView) {
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
