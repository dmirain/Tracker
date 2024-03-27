import UIKit

protocol SelectFilterViewDelegate: AnyObject {
    var currentFilter: TrackerFilter { get }
    func completeSelect(withIndexPath: IndexPath)
}

final class SelectFilterView: UIView {
    weak var controller: SelectFilterViewDelegate?

    private lazy var filtersTable: UITableView = {
        let view = UITableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .ypWhite
        view.separatorStyle = .singleLine
        view.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        view.tableHeaderView = UIView()

        view.register(FilterCell.self, forCellReuseIdentifier: FilterCell.reuseIdentifier)
        view.dataSource = self
        view.delegate = self

        return view
    }()

    init() {
        super.init(frame: .zero)
        backgroundColor = .ypWhite

        addSubview(filtersTable)

        NSLayoutConstraint.activate([
            filtersTable.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            filtersTable.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            filtersTable.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            filtersTable.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SelectFilterView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        TrackerFilter.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: FilterCell.reuseIdentifier,
            for: indexPath
        ) as? FilterCell
        guard let cell, let controller else { return UITableViewCell() }

        let rowPosition = RowPosition(
            isFirst: indexPath.row == 0,
            isLast: indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1
        )

        let filter = TrackerFilter.allCases[indexPath.row]

        cell.delegate = self
        cell.initData(
            filter: filter,
            isSelected: controller.currentFilter == filter,
            rowPosition: rowPosition
        )
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        controller?.completeSelect(withIndexPath: indexPath)
    }
}

extension SelectFilterView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 75 }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: tableView.bounds.width)
        }
    }
}

final class FilterCell: UITableViewCell {
    static let reuseIdentifier = "FilterCell"

    weak var delegate: SelectFilterView?

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

    func initData(filter: TrackerFilter, isSelected: Bool, rowPosition: RowPosition) {
        rowLable.text = filter.asText
        selectedImage.isHidden = !isSelected

        let radius: CGFloat = rowPosition.isFirst || rowPosition.isLast ? 16 : 0
        roundCorners(corners: rowPosition.toCorners(), radius: radius)
    }
}
