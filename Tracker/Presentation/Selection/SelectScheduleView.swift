import Foundation
import UIKit

protocol SelectScheduleViewDelegat: AnyObject {
    var schedule: WeekDaySet { get set }
    func completeSelect()
}

final class SelectScheduleView: UIView {
    weak var controller: SelectScheduleViewDelegat?

    private lazy var daysTable: UITableView = {
        let view = UITableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .ypWhite

        view.register(DaySwitchCell.self, forCellReuseIdentifier: DaySwitchCell.reuseIdentifier)
        view.dataSource = self
        view.delegate = self

        return view
    }()

    private lazy var acceptButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.backgroundColor = .ypBlack
        view.setTitle("Готово", for: .normal)
        view.setTitleColor(.ypWhite, for: .normal)

        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 60)
        ])

        view.addTarget(self, action: #selector(acceptClicked), for: .touchUpInside)

        return view
    }()

    init() {
        super.init(frame: .zero)
        backgroundColor = .ypWhite

        addSubview(daysTable)
        addSubview(acceptButton)

        NSLayoutConstraint.activate([
            daysTable.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            daysTable.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            daysTable.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            daysTable.bottomAnchor.constraint(equalTo: acceptButton.topAnchor),

            acceptButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            acceptButton.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            acceptButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20)
        ])

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initData() {
        daysTable.reloadData()
    }

    @objc
    private func acceptClicked() {
        controller?.completeSelect()
    }
}

extension SelectScheduleView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        WeekDaySet.allDays().count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: DaySwitchCell.reuseIdentifier,
            for: indexPath
        ) as? DaySwitchCell
        guard let cell, let controller else { return UITableViewCell() }

        cell.delegate = self
        cell.initData(weekDay: WeekDaySet.allDays()[indexPath.row], schedule: controller.schedule)
        return cell
    }
}

extension SelectScheduleView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 75 }
}

final class DaySwitchCell: UITableViewCell {
    static let reuseIdentifier = "NameCell"

    weak var delegate: SelectScheduleView?

    private var weekDay: WeekDaySet = .monday

    private lazy var rowLable: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = view.font.withSize(17)
        view.textColor = .ypBlack
        return view
    }()

    private lazy var uiSwitch: UISwitch = {
        let view = UISwitch()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.onTintColor = .ypBlue

        view.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)

        return view
    }()

    private lazy var separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .ypGray

        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 0.5)
        ])
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.backgroundColor = .ypBackground

        contentView.addSubview(rowLable)
        contentView.addSubview(uiSwitch)
        contentView.addSubview(separatorView)

        NSLayoutConstraint.activate([
            contentView.heightAnchor.constraint(equalToConstant: 75),

            rowLable.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            rowLable.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            uiSwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            uiSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            separatorView.topAnchor.constraint(equalTo: contentView.topAnchor),
            separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initData(weekDay: WeekDaySet, schedule: WeekDaySet) {
        self.weekDay = weekDay
        separatorView.isHidden = weekDay == WeekDaySet.monday
        rowLable.text = weekDay.asText()

        uiSwitch.setOn(schedule.contains(weekDay), animated: false)

        let radius: CGFloat
        let corners: UIRectCorner
        switch weekDay {
        case .monday:
            radius = 16
            corners = [.topLeft, .topRight]
        case .sunday:
            radius = 16
            corners = [.bottomLeft, .bottomRight]
        default:
            radius = 0
            corners = []
        }
        roundCorners(corners: corners, radius: radius)
    }

    @objc
    private func switchChanged(_ sender: UISwitch) {
        guard let controller = delegate?.controller else { return }
        if sender.isOn {
            controller.schedule.insert(weekDay)
        } else {
            controller.schedule.remove(weekDay)
        }
    }
}
