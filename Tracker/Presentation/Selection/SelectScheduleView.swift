import Foundation
import UIKit

protocol SelectScheduleViewDelegat: AnyObject {
}

final class SelectScheduleView: UIView {
    weak var controller: SelectScheduleViewDelegat?

    private var switches = [WeekDaySwitch]()
    
    private lazy var header: UINavigationBar = {
        let view = UINavigationBar()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.barTintColor = .ypWhiteDay
        view.setBackgroundImage(UIImage(), for: .default)
        view.shadowImage = UIImage()
                
        let navItem = UINavigationItem()
        navItem.title = "Расписание"
        
        view.setItems([navItem], animated: false)
        
        return view
    }()

    private lazy var daysStack: UIStackView = {
        let views = WeekDaySet.allDays().map { weekDay in
            dayRow(at: weekDay)
        }
        
        let view = UIStackView(arrangedSubviews: views)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .ypBackgroundDay
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        
        view.axis = .vertical
        view.spacing = 0
        view.distribution = .fillEqually

        NSLayoutConstraint.activate(
            views.flatMap { dayRow in
                [
                    dayRow.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    dayRow.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                ]
            }
        )

        return view
    }()

    private func dayRow(at weekDay: WeekDaySet) -> UIView {
        let view = UIView()

        let rowLable = rowLable(at: weekDay)
        let uiSwitch = uiSwitch(at: weekDay)

        view.addSubview(rowLable)
        view.addSubview(uiSwitch)
        
        var constraints = [
            view.heightAnchor.constraint(equalToConstant: 75),
            
            rowLable.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            rowLable.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            uiSwitch.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            uiSwitch.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ]

        if weekDay != WeekDaySet.monday {
            let separator = separator()
            view.addSubview(separator)

            constraints.append(separator.topAnchor.constraint(equalTo: view.topAnchor))
            constraints.append(separator.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16))
            constraints.append(separator.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16))
        }
        
        NSLayoutConstraint.activate(constraints)
        return view
    }
    
    private func rowLable(at weekDay: WeekDaySet) -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.text = weekDay.asText()
        view.font = view.font.withSize(17)
        return view
    }

    private func uiSwitch(at weekDay: WeekDaySet) -> UISwitch {
        let view = WeekDaySwitch(weekDay: weekDay)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.onTintColor = .ypBlue
        
        view.addTarget(self, action: #selector(switchDay(_:)), for: .valueChanged)
        
        switches.append(view)
        
        return view
    }

    private func separator() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .ypGray
        
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 0.5),
        ])
        
        return view
    }

    private lazy var acceptButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.backgroundColor = .ypBlackDay
        view.setTitle("Готово", for: .normal)
        
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        view.addTarget(self, action: #selector(acceptClicked), for: .touchUpInside)
        
        return view
    }()

    @objc
    private func switchDay(_ sender: WeekDaySwitch) {
        print(sender.weekDay.asText(), sender.isOn)
    }

    @objc
    private func acceptClicked() {
        let result = switches
            .filter { wdSwitch in wdSwitch.isOn }
            .map { wdSwitch in wdSwitch.weekDay }
            .reduce(into: WeekDaySet(rawValue: 0)) {
                partialResult, weekDay in partialResult = partialResult.union(weekDay)
            }
        
        print(result.asShortText())
    }

    init() {
        super.init(frame: .zero)
        backgroundColor = .ypWhiteDay

        addSubview(header)
        addSubview(daysStack)
        addSubview(acceptButton)

        NSLayoutConstraint.activate([
            header.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            header.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            header.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            daysStack.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            daysStack.topAnchor.constraint(equalTo: header.bottomAnchor),
            daysStack.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),

            acceptButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            acceptButton.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            acceptButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
        ])

        let schedule: WeekDaySet = [.monday, .wednesday]
        
        switches.forEach { value in
            if schedule.contains(value.weekDay) {
                value.setOn(true, animated: false)
            }
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


final class WeekDaySwitch: UISwitch {
    let weekDay: WeekDaySet
    
    init(weekDay: WeekDaySet) {
        self.weekDay = weekDay
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
