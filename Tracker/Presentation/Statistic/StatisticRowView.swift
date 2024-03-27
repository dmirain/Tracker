import UIKit

final class StatisticRowView: UIView {
    private let title: String

    private lazy var number: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.text = "0"
        view.textColor = .ypBlack
        view.font = UIFont.boldSystemFont(ofSize: 34)
        return view
    }()

    private lazy var titleView: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.text = title
        view.textColor = .ypBlack
        view.font = UIFont.systemFont(ofSize: 12)
        return view
    }()

    private lazy var rows: UIStackView = {
        let view = UIStackView(arrangedSubviews: [number, titleView])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.alignment = .leading
        view.distribution = .equalSpacing
        view.spacing = 7
        return view
    }()

    init(title: String) {
        self.title = title

        super.init(frame: .zero)

        backgroundColor = .ypWhite
        addSubview(rows)

        NSLayoutConstraint.activate([
            self.widthAnchor.constraint(equalToConstant: .greatestFiniteMagnitude),

            rows.topAnchor.constraint(equalTo: self.topAnchor, constant: 12),
            rows.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12),
            rows.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -12),
            rows.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initData(value: Int) {
        number.text = String(value)
    }
}
