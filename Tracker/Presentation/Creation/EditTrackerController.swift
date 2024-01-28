import Foundation
import UIKit

final class EditTrackerController: UIViewController {
    private let contentView: EditTrackerView
    private let selectScheduleController: SelectScheduleController
    private let trackerRepository: TrackerRepository
    
    private(set) var editTrackerViewModel: EditTrackerViewModel = EditTrackerViewModel(type: .event)
            
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
        self.selectScheduleController.delegate = self
        
        modalPresentationStyle = .popover
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = contentView
    }
    
    func initData(editTrackerModel: EditTrackerViewModel) {
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
    TrackerCategory(name: "Дом"),
    TrackerCategory(name: "Работа"),
]

extension EditTrackerController: EditTrackerViewDelegat {
    var viewModel: EditTrackerViewModel { editTrackerViewModel }
    
    func selectSchedule() {
        present(selectScheduleController, animated: true)
    }
    
    func selectCategory() {
        let category = categories.randomElement()!
        set(category: category)
    }
    
    func save() {
        guard let tracker = editTrackerViewModel.toTracker() else { return }
        trackerRepository.create(tracker)
    }
}

extension EditTrackerController: SelectScheduleControllerDelegate {
    func set(schedule: WeekDaySet, controller: UIViewController) {
        editTrackerViewModel.schedule = schedule
        contentView.refreshProperties()
        controller.dismiss(animated: true)
    }
}
