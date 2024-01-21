import Foundation

final class CategoryRepository {
    private var categories = [TrackerCategory]()

    func create(_ new: TrackerCategory) {
        categories.append(new)
    }
    
    func all() -> [TrackerCategory] {
        return categories
    }
}
