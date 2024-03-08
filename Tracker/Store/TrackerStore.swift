import Foundation
import CoreData

protocol TrackerStore {
    var delegate: StoreDelegate? { get set }
    var numberOfSections: Int { get }

    func toggleComplete(at indexPath: IndexPath, on selectedDate: DateWoTime)

    func fetchData(with filter: FilterParams) throws
    func numberOfRowsInSection(_ section: Int) -> Int
    func sectionName(_ section: Int) -> String
    func object(atIndexPath: IndexPath) -> Tracker?
    func add(_ record: Tracker)
    func delete(at indexPath: IndexPath)
    func update(at indexPath: IndexPath)
}

struct FilterParams {
    let date: DateWoTime?
    let name: String?
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
            var newRecord = TrackerRecordCD(context: cdContext)
            newRecord.id = UUID()
            newRecord.date = selectedDate.value
            trackerCD.addToRecords(newRecord)
        }

        save()
    }

    func fetchData(with filter: FilterParams) throws {
        let fetchRequest = TrackerCD.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCD.category?.name, ascending: true),
            NSSortDescriptor(keyPath: \TrackerCD.name, ascending: true)
        ]

        fetchRequest.predicate = predicate(with: filter)

        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: cdContext,
            sectionNameKeyPath: "category.name",
            cacheName: nil
        )
        try super.fetchData(controller: controller)
    }

    private func predicate(with filter: FilterParams) -> NSPredicate? {
        var predicateFormats: [String] = []
        var predicareArgs: [Any] = []

        if let date = filter.date {
            let weekDay = WeekDaySet.from(date: date)
            predicateFormats.append("((%K & %ld) != 0 OR %K == %@)")
            predicareArgs.append(contentsOf: [
                #keyPath(TrackerCD.schedule),
                weekDay.rawValue,
                #keyPath(TrackerCD.eventDate),
                date.value
            ])
        }
        if let name = filter.name {
            predicateFormats.append("%K CONTAINS[n] %@")
            predicareArgs.append(contentsOf: [
                #keyPath(TrackerCD.name),
                name
            ])
        }

        if predicateFormats.isEmpty { return nil }

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
        cdObj.category = findCategory(context: context)
        cdObj.schedule = Int32(schedule.rawValue)
        cdObj.eventDate = eventDate?.value
        cdObj.emojiIndex = Int32(emojiIndex)
        cdObj.colorIndex = Int32(colorIndex)
        return cdObj
    }

    private func findCategory(context: NSManagedObjectContext) -> TrackerCategoryCD {
        let request = TrackerCategoryCD.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", argumentArray: [category.id])
        guard let result = (try? context.fetch(request))?.first else {
            return category.toCD(context: context)
        }
        return result
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
            colorIndex: Int(colorIndex),
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
    func toEntity() -> TrackerRecord? {
        guard let id, let date else { return nil }
        return TrackerRecord(
            id: id,
            date: DateWoTime(date)
        )
    }
}
