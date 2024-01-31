import Foundation
import UIKit

protocol EditTrackerViewDelegat: AnyObject {
    var viewModel: EditTrackerViewModel { get }

    func selectSchedule()
    func selectCategory()
    func nameChanged(_ name: String)
    func compleateEdit(action: EditAction)
}

private enum ViewSections: Int, CaseIterable {
    case name, properties, emoji, color, buttons
}

final class EditTrackerView: UIView {
    weak var controller: EditTrackerViewDelegat?

    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        view.translatesAutoresizingMaskIntoConstraints = false
        view.allowsMultipleSelection = true
        view.showsVerticalScrollIndicator = false

        view.register(NameCell.self, forCellWithReuseIdentifier: NameCell.reuseIdentifier)
        view.register(PropertiesCell.self, forCellWithReuseIdentifier: PropertiesCell.reuseIdentifier)
        view.register(EmojiCell.self, forCellWithReuseIdentifier: EmojiCell.reuseIdentifier)
        view.register(ColorCell.self, forCellWithReuseIdentifier: ColorCell.reuseIdentifier)
        view.register(ButtonsCell.self, forCellWithReuseIdentifier: ButtonsCell.reuseIdentifier)
        view.register(
            SectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SectionHeaderView.reuseIdentifier
        )

        return view
    }()

    init() {
        super.init(frame: .zero)
        backgroundColor = UIColor.ypWhite

        collectionView.dataSource = self
        collectionView.delegate = self

        addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            collectionView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 24),
            collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            collectionView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initData() {
        collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        collectionView.reloadData()
    }

    func refreshProperties() {
        collectionView.reloadItems(at: [IndexPath(row: 0, section: ViewSections.properties.rawValue)])
        refreshButtons()
    }

    func refreshButtons() {
        collectionView.reloadItems(at: [IndexPath(row: 0, section: ViewSections.buttons.rawValue)])
    }

    func compleateEdit(action: EditAction) {
        controller?.compleateEdit(action: action)
    }
}

extension EditTrackerView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        ViewSections.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let section = ViewSections(rawValue: section) else {
            assertionFailure("Unknown section \(section)")
            return 0
        }

        switch section {
        case .name:
            return 1
        case .properties:
            return 1
        case .emoji:
            return 18
        case .color:
            return 18
        case .buttons:
            return 1
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let section = ViewSections(rawValue: indexPath.section) else {
            assertionFailure("Unknown section \(indexPath.section)")
            return UICollectionViewCell()
        }

        switch section {
        case .name:
            return cellForName(collectionView, at: indexPath)
        case .properties:
            return cellForProperties(collectionView, at: indexPath)
        case .emoji:
            return cellForEmoji(collectionView, at: indexPath)
        case .color:
            return cellForColor(collectionView, at: indexPath)
        case .buttons:
            return cellForButtons(collectionView, at: indexPath)
        }
    }

    private func cellForName(_ collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: NameCell.reuseIdentifier,
            for: indexPath
        ) as? NameCell
        guard let cell else { return UICollectionViewCell() }
        cell.delegate = self
        cell.setName(name: controller?.viewModel.name ?? "")
        return cell
    }
    private func cellForProperties(
        _ collectionView: UICollectionView,
        at indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let controller else { return UICollectionViewCell() }

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PropertiesCell.reuseIdentifier,
            for: indexPath
        ) as? PropertiesCell
        guard let cell else { return UICollectionViewCell() }
        cell.delegate = self
        cell.setProperties(
            category: controller.viewModel.category,
            schedule: controller.viewModel.schedule,
            type: controller.viewModel.type
        )
        return cell
    }
    private func cellForEmoji(_ collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: EmojiCell.reuseIdentifier,
            for: indexPath
        ) as? EmojiCell
        guard let cell else { return UICollectionViewCell() }
        cell.delegate = self
        cell.setEmoji(
            Tracker.emoji(byIndex: indexPath.row),
            isSelected: controller?.viewModel.emojiIndex == indexPath.row
        )
        return cell
    }
    private func cellForColor(_ collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ColorCell.reuseIdentifier,
            for: indexPath
        ) as? ColorCell
        guard let cell else { return UICollectionViewCell() }
        cell.delegate = self
        cell.setColor(
            Tracker.color(byIndex: indexPath.row),
            isSelected: controller?.viewModel.colorIndex == indexPath.row
        )
        return cell
    }
    private func cellForButtons(_ collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ButtonsCell.reuseIdentifier,
            for: indexPath
        ) as? ButtonsCell
        guard let cell else { return UICollectionViewCell() }
        cell.delegate = self

        guard let viewModel = controller?.viewModel else { return cell }

        if viewModel.toTracker() == nil {
            cell.setButtonsState(to: .edit)
        } else {
            cell.setButtonsState(to: .save)
        }

        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard let section = ViewSections(rawValue: indexPath.section) else {
            assertionFailure("Unknown section \(indexPath.section)")
            return UICollectionViewCell()
        }

        var sectionTitle: String
        switch section {
        case .name:
            sectionTitle = ""
        case .properties:
            sectionTitle = ""
        case .emoji:
            sectionTitle = "Emoji"
        case .color:
            sectionTitle = "Цвет"
        case .buttons:
            sectionTitle = ""
        }

        let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: SectionHeaderView.reuseIdentifier,
            for: indexPath
        ) as? SectionHeaderView
        guard let view else { return UICollectionViewCell() }

        view.setTitle(sectionTitle, spacing: 24)

        return view
    }
}

