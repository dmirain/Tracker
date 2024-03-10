import UIKit

protocol SelectCategoryViewDelegate: AnyObject {
    func numberOfRowsInSection(_ section: Int) -> Int
    func rowViewModel(byIndexPath: IndexPath) -> SelectCategoryRowViewModel?

    func completeSelect(withIndexPath: IndexPath)
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

    private lazy var emptyListView: UIView = {
        let view = EmptyListView(text: "Привычки и события можно\nобъединить по смыслу")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    init() {
        super.init(frame: .zero)
        backgroundColor = .ypWhite

        addSubview(categoriesTable)
        addSubview(createButton)
        addSubview(emptyListView)

        NSLayoutConstraint.activate([
            categoriesTable.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            categoriesTable.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            categoriesTable.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            categoriesTable.bottomAnchor.constraint(equalTo: createButton.topAnchor),

            emptyListView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            emptyListView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            emptyListView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            emptyListView.bottomAnchor.constraint(equalTo: createButton.topAnchor),

            createButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            createButton.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            createButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func reloadData() {
        categoriesTable.reloadData()
        setEmptyListState()
    }

    @objc
    private func createClicked() {
        controller?.createClicked()
    }

    private func setEmptyListState() {
        if controller?.numberOfRowsInSection(0) == 0 {
            emptyListView.isHidden = false
        } else {
            emptyListView.isHidden = true
        }
    }
}

extension SelectCategoryView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        controller?.numberOfRowsInSection(section) ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: CategoryCell.reuseIdentifier,
            for: indexPath
        ) as? CategoryCell
        guard
            let cell,
            let controller,
            let rowViewModel = controller.rowViewModel(byIndexPath: indexPath)
        else { return UITableViewCell() }

        let rowPosition = RowPosition(
            isFirst: indexPath.row == 0,
            isLast: indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1
        )
        cell.delegate = self
        cell.initData(rowViewModel: rowViewModel, rowPosition: rowPosition)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        controller?.completeSelect(withIndexPath: indexPath)
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

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initData(rowViewModel: SelectCategoryRowViewModel, rowPosition: RowPosition) {
        rowLable.text = rowViewModel.category.name
        selectedImage.isHidden = !rowViewModel.isSelected

        let radius: CGFloat = rowPosition.isFirst || rowPosition.isLast ? 16 : 0
        roundCorners(corners: rowPosition.toCorners(), radius: radius)
    }
}

struct RowPosition {
    let isFirst: Bool
    let isLast: Bool

    func toCorners() -> UIRectCorner {
        switch (isFirst, isLast) {
        case (true, true):
            return [.topLeft, .topRight, .bottomLeft, .bottomRight]
        case (true, false):
            return [.topLeft, .topRight]
        case (false, true):
            return [.bottomLeft, .bottomRight]
        default:
            return []
        }
    }
}
