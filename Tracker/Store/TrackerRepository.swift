import Foundation

var trackersStorage: [Tracker] = [
    Tracker(
        id: UUID(),
        type: .habit,
        name: "Test habit",
        category: TrackerCategory(id: UUID(), name: "Home"),
        schedule: .monday,
        eventDate: nil,
        emojiIndex: 1,
        colorIndex: 2
    ),
    Tracker(
        id: UUID(),
        type: .event,
        name: "Test event",
        category: TrackerCategory(id: UUID(), name: "Work"),
        schedule: [],
        eventDate: DateWoTime(),
        emojiIndex: 4,
        colorIndex: 7
    )
]

final class TrackerRepository {

    func create(_ new: Tracker) {
        trackersStorage.append(new)
    }

    func filter(byDate date: DateWoTime? = nil, byName name: String? = nil) -> [Tracker] {
        var result = trackersStorage

        if let date {
            let weekDay = WeekDaySet.from(date: date)
            result = result.filter { tracker in
                tracker.schedule.contains(weekDay) || tracker.eventDate == date
            }
        }

        if let name {
            result = result.filter { tracker in
                tracker.name.contains(name)
            }
        }

        return result
    }
}

import CoreData

protocol TrackerStore {
    var delegate: StoreDelegate? { get set }

    func fetchData(with filter: FilterParams) throws
    func numberOfRowsInSection(_ section: Int) -> Int
    func object(atIndexPath: IndexPath) -> Tracker?
    func add(_ record: Tracker)
    func delete(at indexPath: IndexPath)
    func update(at indexPath: IndexPath)
}

struct FilterParams {
    let date: DateWoTime? = nil
    let name: String? = nil
}

final class TrackerStoreCD: BaseCDStore<TrackerCD>, TrackerStore {
    func fetchData(with filter: FilterParams) throws {
        let fetchRequest = TrackerCD.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCD.name, ascending: true)
        ]

        fetchRequest.predicate = predicate(with: filter)

        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: cdContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        try super.fetchData(controller: controller)
    }

    private func predicate(with filter: FilterParams) -> NSPredicate? {
        var predicateFormats: [String] = []
        var predicareArgs: [Any] = []

        if let date = filter.date {
            let weekDay = WeekDaySet.from(date: date)
            predicateFormats.append("((%K & %i) != 0 OR %K == %@)")
            predicareArgs.append(contentsOf: [
                \TrackerCD.schedule,
                weekDay.rawValue,
                \TrackerCD.eventDate,
                date
            ])
        }
        if let name = filter.name {
            predicateFormats.append("%K CONTAINS[n] %@")
            predicareArgs.append(contentsOf: [
                \TrackerCD.name,
                name
            ])
        }

        if predicateFormats.isEmpty { return nil }

        return NSPredicate(format: predicateFormats.joined(separator: " AND "), argumentArray: predicareArgs)
    }
}

extension Tracker: CDStorableObject {
    func toCD(context: NSManagedObjectContext) -> TrackerCD {
        let cdObj = TrackerCD(context: context)
        cdObj.id = id
        cdObj.name = name
        cdObj.type = type.rawValue
        cdObj.category = category.toCD(context: context)
        cdObj.schedule = Int32(schedule.rawValue)
        cdObj.eventDate = eventDate?.value
        cdObj.emojiIndex = Int32(emojiIndex)
        cdObj.colorIndex = Int32(colorIndex)
        return cdObj
    }
}

extension TrackerCD: CDObject {
    func toEntity() -> Tracker? {
        guard
            let id,
            let name,
            let type,
            let type = TrackerType(rawValue: type),
            let category,
            let category = category.toEntity()
        else { return nil }

        let schedule = WeekDaySet(rawValue: Int(schedule))
        let eventDate = eventDate == nil ? nil : DateWoTime(eventDate!)

        return Tracker(
            id: id,
            type: type,
            name: name,
            category: category,
            schedule: schedule,
            eventDate: eventDate,
            emojiIndex: Int(emojiIndex),
            colorIndex: Int(colorIndex)
        )
    }
}
