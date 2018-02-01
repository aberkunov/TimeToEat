//
//  Types.swift
//  TimeToEat
//
//  Created by Alexander Berkunov on 10.08.17.
//  Copyright © 2017 MB. All rights reserved.
//

import UIKit

protocol ImageConvertible: CustomStringConvertible {
    var image: UIImage? { get }
}

extension ImageConvertible where Self: RawRepresentable, Self.RawValue == String {
    var description: String {
        return NSLocalizedString(self.rawValue, comment: "")
    }
    
    var image: UIImage? {
        return UIImage(named: self.rawValue)
    }
}


/// Describes an eating occasion that takes place at a certain time during the day.
enum Meal: String, ImageConvertible {
    case breakfast
    case lunch
    case dinner
    case snack
}

enum Drink: String, ImageConvertible {
    case tea
    case coffee
    case cappuccino
    case milk
    case juice
    case soda
    case beer
}

struct Settings {
    init() { }
    init(glassVolume: Int, glassesPerDay: Int, meals: [Meal]) {
        self.glassVolume = glassVolume
        self.glassesPerDay = glassesPerDay
        self.meals = meals
    }
    
    // in milliliters
    var glassVolume: Int = 0 {
        didSet { isGlassVolumeChanged = (glassVolume != oldValue) }
    }
    
    // consumed water per day in glasses
    var glassesPerDay: Int = 0 {
        didSet { isGlassesPerDayChanged = (glassesPerDay != oldValue) }
    }
    
    // ordered meals per day - for instance [Breakfast, Lunch, Snack, Dinner]
    var meals: [Meal] = [] {
        didSet { isMealsChanged = (meals != oldValue) }
    }
    
    private var isGlassVolumeChanged = false
    private var isGlassesPerDayChanged = false
    private var isMealsChanged = false
    var hasChanges: Bool {
        return isGlassVolumeChanged || isGlassesPerDayChanged || isMealsChanged
    }
}
