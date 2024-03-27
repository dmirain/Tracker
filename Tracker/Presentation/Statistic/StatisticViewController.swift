import UIKit

final class StatisticViewController: UIViewController {
    private let contentView: StatisticView
    private var trackerStore: TrackerStore

    init(contentView: StatisticView, trackerStore: TrackerStore) {
        self.contentView = contentView
        self.trackerStore = trackerStore
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
       self.view = contentView
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        contentView.initData(calculateData())
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        contentView.addGradienBorder()
    }

    private func calculateData() -> StatisticData {
        let records = trackerStore.fetchAllRecords()
        let grouped = Dictionary(grouping: records) { $0.date }.mapValues { items in items.count }

        return StatisticData(
            bestPeriod: 0,
            bestDaysCount: 0,
            completed: records.count,
            averageValue: grouped.isEmpty ? 0 : grouped.values.reduce(0, +) / grouped.count
        )
    }
}

struct StatisticData {
    let bestPeriod: Int
    let bestDaysCount: Int
    let completed: Int
    let averageValue: Int
}
