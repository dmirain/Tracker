import UIKit

final class StatisticView: UIView {

    private lazy var header: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.text = "Statistic.header"~
        view.textColor = .ypBlack
        view.font = UIFont.systemFont(ofSize: 34, weight: .heavy)
        return view
    }()

    private lazy var rowBestPeriod: StatisticRowView = {
        let view = StatisticRowView(title: "Statistic.rowBestPeriod"~)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private lazy var rowBestDaysCount: StatisticRowView = {
        let view = StatisticRowView(title: "Statistic.rowBestDaysCount"~)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private lazy var rowCompleted: StatisticRowView = {
        let view = StatisticRowView(title: "Statistic.rowCompleted"~)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private lazy var rowAverageValue: StatisticRowView = {
        let view = StatisticRowView(title: "Statistic.rowAverageValue"~)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var rows: UIStackView = {
        let view = UIStackView(arrangedSubviews: [
            rowBestPeriod, rowBestDaysCount, rowCompleted, rowAverageValue
        ])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.alignment = .leading
        view.distribution = .equalSpacing
        view.spacing = 12
        return view
    }()

    private lazy var emptyListView: UIView = {
        let view = EmptyListView(text: "Statistic.emptyList"~, image: .emptyStat)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var container: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(rows)
        NSLayoutConstraint.activate([
            rows.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            rows.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            rows.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        return view
    }()

    init() {
        super.init(frame: .zero)

        backgroundColor = .ypWhite
        addSubview(header)
        addSubview(container)
        addSubview(emptyListView)

        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 44),
            header.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),

            container.topAnchor.constraint(equalTo: header.bottomAnchor),
            container.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            container.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            container.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor),

            emptyListView.topAnchor.constraint(equalTo: header.bottomAnchor),
            emptyListView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            emptyListView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            emptyListView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initData(_ data: StatisticData) {
        if data.bestPeriod + data.bestDaysCount + data.completed + data.averageValue == 0 {
            emptyListView.isHidden = false
        } else {
            emptyListView.isHidden = true
            rowBestPeriod.initData(value: data.bestPeriod)
            rowBestDaysCount.initData(value: data.bestDaysCount)
            rowCompleted.initData(value: data.completed)
            rowAverageValue.initData(value: data.averageValue)
        }
    }

    func addGradienBorder() {
        rows.arrangedSubviews.forEach {
            $0.layer.addGradienBorder(colors: [.ypGLeft, .ypGCenter, .ypGRight], width: 1)
        }
    }
}
