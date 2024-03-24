import UIKit

final class StatisticViewController: UIViewController {
    private let contentView: StatisticView

    init(contentView: StatisticView) {
        self.contentView = contentView
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
        contentView.initData(StatisticData(
            bestPeriod: Int.random(in: 0...10),
            bestDaysCount: Int.random(in: 0...10),
            completed: Int.random(in: 0...10),
            averageValue: Int.random(in: 0...10)
        ))
    }
}

struct StatisticData {
    let bestPeriod: Int
    let bestDaysCount: Int
    let completed: Int
    let averageValue: Int
}
