import Foundation
import UIKit

final class EditTrackerController: UIViewController {
    private let contentView: EditTrackerView
    private let selectScheduleController: SelectScheduleController
    private let trackerRepository: TrackerRepository

    private weak var parentDelegate: AddParentDelegateProtocol?
    private(set) var editTrackerViewModel = EditTrackerViewModel(type: .event, selectedDate: DateWoTime())

    init(
        contentView: EditTrackerView,
        selectScheduleController: SelectScheduleController,
        trackerRepository: TrackerRepository
    ) {
        self.contentView = contentView
        self.selectScheduleController = selectScheduleController
        self.trackerRepository = trackerRepository

        super.init(nibName: nil, bundle: nil)

        self.contentView.controller = self

        switch editTrackerViewModel.type {
        case .event:
            navigationItem.title = "Новое нерегулярное событие"
        case .habit:
            navigationItem.title = "Новая привычка"
        }
        navigationItem.hidesBackButton = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.view = contentView
    }

    func initData(parentDelegat: AddParentDelegateProtocol, editTrackerModel: EditTrackerViewModel) {
        self.parentDelegate = parentDelegat
        self.editTrackerViewModel = editTrackerModel
        self.contentView.initData()
    }

    func set(category: TrackerCategory) {
        editTrackerViewModel.category = category
        contentView.refreshProperties()
    }
}

// TODO: убрать заглушку
private let categories: [TrackerCategory] = [
    TrackerCategory(name: "Home"),
    TrackerCategory(name: "Work")
]

extension EditTrackerController: EditTrackerViewDelegat {
    var viewModel: EditTrackerViewModel { editTrackerViewModel }

    func selectSchedule() {
        selectScheduleController.delegate = self
        selectScheduleController.initData(schedule: editTrackerViewModel.schedule)
        navigationController?.pushViewController(selectScheduleController, animated: true)
    }

    func selectCategory() {
        let category = categories.randomElement()!
        set(category: category)
    }

    func compleateEdit(action: EditAction) {
        switch action {
        case .save:
            let tracker = editTrackerViewModel.toTracker()
            if let tracker {
                trackerRepository.create(tracker)
            }
        case .cancel:
            break
        }

        parentDelegate?.compleateAdd(action: action)
    }
}

extension EditTrackerController: SelectScheduleControllerDelegate {
    func set(schedule: WeekDaySet) {
        editTrackerViewModel.schedule = schedule
        contentView.refreshProperties()
        navigationController?.popViewController(animated: true)
    }
}
