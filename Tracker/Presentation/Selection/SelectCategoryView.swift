import Foundation
import UIKit

protocol SelectCategoryViewDelegate: AnyObject {
    var category: TrackerCategory? { get set }

    func numberOfRows() -> Int
    func category(byIndex: Int) -> TrackerCategory

    func completeSelect(withIndex: Int)
    func createClicked()
}

final class SelectCategoryView: UIView {
    weak var controller: SelectCategoryViewDelegate?

    private lazy var categoriesTable: UITableView = {
        let view = UITableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .ypWhite
        view.separatorStyle = .singleLine
        view.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        view.tableHeaderView = UIView()

        view.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.reuseIdentifier)
        view.dataSource = self
        view.delegate = self

        return view
    }()

    private lazy var createButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.backgroundColor = .ypBlack
        view.setTitle("Добавить категорию", for: .normal)
        view.setTitleColor(.ypWhite, for: .normal)

        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 60)
        ])

        view.addTarget(self, action: #selector(createClicked), for: .touchUpInside)

        return view
    }()

    init() {
        super.init(frame: .zero)
        backgroundColor = .ypWhite

        addSubview(categoriesTable)
        addSubview(createButton)

        NSLayoutConstraint.activate([
            categoriesTable.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            categoriesTable.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            categoriesTable.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            categoriesTable.bottomAnchor.constraint(equalTo: createButton.topAnchor),

            createButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            createButton.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            createButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20)
        ])

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initData() {
        categoriesTable.reloadData()
    }

    @objc
    private func createClicked() {
        controller?.createClicked()
    }
}

extension SelectCategoryView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        controller?.numberOfRows() ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: CategoryCell.reuseIdentifier,
            for: indexPath
        ) as? CategoryCell
        guard let cell, let controller else { return UITableViewCell() }

        let category = controller.category(byIndex: indexPath.row)

        var rowPosition: RowPosition
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            rowPosition = .last
        } else if indexPath.row == 0 {
            rowPosition = .first
        } else {
            rowPosition = .other
        }

        cell.delegate = self
        cell.initData(category: category, isSelected: controller.category == category, rowPosition: rowPosition)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        controller?.completeSelect(withIndex: indexPath.row)
    }
}

extension SelectCategoryView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 75 }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: tableView.bounds.width)
        }
    }
}

final class CategoryCell: UITableViewCell {
    static let reuseIdentifier = "CategoryCell"

    weak var delegate: SelectCategoryView?

    private var category: TrackerCategory?

    private lazy var rowLable: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = view.font.withSize(17)
        view.textColor = .ypBlack
        return view
    }()

    private lazy var selectedImage: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = .selected
        view.tintColor = .ypBlue

        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: 24),
            view.heightAnchor.constraint(equalToConstant: 24)
        ])

        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none
        contentView.backgroundColor = .ypBackground

        contentView.addSubview(rowLable)
        contentView.addSubview(selectedImage)

        NSLayoutConstraint.activate([
            contentView.heightAnchor.constraint(equalToConstant: 75),

            rowLable.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            rowLable.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            selectedImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            selectedImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)

        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initData(category: TrackerCategory, isSelected: Bool, rowPosition: RowPosition) {
        self.category = category

        rowLable.text = category.name
        selectedImage.isHidden = !isSelected

        let radius: CGFloat
        let corners: UIRectCorner
        switch rowPosition {
        case .first:
            radius = 16
            corners = [.topLeft, .topRight]
        case .last:
            radius = 16
            corners = [.bottomLeft, .bottomRight]
        case .other:
            radius = 0
            corners = []
        }
        roundCorners(corners: corners, radius: radius)
    }
}

enum RowPosition {
    case first, last, other
}
