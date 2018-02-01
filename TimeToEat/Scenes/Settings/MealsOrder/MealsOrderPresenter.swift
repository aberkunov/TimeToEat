//
//  MealsOrderPresenter.swift
//  TimeToEat
//
//  Created by Alexander Berkunov on 17.05.17.
//  Copyright © 2017 MB. All rights reserved.
//

import UIKit

protocol MealsOrderPresenterInterface {
    func presentMeals(response: MealsOrder.Load.Response)
    func presentAddedMeal(response: MealsOrder.Add.Response)
    func presentRemovedMeal(response: MealsOrder.Remove.Response)
}

class MealsOrderPresenter: MealsOrderPresenterInterface {
    weak var viewController: MealsOrderViewControllerInterface?
    
    // MARK: - Presentation logic
    func presentMeals(response: MealsOrder.Load.Response) {
        let allMeals = response.meals.map {
            MealViewModel(name: $0.description, image: $0.image)
        }
        
        let viewModel = MealsOrder.ViewModel(displayedMeals: allMeals)
        viewController?.displayMeals(viewModel: viewModel)
    }
    
    func presentAddedMeal(response: MealsOrder.Add.Response) {
        let viewModel = MealViewModel(name: response.meal.description, image: response.meal.image)
        viewController?.displayAddedMeal(viewModel: viewModel)
    }
    
    func presentRemovedMeal(response: MealsOrder.Remove.Response) {
        let viewModel = MealsOrder.Remove.ViewModel(atIndex: response.atIndex)
        viewController?.displayRemovedMeal(viewModel: viewModel)
    }
}
