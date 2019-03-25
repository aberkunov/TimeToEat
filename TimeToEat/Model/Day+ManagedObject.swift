//
//  Day+ManagedObject.swift
//  TimeToEat
//
//  Created by Alexander Berkunov on 19.10.17.
//  Copyright © 2017 MB. All rights reserved.
//

import CoreData

extension Day {
    func newManagedObject(inContext context: NSManagedObjectContext) -> NSManagedObject {
        let mo = DayMO(context: context)
        mo.plannedWakeUp = self.plannedWakeUp
        mo.actualWakeUp = self.actualWakeUp
        return mo
    }
}

extension DayMO {
    var day: Day {
        let day = Day()
        if let plannedWakeUp = self.plannedWakeUp {
            day.plannedWakeUp = plannedWakeUp as Date
        }
        if let eatingsMO = self.eatings?.allObjects as? [EatingMO] {
            day.eatings = eatingsMO.map { $0.eating }
        }
        day.actualWakeUp = actualWakeUp as Date?
        
        return day
    }
}
