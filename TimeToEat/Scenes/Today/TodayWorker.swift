//
//  TodayWorker.swift
//  TimeToEat
//
//  Created by Alexander Berkunov on 04.05.17.
//  Copyright © 2017 MB. All rights reserved.
//

import UIKit
import CoreData

class TodayWorker {
    var settingsStorage = UserDefaultsSettingsStorage()
    private var dataBaseStorage = DataBaseStorage()
    private let lastMealTimeHour = 20               // at 20:00
    private let firstGlassInterval: TimeInterval = 60 * 2        // 15 min
    
    // MARK: - Eatings
    func fetchEatings(for day: Day) -> [Eating] {
        let date = day.actualWakeUp ?? day.plannedWakeUp
        guard let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: date) else {
            return []
        }
        // end of the current day
        let endDate = Calendar.current.startOfDay(for: nextDay).addingTimeInterval(-1.0 / 100)
        let predicate = NSPredicate(format: "plannedDate >= %@ AND plannedDate < %@", date as NSDate, endDate as NSDate)
        
        var moEatings: [EatingMO]? = []
        let context = dataBaseStorage.persistentContainer.newBackgroundContext()
        context.performAndWait { [weak self] in
            let items: [EatingMO]? = self?.dataBaseStorage.items(in: context, matching: predicate)
            moEatings = items
        }
        
