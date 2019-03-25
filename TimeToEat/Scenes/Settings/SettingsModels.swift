//
//  SettingsModels.swift
//  TimeToEat
//
//  Created by Alexander Berkunov on 04.05.17.
//  Copyright © 2017 MB. All rights reserved.
//

import UIKit

// The type items correpond to UI, check also the Settings storyboard where 1st row is for water, 2nd - meal order and so on
enum SettingType: Int {
    case drinkingWater = 0
    case mealOrder
}

enum SettingsModel {
    enum Load {
        struct Request {
        }
        struct Response {
            let numberOfGlasses: Int
            let glassVolume: Int
            let meals: [Meal]
        }
        struct ViewModel {
            let consumedDrinkingWater: String
            let orderedMeals: String
            let numberOfGlasses: Int
            let glassVolume: Int
        }
    }
    
    enum Save {
        struct Request {
            let numberOfGlasses: Int?
            let glassVolume: Int?
        }
        struct Response {
            var numberOfGlasses: Int?
            var glassVolume: Int?
        }
        struct ViewModel {
            let consumedDrinkingWater: String?
        }
    }
    
    enum Select {
        struct Request {
            let type: SettingType
        }
        struct Response {
        }
        struct ViewModel {
        }
    }
}
