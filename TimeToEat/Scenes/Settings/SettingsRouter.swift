//
//  SettingsRouter.swift
//  TimeToEat
//
//  Created by Alexander Berkunov on 04.05.17.
//  Copyright © 2017 MB. All rights reserved.
//

import UIKit

protocol SettingsRouting {
    func navigateToMealsOrderScene()
    
    func passDataToNextScene(segue: UIStoryboardSegue)
}

protocol SettingsDataPassing {
    var dataStore: SettingsDataStore? { get }
}

class SettingsRouter: SettingsRouting, SettingsDataPassing {
    private enum SegueIdentifiers {
        static let ShowMealOrder = "showMealOrder"
    }
    
    weak var viewController: SettingsViewController?
    var dataStore: SettingsDataStore?
    
    // MARK: - Navigation
    func navigateToMealsOrderScene() {
        viewController?.performSegue(withIdentifier: SegueIdentifiers.ShowMealOrder, sender: nil)
    }
    
    // MARK: - Communication
    func passDataToNextScene(segue: UIStoryboardSegue) {
        if segue.identifier == SegueIdentifiers.ShowMealOrder {
            passDataToMealOrderScene(segue: segue)
        }
    }
    
    func passDataToMealOrderScene(segue: UIStoryboardSegue) {
    }
}