extension EditTrackerView: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _: UICollectionView,
        layout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt: Int
    ) -> CGFloat {
        0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        guard let section = ViewSections(rawValue: indexPath.section) else {
            assertionFailure("Unknown section \(indexPath.section)")
            return CGSize()
        }

        switch section {
        case .name:
            return CGSize(width: collectionView.bounds.width, height: 75)
        case .properties:
            return CGSize(
                width: collectionView.bounds.width,
                height: controller?.viewModel.type == .habit ? 150 : 75
            )
        case .emoji:
            return CGSize(width: collectionView.bounds.width / 6, height: 52)
        case .color:
            return CGSize(width: collectionView.bounds.width / 6, height: 52)
        case .buttons:
            return CGSize(width: collectionView.bounds.width, height: 60)
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        guard let section = ViewSections(rawValue: section) else {
            assertionFailure("Unknown section \(section)")
            return CGSize()
        }
        switch section {
        case .name:
            return CGSize(width: collectionView.frame.width, height: 0)
        case .properties:
            return CGSize(width: collectionView.frame.width, height: 24)
        case .emoji:
            return CGSize(width: collectionView.frame.width, height: 74)
        case .color:
            return CGSize(width: collectionView.frame.width, height: 82)
        case .buttons:
            return CGSize(width: collectionView.frame.width, height: 40)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let controller, let section = ViewSections(rawValue: indexPath.section) else {
            assertionFailure("Unknown section \(indexPath.section)")
            return
        }

        switch section {
        case .name:
            return
        case .properties:
            return
        case .emoji:
            let oldIndexPath = IndexPath(row: controller.viewModel.emojiIndex, section: section.rawValue)
            controller.viewModel.emojiIndex = indexPath.row
            collectionView.reloadItems(at: [indexPath, oldIndexPath])
        case .color:
            let oldIndexPath = IndexPath(row: controller.viewModel.colorIndex, section: section.rawValue)
            controller.viewModel.colorIndex = indexPath.row
            collectionView.reloadItems(at: [indexPath, oldIndexPath])
        case .buttons:
            return
        }
    }
}

extension EditTrackerView {
    func selectSchedule() {
        controller?.selectSchedule()
    }

    func selectCategory() {
        controller?.selectCategory()
    }

    func nameChanged(_ name: String) {
        controller?.nameChanged(name)
    }
}
