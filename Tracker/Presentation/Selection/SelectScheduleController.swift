import UIKit

protocol SelectScheduleControllerDelegate: AnyObject {
    func set(schedule: WeekDaySet)
}

final class SelectScheduleController: UIViewController {
    private let contentView: SelectScheduleView

    weak var delegate: SelectScheduleControllerDelegate?

    var schedule: WeekDaySet = []

    init(contentView: SelectScheduleView) {
        self.contentView = contentView
        super.init(nibName: nil, bundle: nil)

        self.contentView.controller = self

        navigationItem.title = "SelectSchedule.NavTitle"~
        navigationItem.hidesBackButton = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
       self.view = contentView
    }

    func initData(schedule: WeekDaySet) {
        self.schedule = schedule
        contentView.initData()
    }
}

extension SelectScheduleController: SelectScheduleViewDelegate {
    func completeSelect() {
        delegate?.set(schedule: schedule)
    }
}
