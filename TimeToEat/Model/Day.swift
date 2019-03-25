//
//  Day.swift
//  TimeToEat
//
//  Created by Alexander Berkunov on 19.10.17.
//  Copyright © 2017 MB. All rights reserved.
//

import Foundation

// Represents a single day
class Day {
    var plannedWakeUp           = Date()
    var actualWakeUp: Date?
    var eatings                 = [Eating]()
    
    init(plannedWakeUpTime: Date) {
        plannedWakeUp = plannedWakeUpTime
    }
    
    convenience init() {
        self.init(plannedWakeUpTime: Date())
    }
}

extension Day {
    static let plannedWakeUpTime = 7 // at 07:00
}

