import UIKit

final class EmptyListView: UIView {
    private let text: String

    private lazy var image: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = UIImage.emptyList
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: 80),
            view.heightAnchor.constraint(equalToConstant: 80)
        ])
        return view
    }()

    private lazy var lable: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 2
        view.textAlignment = .center
        view.text = text
        view.textColor = .ypBlack
        view.font = view.font.withSize(12)
        return view
    }()

    private lazy var rows: UIStackView = {
        let view = UIStackView(arrangedSubviews: [image, lable])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.alignment = .center
        view.distribution = .equalSpacing
        view.spacing = 8
        return view
    }()

    init(text: String) {
        self.text = text

        super.init(frame: .zero)

        backgroundColor = .ypWhite
        addSubview(rows)
        NSLayoutConstraint.activate([
            rows.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            rows.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