        // convert NSManagedObject(s) to regular Eatings
        let eatings = moEatings?.compactMap { $0.eating }.sorted { $0.plannedDate < $1.plannedDate } ?? []
        return eatings
    }
    
    /// Creates the eatings and sets their status according to wake up date
    func createEatings(for day: Day) -> [Eating] {
        let wakeUpTime = day.actualWakeUp ?? day.plannedWakeUp
        let settings = settingsStorage.item
        var eatings = [Eating]()
        
        // 0. Water
        if settings.glassesPerDay > 0 { // add the very first glass, in 15 min after wake up
            let firstGlass = Eating(kind: .water, planned: wakeUpTime.addingTimeInterval(firstGlassInterval))
            eatings.append(firstGlass)
        }
        var numberOfGlasses = settings.glassesPerDay - 1
        
        // 1. Set up all the meals
        var (nextMealTime, secondsBetweenMeals) = mealTimeRange(within: settings.meals.count, baseDate: wakeUpTime)
        for meal in settings.meals {
            let eating = Eating(kind: .meal(meal), planned: nextMealTime)
            eatings.append(eating)
            nextMealTime.addTimeInterval(secondsBetweenMeals)
            
            // water - 20 minutes before every meal
            if numberOfGlasses > 0 && settings.glassesPerDay - settings.meals.count < numberOfGlasses {
                let waterTime = nextMealTime.addingTimeInterval(-20 * 60)
                let water = Eating(kind: .water, planned: waterTime)
                eatings.append(water)
                numberOfGlasses -= 1
            }
        }
        
        // 2. Remaining water - find the biggest gaps between the eatings and insert there water
        repeat {
            // finds the intervals between eatings
            let intervals: [TimeInterval] = eatings.enumerated().map { pair in
                let previousEating = eatings[pair.offset - (pair.offset > 0 ? 1 : 0)]
                return abs(pair.element.plannedDate.timeIntervalSince(previousEating.plannedDate))
            }
            // finds the max interval and its index
            let max = intervals.dropFirst().enumerated().max { $0.element < $1.element }
            // inserts a new glass of water into the middle of that max interval
            if let offset = max?.offset, offset < eatings.count, let maxInterval = max?.element {
                let waterTime = eatings[offset].plannedDate.addingTimeInterval(maxInterval / 2)
                let water = Eating(kind: .water, planned: waterTime)
                eatings.insert(water, at: offset + 1)
            }
            numberOfGlasses -= 1
        } while numberOfGlasses > 0
        
        // save the eatings into the DB
        let context = dataBaseStorage.persistentContainer.newBackgroundContext()
        context.perform { [weak self] in
            let eatingsMO = eatings.compactMap { $0.newManagedObject(inContext: context) }
            if let todayMO = self?.fetchTodayMO(in: context) {
                eatingsMO.forEach { ($0 as? EatingMO)?.day = todayMO }
            }
            try? context.save()
        }
        
        return eatings
    }
    
    /// The easiest way to update eatings is to delete old items and create new ones.
    /// It updates the eatings's planned date on the base of the wake up date
    func updateEatings(for day: Day) -> [Eating] {
        let context = dataBaseStorage.persistentContainer.newBackgroundContext()
        let dates = day.eatings.map { $0.plannedDate }
        let predicate = NSPredicate(format: "plannedDate IN %@", dates as [NSDate])
        let eatingsMO: [EatingMO] = EatingMO.all(in: context, matching: predicate).sorted { ($0.plannedDate ?? Date()) < ($1.plannedDate ?? Date()) }
        eatingsMO.forEach { context.delete($0) }
        try? context.save()
        
        let eatings = createEatings(for: day)
        return eatings
    }
    
    /// Updates only the statuses based on the current date
    /// Should be called as soons as there is a time for an eating, e.g.
    func updateTodayStatuses() -> [Eating] {
        let context = dataBaseStorage.persistentContainer.newBackgroundContext()
        let todayEatings = fetchEatings(for: today())
        let now = Date()
        
        // find missed items
        for eating in todayEatings where eating.plannedDate < now && eating.actualDate == nil {
            eating.status = .missed
            
            // update the corresponding DB item
            if let eatingMO = eating.existingManagedObject(inContext: context) {
                eatingMO.status = eating.status.rawValue
            }
        }
        // mark the first active/planned items as active
        let firstPlanned = todayEatings.first { $0.status == .active || $0.status == .planned }
        firstPlanned?.status = .active
        if let firstPlannedMO = firstPlanned?.existingManagedObject(inContext: context) {
            firstPlannedMO.status = Eating.Status.active.rawValue
        }
        
        if context.hasChanges {
            try? context.save()
        }
        
        return todayEatings
    }
    
    func updateActive(eating: Eating) {
        let context = dataBaseStorage.persistentContainer.newBackgroundContext()
        context.perform {
            if let eatingMO = eating.existingManagedObject(inContext: context) {
                eatingMO.status = eating.status.rawValue
                eatingMO.actualDate = eating.actualDate
                try? context.save()
            }
        }
    }
    
    // MARK: - Day
    func today() -> Day {
        let context = dataBaseStorage.persistentContainer.newBackgroundContext()
        let moDay = fetchTodayMO(in: context)
        guard let day = moDay?.day else {
            let today = createToday()
            return today
        }
        
        return day
    }
    
    func update(day: Day, with actualWakeUp: Date) {
        day.actualWakeUp = actualWakeUp
        
        // update the day in the DB
        let context = dataBaseStorage.persistentContainer.newBackgroundContext()
        context.perform {
            let predicate = NSPredicate(format: "plannedWakeUp == %@", day.plannedWakeUp as NSDate)
            if let dayMO: DayMO = DayMO.first(in: context, matching: predicate) {
                dayMO.actualWakeUp = actualWakeUp
                try? context.save()
            }
        }
    }
    
    private func fetchTodayMO(in context: NSManagedObjectContext) -> DayMO? {
        guard let plannedWakeUp = Calendar.current.date(bySettingHour: Day.plannedWakeUpTime, minute: 0, second: 0, of: Date()) else {
            preconditionFailure()
        }
        
        let predicate = NSPredicate(format: "plannedWakeUp == %@", plannedWakeUp as NSDate)
        
        var moDay: DayMO?
        context.performAndWait { [weak self] in
            let items: [DayMO]? = self?.dataBaseStorage.items(in: context, matching: predicate)
            moDay = items?.first
        }
        return moDay
    }
    
    private func createToday() -> Day {
        // bySettingHour: minute: second: shows better results than bySettingComponent (the last one can change other components)
        guard let time = Calendar.current.date(bySettingHour: Day.plannedWakeUpTime, minute: 0, second: 0, of: Date()) else {
            preconditionFailure()
        }
        let today = Day(plannedWakeUpTime: time)
        
        // save the day into the DB
        let context = dataBaseStorage.persistentContainer.newBackgroundContext()
        context.perform {
            let _ = today.newManagedObject(inContext: context)
            try? context.save()
        }
        
        return today
    }
    
    // Returns the very first meal time and interval in seconds between next meal
    private func mealTimeRange(within mealsCount: Int, baseDate: Date) -> (Date, TimeInterval) {
        // The very first meal happens in one hour after wake up
        // Every next meal occurs in the same specific time interval until the last meal time
        let startMealTime = Calendar.current.date(byAdding: .hour, value: 1, to: baseDate) ?? baseDate.addingTimeInterval(60 * 60)
        var secondsBetweenMeals: TimeInterval = 60 * 60 * 3 // 3h - default value in case Calendar can't calculate the last meal time
        if let lastMealTime = Calendar.current.date(bySetting: .hour, value: lastMealTimeHour, of: baseDate), mealsCount > 0 {
            secondsBetweenMeals = lastMealTime.timeIntervalSince(startMealTime) / Double(mealsCount - 1)
        }
        return (startMealTime, secondsBetweenMeals)
    }
}

// Example:
//
// [Breakfast, Snack, Lunch, Snack, Snack, Dinner, Snack]
//
// wake up     1. Meal   Last meal       Interval                      Count - first one
// 07:00   ->  08:00.    19:00 - 08:00 = 11*3600 = 39600.      39600 / (7 - 1) = 6600. 6600 seconds between meals (1h 50min)
// 07:00 -> 08:00(Breakfast) -> 09:50(Snack) -> 11:40(Lunch) -> 13:30(Snack) -> 15:20(Snack) -> 17:10(Dinner) -> 19:00(Snack)
