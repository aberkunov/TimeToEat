//
//  Eating+ManagedObject.swift
//  TimeToEat
//
//  Created by Alexander Berkunov on 18.08.17.
//  Copyright © 2017 MB. All rights reserved.
//

import CoreData

extension Eating {
    func newManagedObject(inContext context: NSManagedObjectContext) -> NSManagedObject {
        let mo = EatingMO(context: context)
        mo.plannedDate = self.plannedDate
        mo.actualDate = self.actualDate
        mo.kind = self.kind.stringValue
        mo.status = self.status.rawValue
        return mo
    }
    
    func existingManagedObject(inContext context: NSManagedObjectContext) -> EatingMO? {
        var existingEatingMO: EatingMO?
        context.performAndWait {
            let predicate = NSPredicate(format: "plannedDate == %@", self.plannedDate as NSDate)
            let eatingsMO: [EatingMO] = EatingMO.all(in: context, matching: predicate)
            existingEatingMO = eatingsMO.first
        }
        return existingEatingMO
    }
}

extension EatingMO {
    var eating: Eating {
        let eating = Eating()
        if let plannedDate = self.plannedDate {
            eating.plannedDate = plannedDate as Date
        }
        if let actualDate = self.actualDate {
            eating.actualDate = actualDate as Date
        }
        if let kindText = self.kind {
            if let mealName = Meal(rawValue: kindText) {
                eating.kind = .meal(mealName)
            }
            else if let drinkName = Drink(rawValue: kindText) {
                eating.kind = .drink(drinkName)
            }
            else {
                eating.kind = (kindText == "water") ? .water : .another(kindText)
            }
        }
        eating.status = Eating.Status(rawValue: self.status) ?? .unready
        
        return eating
    }
}
