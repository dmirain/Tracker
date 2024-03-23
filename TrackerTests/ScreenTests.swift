import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {
    func testMain() throws {
        let viewCtl = TrackerListViewController(
            depsFactory: TrackerViewControllerDepsFactoryMock(),
            contentView: TrackerListView(),
            trackerStore: TrackerStoreMock()
        )

        viewCtl.selectedDate = testDate

        assertSnapshots(of: viewCtl, as: [
            .image(on: .iPhone13, traits: UITraitCollection(userInterfaceStyle: .light)),
            .image(on: .iPhone13, traits: UITraitCollection(userInterfaceStyle: .dark))
        ])
    }
}

final class TrackerViewControllerDepsFactoryMock: TrackerViewControllerDepsFactory {
    func getAddController(
        parentDelegate: AddParentDelegateProtocol,
        selectedDate: DateWoTime
    ) -> AddTrackerController? { nil }
    func editTrackerController(
        parentDelegate: AddParentDelegateProtocol,
        editTrackerModel: EditTrackerViewModel
    ) -> EditTrackerController? { nil }

    func selectFilterController(
        delegate: SelectFilterControllerDelegate,
        currentFilter: TrackerFilter
    ) -> SelectFilterController? { nil }

}

let testDate: DateWoTime = {
    var dateComponents = DateComponents()
    dateComponents.year = 1_980
    dateComponents.month = 7
    dateComponents.day = 11
    dateComponents.timeZone = TimeZone(abbreviation: "JST") // Japan Standard Time
    dateComponents.hour = 8
    dateComponents.minute = 34
    // Create date from components
    let userCalendar = Calendar(identifier: .gregorian)
    let someDateTime = userCalendar.date(from: dateComponents)
    return DateWoTime(someDateTime!)
}()

final class TrackerStoreMock: TrackerStore {

    private let trackers = (0..<6).map {
        Tracker(
            id: UUID(),
            type: [1, 2, 5].contains($0) ? .event : .habit,
            name: String(repeating: $0.description, count: 40),
            category: TrackerCategory(id: UUID(), name: ""),
            schedule: WeekDaySet.from(date: testDate),
            eventDate: testDate,
            emojiIndex: $0,
            colorIndex: $0,
            isPinned: [0, 1].contains($0) ? true : false,
            records: []
        )
    }

    weak var delegate: StoreDelegate?
    var numberOfSections = 3
    func numberOfRowsInSection(_ section: Int) -> Int {
        2
    }
    func sectionName(_ section: Int) -> String {
        switch section {
        case 0:
            Constants.pinSlug
        case 1:
            "First"
        case 2:
            "Second"
        default:
            ""
        }
    }
    func object(atIndexPath: IndexPath) -> Tracker? {
        trackers[atIndexPath.section + atIndexPath.row]
    }

    func toggleComplete(at indexPath: IndexPath, on selectedDate: DateWoTime) {}
    func fetchData(with filter: FilterParams) throws {}
    func add(_ record: Tracker) {}
    func delete(at indexPath: IndexPath) {}
    func update(record: Tracker) {}
}
