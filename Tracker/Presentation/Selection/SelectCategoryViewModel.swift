import Foundation

protocol SelectCategoryViewModel {
    var categories: [SelectCategoryRowViewModel] { get }
    var categoriesBinding: Binding<[SelectCategoryRowViewModel]>? { get set }
    var selectedCategory: TrackerCategory? { get set }

    func initData(category: TrackerCategory?)
    func add(_ category: TrackerCategory)
}

final class SelectCategoryViewModelImpl: SelectCategoryViewModel {
    var categories: [SelectCategoryRowViewModel] = [] {
        didSet {
            categoriesBinding?(categories)
        }
    }
    var categoriesBinding: Binding<[SelectCategoryRowViewModel]>?

    var selectedCategory: TrackerCategory? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.fetchCategories()
            }
        }
    }

    private var store: TrackerCategoryStore

    init(store: TrackerCategoryStore) {
        self.store = store
        self.store.delegate = self
    }

    func initData(category: TrackerCategory?) {
        do {
            try store.fetchData()
        } catch {
            assertionFailure(error.localizedDescription)
        }
        self.selectedCategory = category
    }

    func add(_ category: TrackerCategory) {
        store.add(category)
    }

    private func fetchCategories() {
        let numOfRows = store.numberOfRowsInSection(0)
        categories = (0..<numOfRows)
            .compactMap {
                if let category = store.object(atIndexPath: IndexPath(row: $0, section: 0)) {
                    return SelectCategoryRowViewModel(category: category, isSelected: category == selectedCategory)
                }
                return nil
            }
    }
}

extension SelectCategoryViewModelImpl: StoreDelegate {
    func store(didUpdate update: StoreUpdate) {
        fetchCategories()
    }
}

struct SelectCategoryRowViewModel {
    let category: TrackerCategory
    let isSelected: Bool
}
