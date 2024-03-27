import Foundation
import CoreData

protocol TrackerStore {
    var delegate: StoreDelegate? { get set }
    var numberOfSections: Int { get }

    func toggleComplete(at indexPath: IndexPath, on selectedDate: DateWoTime)

    func fetchAllRecords() -> [TrackerRecord]

    func fetchData(with filter: FilterParams) throws
    func numberOfRowsInSection(_ section: Int) -> Int
    func sectionName(_ section: Int) -> String
    func object(atIndexPath: IndexPath) -> Tracker?
    func add(_ record: Tracker)
    func delete(at indexPath: IndexPath)
    func update(record: Tracker)
}

struct FilterParams {
    let date: DateWoTime
    let filter: TrackerFilter
    let name: String
}

final class TrackerStoreCD: BaseCDStore<TrackerCD>, TrackerStore {
    func toggleComplete(at indexPath: IndexPath, on selectedDate: DateWoTime) {
        guard let trackerCD = cdObject(atIndexPath: indexPath) else { return }

        let recordCD = trackerCD.records?.first(where: {
            guard let record = $0 as? TrackerRecordCD, let recordDate = record.date else { return false }
            return DateWoTime(recordDate) == selectedDate
        }) as? TrackerRecordCD

        if let recordCD {
            trackerCD.removeFromRecords(recordCD)
            cdContext.delete(recordCD)
        } else {
            let newRecord = TrackerRecordCD(context: cdContext)
            newRecord.id = UUID()
            newRecord.date = selectedDate.value
            trackerCD.addToRecords(newRecord)
        }

        save()
    }

    func fetchData(with filter: FilterParams) throws {
        let fetchRequest = TrackerCD.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCD.categoryName, ascending: false),
            NSSortDescriptor(keyPath: \TrackerCD.id, ascending: true)
        ]

        fetchRequest.predicate = predicate(with: filter)

        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: cdContext,
            sectionNameKeyPath: "categoryName",
            cacheName: nil
        )
        try super.fetchData(controller: controller)
    }

    func fetchAllRecords() -> [TrackerRecord] {
        let request = TrackerRecordCD.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerRecordCD.date, ascending: true)]
        let result = (try? cdContext.fetch(request)) ?? []
        return result.compactMap { $0.toEntity() }
    }

    private func predicate(with filter: FilterParams) -> NSPredicate {
        var predicateFormats: [String] = []
        var predicareArgs: [Any] = []

        let weekDay = WeekDaySet.from(date: filter.date)
        predicateFormats.append("((%K & %ld) != 0 OR %K == %@)")
        predicareArgs.append(contentsOf: [
            #keyPath(TrackerCD.schedule),
            weekDay.rawValue,
            #keyPath(TrackerCD.eventDate),
            filter.date.value
        ])

        if !filter.name.isEmpty {
            predicateFormats.append("%K CONTAINS[n] %@")
            predicareArgs.append(contentsOf: [
                #keyPath(TrackerCD.name),
                filter.name
            ])
        }

        switch filter.filter {
        case .all:
            break
        case .today:
            break
        case .completed:
            predicateFormats.append("SUBQUERY(records, $record, $record.date == %@).@count > 0")
            predicareArgs.append(filter.date.value)
        case .notCompleted:
            predicateFormats.append("SUBQUERY(records, $record, $record.date == %@).@count == 0")
            predicareArgs.append(filter.date.value)
        }

        let format = predicateFormats.joined(separator: " AND ")
        return NSPredicate(format: format, argumentArray: predicareArgs)
    }
}

extension Tracker: CDStorableObject {
    func toCD(context: NSManagedObjectContext) -> TrackerCD {
        let cdObj = TrackerCD(context: context)
        cdObj.id = id
        cdObj.name = name
        cdObj.type = type.rawValue
        cdObj.category = findCategory(by: category, context: context)
        cdObj.schedule = Int32(schedule.rawValue)
        cdObj.eventDate = eventDate?.value
        cdObj.emojiIndex = Int32(emojiIndex)
        cdObj.colorIndex = Int32(colorIndex)
        cdObj.isPinned = isPinned
        cdObj.categoryName = isPinned ? Constants.pinSlug : category.name
        return cdObj
    }

}

extension TrackerCD: CDObject {
    func update(by tracker: Tracker) {
        guard let managedObjectContext else { return }
        self.name = tracker.name
        self.category = findCategory(by: tracker.category, context: managedObjectContext)
        self.schedule = Int32(tracker.schedule.rawValue)
        self.emojiIndex = Int32(tracker.emojiIndex)
        self.colorIndex = Int32(tracker.colorIndex)
        self.isPinned = tracker.isPinned
        self.categoryName = tracker.isPinned ? Constants.pinSlug : tracker.category.name
    }

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
            colorIndex: Int(colorIndex),
            isPinned: self.isPinned,
            records: self.records?
                .map {
                    guard let record = $0 as? TrackerRecordCD else { return nil }
                    return record.toEntity()
                }
                .compactMap { $0 } ?? []
        )
    }
}

extension TrackerRecord: CDStorableObject {
    func toCD(context: NSManagedObjectContext) -> TrackerRecordCD {
        let cdObj = TrackerRecordCD(context: context)
        cdObj.id = id
        cdObj.date = date.value
        return cdObj
    }
}

extension TrackerRecordCD: CDObject {
    func update(by record: TrackerRecord) { }

    func toEntity() -> TrackerRecord? {
        guard let id, let date else { return nil }
        return TrackerRecord(
            id: id,
            date: DateWoTime(date)
        )
    }
}

private func findCategory(by category: TrackerCategory, context: NSManagedObjectContext) -> TrackerCategoryCD {
    let request = TrackerCategoryCD.fetchRequest()
    request.predicate = NSPredicate(format: "id == %@", argumentArray: [category.id])
    guard let result = (try? context.fetch(request))?.first else {
        return category.toCD(context: context)
    }
    return result
}
