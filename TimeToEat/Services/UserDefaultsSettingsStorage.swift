//
//  UserDefaultsSettingsStorage.swift
//  TimeToEat
//
//  Created by Alexander Berkunov on 15.06.17.
//  Copyright © 2017 MB. All rights reserved.
//

import Foundation

class UserDefaultsSettingsStorage: RegisteredStorable {
    private let userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    func registerInitial() {
        userDefaults.register(defaults: [Constants.UserDefaults.Settings.GlassVolume: Constants.Settings.GlassVolumeDefaultValue])
        userDefaults.register(defaults: [Constants.UserDefaults.Settings.GlassesPerDay: Constants.Settings.GlassesPerDayDefaultValue])
        
        // register meals as array of String
        let meals = Constants.Settings.MealsDefaultValue.map { $0.rawValue }
        userDefaults.register(defaults: [Constants.UserDefaults.Settings.Meals: meals])
    }
    
    func save(_ item: Settings) {
        userDefaults.set(item.glassVolume, forKey: Constants.UserDefaults.Settings.GlassVolume)
        userDefaults.set(item.glassesPerDay, forKey: Constants.UserDefaults.Settings.GlassesPerDay)
        
        // meals - array of String
        let mealStrings = item.meals.map { $0.rawValue }
        userDefaults.set(mealStrings, forKey: Constants.UserDefaults.Settings.Meals)
    }
    
    var item: Settings {
        let glassVolume = userDefaults.integer(forKey: Constants.UserDefaults.Settings.GlassVolume)
        let glassesPerDay = userDefaults.integer(forKey: Constants.UserDefaults.Settings.GlassesPerDay)
        
        // ordered meals
        let meals: [Meal]
        if let defaultMeals = userDefaults.array(forKey: Constants.UserDefaults.Settings.Meals) as? [String] {
            meals = defaultMeals.flatMap { Meal(rawValue: $0) }
        }
        else {
            meals = []
        }
        
        let settings = Settings(glassVolume: glassVolume, glassesPerDay: glassesPerDay, meals: meals)
        return settings
    }
}
