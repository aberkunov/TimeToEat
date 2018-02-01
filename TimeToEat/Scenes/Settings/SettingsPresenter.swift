//
//  SettingsPresenter.swift
//  TimeToEat
//
//  Created by Alexander Berkunov on 04.05.17.
//  Copyright © 2017 MB. All rights reserved.
//

import UIKit

protocol SettingsPresenterInterface {
    func presentSettings(response: SettingsModel.Load.Response)
    func presentSavedSettings(response: SettingsModel.Save.Response)
    
    func presentDrinkingWaterSetting(response: SettingsModel.Select.Response)
    func presentMealsOrderSetting(response: SettingsModel.Select.Response)
}

class SettingsPresenter: SettingsPresenterInterface {
    weak var viewController: SettingsViewControllerInterface?
    
    // MARK: - Presentation logic
    func presentSettings(response: SettingsModel.Load.Response) {
        let liters = Float(response.glassVolume * response.numberOfGlasses) / 1000
        let consumedWater = String(format: NSLocalizedString("X glasses (Y liter)", comment: ""), response.numberOfGlasses, liters)
        
        let meals = response.meals.map { $0.description }.joined(separator: ", ")
        let viewModel = SettingsModel.Load.ViewModel(consumedDrinkingWater: consumedWater,
                                                     orderedMeals: meals,
                                                     numberOfGlasses: response.numberOfGlasses,
                                                     glassVolume: response.glassVolume)
        viewController?.displaySettings(viewModel: viewModel)
    }
    
    func presentSavedSettings(response: SettingsModel.Save.Response) {
        if let numberOfGlasses = response.numberOfGlasses, let glassVolume = response.glassVolume {
            let liters = Float(glassVolume * numberOfGlasses) / 1000
            let consumedWater = String(format: NSLocalizedString("X glasses (Y liter)", comment: ""), numberOfGlasses, liters)
            
            let viewModel = SettingsModel.Save.ViewModel(consumedDrinkingWater: consumedWater)
            viewController?.displaySavedSettings(viewModel: viewModel)
        }
    }
    
    func presentDrinkingWaterSetting(response: SettingsModel.Select.Response) {
        let viewModel = SettingsModel.Select.ViewModel()
        viewController?.displayDrinkingWaterPicker(viewModel: viewModel)
    }
    
    func presentMealsOrderSetting(response: SettingsModel.Select.Response) {
        let viewModel = SettingsModel.Select.ViewModel()
        viewController?.displayMealsOrderSetting(viewModel: viewModel)
    }
}
