//
//  MealsOrderInteractor.swift
//  TimeToEat
//
//  Created by Alexander Berkunov on 17.05.17.
//  Copyright © 2017 MB. All rights reserved.
//

import UIKit

protocol MealsOrderInteractorInterface {
    /// Loads all current meals
    func loadMeals(request: MealsOrder.Load.Request)
    
    /// Adds a new meal to the end of the list of current meals
    func addMeal(request: MealsOrder.Add.Request)
    
    /// Removes the meal at provided index
    func removeMeal(request: MealsOrder.Remove.Request)
    
    /// Reorders the position of meals. There is only data manipulation, so it doesn't go for the whole WIP-cycle
    func reorderMeals(request: MealsOrder.Reorder.Request)
}

protocol MealsOrderDataStore { }

class MealsOrderInteractor: MealsOrderInteractorInterface, MealsOrderDataStore {
    var presenter: MealsOrderPresenterInterface?
    var settingsStorable = UserDefaultsSettingsStorage()
    
    // MARK: - Business logic
    func loadMeals(request: MealsOrder.Load.Request) {
        let settings = settingsStorable.item
        let response = MealsOrder.Load.Response(meals: settings.meals)
        presenter?.presentMeals(response: response)
    }
    
    func addMeal(request: MealsOrder.Add.Request) {
        // get settings and update meals
        var settings = settingsStorable.item
        settings.meals.append(request.meal)
        
        settingsStorable.save(settings)
        let response = MealsOrder.Add.Response(meal: request.meal)
        presenter?.presentAddedMeal(response: response)
    }
    
    func removeMeal(request: MealsOrder.Remove.Request) {
        // get settings and update meals
        var settings = settingsStorable.item
        
        guard request.atIndex >= 0 && settings.meals.count > request.atIndex  else { return }
        settings.meals.remove(at: request.atIndex)
        
        settingsStorable.save(settings)
        let response = MealsOrder.Remove.Response(atIndex: request.atIndex)
        presenter?.presentRemovedMeal(response: response)
    }
    
    func reorderMeals(request: MealsOrder.Reorder.Request) {
        var settings = settingsStorable.item
        
        guard (request.fromIndex >= 0 && settings.meals.count > request.fromIndex) &&
            (request.toIndex >= 0 && settings.meals.count > request.toIndex) else {
                return
        }
        
        // reorder meals and reassign it back to settings
        var meals = settings.meals
        let meal = meals[request.fromIndex]
        meals.remove(at: request.fromIndex)
        meals.insert(meal, at: request.toIndex)
        settings.meals = meals
        
        settingsStorable.save(settings)
    }
}
