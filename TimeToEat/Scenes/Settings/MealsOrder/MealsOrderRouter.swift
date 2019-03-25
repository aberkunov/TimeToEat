//
//  MealsOrderRouter.swift
//  TimeToEat
//
//  Created by Alexander Berkunov on 17.05.17.
//  Copyright © 2017 MB. All rights reserved.
//

import UIKit

protocol MealsOrderRouting {
    func presentAddMeal()
    
    func passDataToNextScene(segue: UIStoryboardSegue)
}

protocol MealsOrderDataPassing {
    var dataStore: MealsOrderDataStore? { get }
}

class MealsOrderRouter: MealsOrderRouting, MealsOrderDataPassing {
    private enum SegueIdentifiers {
        static let AddMeal = "addMeal"
    }
    
    weak var viewController: MealsOrderViewController?
    var dataStore: MealsOrderDataStore?
    
    // MARK: - Navigation
    func presentAddMeal() {
        viewController?.performSegue(withIdentifier: SegueIdentifiers.AddMeal, sender: nil)
    }
    
    // MARK: - Communication
    func passDataToNextScene(segue: UIStoryboardSegue) {
        if segue.identifier == SegueIdentifiers.AddMeal {
            passDataToAddMeal(segue: segue)
        }
    }
    
    func passDataToAddMeal(segue: UIStoryboardSegue) {
        segue.destination.popoverPresentationController?.delegate = viewController
        segue.destination.popoverPresentationController?.backgroundColor = segue.destination.view.backgroundColor
        if let addMealViewController = segue.destination as? AddMealViewController {
            addMealViewController.delegate = viewController
        }
    }
}
