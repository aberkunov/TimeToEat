//
//  SettingsInteractor.swift
//  TimeToEat
//
//  Created by Alexander Berkunov on 04.05.17.
//  Copyright © 2017 MB. All rights reserved.
//

import UIKit

protocol SettingsInteractorInterface {
    /// Loads the settings from a storage
    func loadSettings(request: SettingsModel.Load.Request)
    
    /// Saves the settings to a storage
    func saveSettings(request: SettingsModel.Save.Request)
    
    /// Selects a certain option
    func selectSetting(request: SettingsModel.Select.Request)
}

protocol SettingsDataStore { }

class SettingsInteractor: SettingsInteractorInterface, SettingsDataStore {
    var presenter: SettingsPresenterInterface?
    var settingsStorable = UserDefaultsSettingsStorage()
    
    // Main settings
    private var settings = Settings()
    
    // MARK: - Business logic
    func loadSettings(request: SettingsModel.Load.Request) {
        settings = settingsStorable.item
        
        let response = SettingsModel.Load.Response(numberOfGlasses: settings.glassesPerDay,
                                                   glassVolume: settings.glassVolume,
                                                   meals: settings.meals)
        presenter?.presentSettings(response: response)
    }
    
    func saveSettings(request: SettingsModel.Save.Request) {
        var response = SettingsModel.Save.Response()
        guard let numberOfGlasses = request.numberOfGlasses, let glassVolume = request.glassVolume else {
            return
        }
        
        settings.glassVolume = glassVolume
        settings.glassesPerDay = numberOfGlasses
        
        if settings.hasChanges {
            settingsStorable.save(settings)
            
            response.glassVolume = glassVolume
            response.numberOfGlasses = numberOfGlasses
            
            presenter?.presentSavedSettings(response: response)
        }
    }
    
    func selectSetting(request: SettingsModel.Select.Request) {
        switch request.type {
        case .drinkingWater:
            presenter?.presentDrinkingWaterSetting(response: SettingsModel.Select.Response())
        case .mealOrder:
            presenter?.presentMealsOrderSetting(response: SettingsModel.Select.Response())
        }
    }
}
