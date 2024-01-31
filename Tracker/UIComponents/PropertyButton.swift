import UIKit

final class PropertyButton: UIButton {

    private lazy var separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .ypGray

        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 0.3)
        ])

        return view
    }()

    private lazy var rightArrowView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = .rightArrow

        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 24),
            view.widthAnchor.constraint(equalToConstant: 24)
        ])

        return view
    }()

    private lazy var titleView: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .ypBlack
        view.font = UIFont.systemFont(ofSize: 17)
        return view
    }()

    private lazy var subTitleView: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.systemFont(ofSize: 17)
        view.textColor = .ypGray
        view.isHidden = true
        return view
    }()

    private lazy var titleStack: UIStackView = {
        let view = UIStackView(arrangedSubviews: [titleView, subTitleView])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.spacing = 2
        view.distribution = .fillEqually
        view.alignment = .leading
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .ypBackground

        addSubview(titleStack)
        addSubview(rightArrowView)

        NSLayoutConstraint.activate([
            titleStack.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),

            rightArrowView.centerYAnchor.constraint(equalTo: centerYAnchor),
            rightArrowView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setTitle(_ title: String?, for state: UIControl.State) {
        titleView.text = title
    }

    func setSubTitle(_ title: String?) {
        subTitleView.isHidden = title?.isEmpty ?? true
        subTitleView.text = title
    }

    func addSeparator() {
        addSubview(separatorView)

        NSLayoutConstraint.activate([
            separatorView.topAnchor.constraint(equalTo: topAnchor),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }
}
