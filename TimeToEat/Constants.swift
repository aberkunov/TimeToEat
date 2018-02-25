//
//  Constants.swift
//  TimeToEat
//
//  Created by Alexander Berkunov on 12.05.17.
//  Copyright © 2017 MB. All rights reserved.
//

import UIKit

enum Constants {
    enum UserDefaults {
        enum Settings {
            static let GlassVolume = "Settings.GlassVolume"
            static let GlassesPerDay = "Settings.GlassesPerDay"
            static let Meals = "Settings.Meals"
        }
    }
    
    enum Settings {
        static let GlassesRange = Array(1...20)
        static let GlassVolumeRange = [100, 150, 200, 250, 300, 330, 350, 400, 500]
        
        static let GlassesPerDayDefaultValue = 9
        static let GlassVolumeDefaultValue = Constants.Settings.GlassVolumeRange[2]
        static let MealsDefaultValue: [Meal] = [.breakfast, .snack, .lunch, .snack, .dinner]
    }
}
