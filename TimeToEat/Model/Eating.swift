//
//  Eating.swift
//  TimeToEat
//
//  Created by Alexander Berkunov on 14.08.17.
//  Copyright © 2017 MB. All rights reserved.
//

import Foundation
import UIKit

/// Represents a time-planned action of consuming food.
/// In contrast to Meal enum it could be, for instance, an occasional cup of coffee at 16:45.
class Eating {
    enum Kind {
        case water
        case meal(Meal)
        case drink(Drink)
        case another(String)
    }
    
    enum Status: Int16 {
        case unready
        case planned
        case missed
        case active
        case done
    }
    
    var kind                = Kind.water        // either water or one of the eatings or drink or other (String)
    var plannedDate         = Date()
    var actualDate: Date?
    var status              = Status.unready    //
    
    convenience init(kind: Kind, planned: Date) {
        self.init()
        
        self.kind = kind
        self.plannedDate = planned
        self.status = .planned
    }
}

extension Eating.Kind {
    var stringValue: String {
        switch self {
        case .water:
            return "water"
        case .meal(let meal):
            return meal.rawValue
        case .drink(let drink):
            return drink.rawValue
        case .another(let text):
            return text
        }
    }
    
    var image: UIImage? {
        switch self {
        case .water:
            return UIImage(named: "water")
        case .meal(let meal):
            return meal.image
        case .drink(let drink):
            return drink.image
        case .another:
            return nil
        }
    }
}
