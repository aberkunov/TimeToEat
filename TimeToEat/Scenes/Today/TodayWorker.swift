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
    private let lastMealTimeHour = 19 // at 19:00
    
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
        let eatings = moEatings?.flatMap { $0.eating }.sorted { $0.plannedDate < $1.plannedDate } ?? []
        return eatings
    }
    
    func createEatings(for day: Day) -> [Eating] {
        let date = day.actualWakeUp ?? day.plannedWakeUp
        let settings = settingsStorage.item
        var eatings = [Eating]()
        
        // 1. Set all the meals up
        var (mealTime, secondsBetweenMeals) = mealTimeRange(within: settings.meals.count, baseDate: date)
        for meal in settings.meals {
            if let time = mealTime {
                let eating = Eating(kind: .meal(meal), planned: time)
                eatings.append(eating)
                mealTime = time.addingTimeInterval(secondsBetweenMeals)
            }
        }
        
        // 2. Water
        
        // save the eatings into the DB
        let context = dataBaseStorage.persistentContainer.newBackgroundContext()
        context.perform { [weak self] in
            let eatingsMO = eatings.flatMap { $0.newManagedObject(inContext: context) }
            if let todayMO = self?.fetchTodayMO(in: context) {
                eatingsMO.forEach { ($0 as? EatingMO)?.day = todayMO }
            }
            try? context.save()
        }
        
        return eatings
    }
    
    func updateEatings(for day: Day) -> [Eating] {
        let date = day.actualWakeUp ?? day.plannedWakeUp
        
        let context = dataBaseStorage.persistentContainer.newBackgroundContext()
        let dates = day.eatings.map { $0.plannedDate }
        let predicate = NSPredicate(format: "plannedDate IN %@", dates as [NSDate])
        let eatingsMO: [EatingMO] = EatingMO.all(in: context, matching: predicate).sorted { ($0.plannedDate ?? Date()) < ($1.plannedDate ?? Date()) }
        
        var (mealTime, secondsBetweenMeals) = mealTimeRange(within: eatingsMO.count, baseDate: date)
        for eatingMO in eatingsMO {
            if let time = mealTime {
                eatingMO.plannedDate = time
                mealTime = time.addingTimeInterval(secondsBetweenMeals)
            }
        }
        
        try? context.save()
        return eatingsMO.map { $0.eating }
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
    private func mealTimeRange(within mealsCount: Int, baseDate: Date) -> (Date?, TimeInterval) {
        // The very first meal happens in one hour after wake up
        // Every next meal occurs in the same specific time interval until the last meal time
        let startMealTime = Calendar.current.date(byAdding: .hour, value: 1, to: baseDate)
        var secondsBetweenMeals: TimeInterval = 60 * 60 * 3 // 3h - default value in case Calendar can't calculate the last meal time
        if let lastMealTime = Calendar.current.date(bySetting: .hour, value: lastMealTimeHour, of: baseDate), let mealTime = startMealTime, mealsCount > 0 {
            secondsBetweenMeals = lastMealTime.timeIntervalSince(mealTime) / Double(mealsCount - 1)
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
