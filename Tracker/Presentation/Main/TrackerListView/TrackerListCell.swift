import UIKit

final class TrackerListCell: UICollectionViewCell {
    static let reuseIdentifier = "TrackerListCell"
    weak var delegate: TrackerListView?

    private var trackerViewModel: TrackerViewModel?

    private lazy var emojiLable: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false

        view.backgroundColor = .ypWhite30
        view.text = "🌺"
        view.textAlignment = .center
        view.font = UIFont.systemFont(ofSize: 12)

        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true

        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 24),
            view.widthAnchor.constraint(equalToConstant: 24)
        ])

        return view
    }()

    private lazy var nameLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 2

        view.text = "TrackerList.Cell.nameLabel"~
        view.textColor = .ypWhite
        view.font = view.font.withSize(12)

        return view
    }()

    private lazy var pinImage: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = .pin

        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 24),
            view.widthAnchor.constraint(equalToConstant: 24)
        ])

        return view
    }()

    private lazy var periodeLable: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false

        view.text = ""
        view.font = view.font.withSize(12)

        return view
    }()

    private lazy var compliteButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .ypColorSelection01

        view.imageEdgeInsets = UIEdgeInsets(top: 11, left: 11, bottom: 11, right: 11)

        view.layer.cornerRadius = 17
        view.layer.masksToBounds = true

        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 34),
            view.widthAnchor.constraint(equalToConstant: 34)
        ])

        view.addTarget(self, action: #selector(compliteButtonClicked), for: .touchUpInside)

        return view
    }()

    private lazy var nameView: UIControl = {
        let view = UIControl()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .ypColorSelection01

        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true

        view.addSubview(emojiLable)
        view.addSubview(nameLabel)
        view.addSubview(pinImage)

        view.addInteraction(UIContextMenuInteraction(delegate: self))

        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 90),

            emojiLable.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            emojiLable.topAnchor.constraint(equalTo: view.topAnchor, constant: 12),

            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            nameLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -12),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),

            pinImage.topAnchor.constraint(equalTo: view.topAnchor, constant: 12),
            pinImage.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -4)
        ])
        return view
    }()

    private lazy var stateView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(periodeLable)
        view.addSubview(compliteButton)

        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 50),

            periodeLable.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            periodeLable.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            compliteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            compliteButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(nameView)
        contentView.addSubview(stateView)

        NSLayoutConstraint.activate([
            nameView.topAnchor.constraint(equalTo: contentView.topAnchor),
            nameView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nameView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            stateView.topAnchor.constraint(equalTo: nameView.bottomAnchor),
            stateView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stateView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stateView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initData(trackerViewModel: TrackerViewModel) {
        self.trackerViewModel = trackerViewModel

        emojiLable.text = trackerViewModel.tracker.emoji
        nameLabel.text = trackerViewModel.tracker.name
        periodeLable.text = String.localizedStringWithFormat("numberOfDay"~, trackerViewModel.complitionsCount)

        if trackerViewModel.isComplited {
            compliteButton.setImage(.complited, for: .normal)
            compliteButton.layer.opacity = 0.3
        } else {
            compliteButton.setImage(.toComplite, for: .normal)
            compliteButton.layer.opacity = 1
        }

        compliteButton.backgroundColor = trackerViewModel.tracker.color
        nameView.backgroundColor = trackerViewModel.tracker.color

        compliteButton.isEnabled = DateWoTime() >= trackerViewModel.selectedDate

        pinImage.isHidden = !trackerViewModel.tracker.isPinned
    }

    @objc
    private func compliteButtonClicked() {
        guard let delegate else { return }
        delegate.toggleComplete(self)
    }
}

extension TrackerListCell: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        configurationForMenuAtLocation location: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard let trackerViewModel else { return nil }

        let pinAction = trackerViewModel.tracker.isPinned ? "TrackerList.unpin"~ : "TrackerList.pin"~

        return UIContextMenuConfiguration(
            actionProvider: { _ in
                UIMenu(children: [
                    UIAction(title: pinAction) { [weak self] _ in
                        guard let self else { return }
                        self.delegate?.togglePin(self)
                    },
                    UIAction(title: "TrackerList.edit"~) { [weak self] _ in
                        guard let self else { return }
                        self.delegate?.editTrackerClicked(self)
                    },
                    UIAction(title: "TrackerList.delete"~, attributes: .destructive) { [weak self] _ in
                        guard let self else { return }
                        self.delegate?.deleteTracker(self)
                    }
                ])
            }
        )
    }
}
