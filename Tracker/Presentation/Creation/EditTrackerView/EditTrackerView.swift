import Foundation
import UIKit

protocol EditTrackerViewDelegat: AnyObject {
    var viewModel: EditTrackerViewModel { get }

    func selectSchedule()
    func selectCategory()
    func compleateEdit(action: EditAction)
}


final class EditTrackerView: UIView {
    weak var controller: EditTrackerViewDelegat?

    private lazy var header: UINavigationBar = {
        let view = UINavigationBar()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.barTintColor = .ypWhite
        view.setBackgroundImage(UIImage(), for: .default)
        view.shadowImage = UIImage()
                
        let navItem = UINavigationItem()
        navItem.title = "Новая привычка"
        
        view.setItems([navItem], animated: false)
        
        return view
    }()

    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        view.translatesAutoresizingMaskIntoConstraints = false
        view.allowsMultipleSelection = true
        
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

        addSubview(header)
        addSubview(collectionView)

        NSLayoutConstraint.activate([
            header.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            header.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            header.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            collectionView.topAnchor.constraint(equalTo: header.bottomAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            collectionView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initData() {
        collectionView.reloadData()
    }
    
    func refreshProperties() {
        collectionView.reloadItems(at: [IndexPath(row: 0, section: 1)])
    }
    
    func compleateEdit(action: EditAction) {
        controller?.compleateEdit(action: action)
    }
}

extension EditTrackerView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        5
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0: return 1  // name
        case 1: return 1  // category + schedule
        case 2: return 18 // emoji
        case 3: return 18 // color
        case 4: return 1  // buttons
        default: 
            assertionFailure("Uncnown section")
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0: return cellForName(collectionView, at: indexPath)  // name
        case 1: return cellForProperties(collectionView, at: indexPath)  // category + schedule
        case 2: return cellForEmoji(collectionView, at: indexPath) // emoji
        case 3: return cellForColor(collectionView, at: indexPath) // color
        case 4: return cellForButtons(collectionView, at: indexPath)  // buttons
        default: 
            assertionFailure("Uncnown section")
            return UICollectionViewCell()
        }
    }
    
    func cellForName(_ collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: NameCell.reuseIdentifier,
            for: indexPath
        ) as? NameCell
        guard let cell else { return UICollectionViewCell() }
        cell.delegate = self
        cell.setName(name: controller?.viewModel.name ?? "")
        return cell
    }
    func cellForProperties(_ collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
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
    func cellForEmoji(_ collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
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
    func cellForColor(_ collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
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
    func cellForButtons(_ collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ButtonsCell.reuseIdentifier,
            for: indexPath
        ) as? ButtonsCell
        guard let cell else { return UICollectionViewCell() }
        cell.delegate = self
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        var sectionTitle: String
        switch indexPath.section {
        case 2: sectionTitle = "Emoji"
        case 3: sectionTitle = "Цвет"
        default: sectionTitle = ""
        }
        
        guard !sectionTitle.isEmpty && kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: SectionHeaderView.reuseIdentifier,
            for: indexPath
        ) as! SectionHeaderView
        
        view.titleLabel.text = sectionTitle

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
        
        switch indexPath.section {
        case 0: return CGSize(width: collectionView.bounds.width, height: 75)  // name
        case 1: return CGSize(width: collectionView.bounds.width, height: 174)  // category + schedule
        case 2: return CGSize(width: collectionView.bounds.width / 6, height: 52) // emoji
        case 3: return CGSize(width: collectionView.bounds.width / 6, height: 52) // color
        case 4: return CGSize(width: collectionView.bounds.width, height: 100)  // buttons
        default:
            assertionFailure("Uncnown section")
            return CGSize()
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        if [2, 3].contains(section) {
            return CGSize(width: collectionView.frame.width, height: 70)
        }
        return CGSize()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let controller else { return }

        switch indexPath.section {
        case 2:
            let oldIndexPath = IndexPath(row: controller.viewModel.emojiIndex, section: 2)
            controller.viewModel.emojiIndex = indexPath.row
            collectionView.reloadItems(at: [indexPath, oldIndexPath])
        case 3:
            let oldIndexPath = IndexPath(row: controller.viewModel.colorIndex, section: 3)
            controller.viewModel.colorIndex = indexPath.row
            collectionView.reloadItems(at: [indexPath, oldIndexPath])
        default:
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
}