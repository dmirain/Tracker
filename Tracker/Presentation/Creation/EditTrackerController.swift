import UIKit

protocol EditTrackerControllerDepsFactory {
    func getSelectScheduleController() -> SelectScheduleController?
    func getSelectCategoryController() -> SelectCategoryController?
}

final class EditTrackerController: UIViewController {
    private let depsFactory: EditTrackerControllerDepsFactory
    private let contentView: EditTrackerView

    private weak var parentDelegate: AddParentDelegateProtocol?
    private(set) var editTrackerViewModel = EditTrackerViewModel(type: .event, selectedDate: DateWoTime())

    init(
        depsFactory: EditTrackerControllerDepsFactory,
        contentView: EditTrackerView
    ) {
        self.depsFactory = depsFactory
        self.contentView = contentView

        super.init(nibName: nil, bundle: nil)

        self.contentView.controller = self

        switch editTrackerViewModel.type {
        case .event:
            navigationItem.title = "EditTracker.NavTitle.event"~
        case .habit:
            navigationItem.title = "EditTracker.NavTitle.habit"~
        }
        navigationItem.hidesBackButton = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.view = contentView
    }

    func initData(parentDelegate: AddParentDelegateProtocol, editTrackerModel: EditTrackerViewModel) {
        self.parentDelegate = parentDelegate
        self.editTrackerViewModel = editTrackerModel
        self.contentView.initData()
    }
}

extension EditTrackerController: EditTrackerViewDelegat {
    var viewModel: EditTrackerViewModel { editTrackerViewModel }

    func selectSchedule() {
        let selectScheduleController = depsFactory.getSelectScheduleController()
        guard let selectScheduleController else { return }
        selectScheduleController.delegate = self
        selectScheduleController.initData(schedule: editTrackerViewModel.schedule)
        navigationController?.pushViewController(selectScheduleController, animated: true)
    }

    func selectCategory() {
        let selectCategoryController = depsFactory.getSelectCategoryController()
        guard let selectCategoryController else { return }
        selectCategoryController.delegate = self
        selectCategoryController.initData(category: editTrackerViewModel.category)
        navigationController?.pushViewController(selectCategoryController, animated: true)
    }

    func compleateEdit() {
        guard let tracker = editTrackerViewModel.toTracker() else { return }
        let action: EditAction = editTrackerViewModel.isNew ? .create(tracker: tracker) : .update(tracker: tracker)
        parentDelegate?.compleateEdit(action: action)
    }

    func cancelEdit() {
        parentDelegate?.compleateEdit(action: .cancel)
    }

    func nameChanged(_ name: String) {
        editTrackerViewModel.name = name
        contentView.refreshButtons()
    }
}

extension EditTrackerController: SelectScheduleControllerDelegate {
    func set(schedule: WeekDaySet) {
        editTrackerViewModel.schedule = schedule
        contentView.refreshProperties()
        navigationController?.popViewController(animated: true)
    }
}

extension EditTrackerController: SelectCategoryControllerDelegate {
    func set(category: TrackerCategory) {
        editTrackerViewModel.category = category
        contentView.refreshProperties()
        navigationController?.popViewController(animated: true)
    }
}
