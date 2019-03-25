//
//  MealsOrderModels.swift
//  TimeToEat
//
//  Created by Alexander Berkunov on 17.05.17.
//  Copyright © 2017 MB. All rights reserved.
//

import UIKit

enum MealsOrder {
    enum Load {
        struct Request {
        }
        struct Response {
            let meals: [Meal]
        }
        // ViewModel will be MealsOrder.ViewModel
    }
    
    enum Add {
        struct Request {
            let meal: Meal
        }
        struct Response {
            let meal: Meal
        }
        // ViewModel will be MealsOrder.ViewModel
    }
    
    enum Remove {
        struct Request {
            let atIndex: Int
        }
        struct Response {
            let atIndex: Int
        }
        struct ViewModel {
            let atIndex: Int
        }
    }
    
    enum Reorder {
        struct Request {
            let fromIndex: Int
            let toIndex: Int
        }
        struct Response {
        }
        struct ViewModel {
        }
    }
    
    struct ViewModel {
        struct DisplayedMeal {
            let name: String
            let image: UIImage?
        }
        let displayedMeals: [DisplayedMeal]
    }
}


typealias MealViewModel = MealsOrder.ViewModel.DisplayedMeal
