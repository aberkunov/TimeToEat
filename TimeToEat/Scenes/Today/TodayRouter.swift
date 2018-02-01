//
//  TodayRouter.swift
//  TimeToEat
//
//  Created by Alexander Berkunov on 04.05.17.
//  Copyright © 2017 MB. All rights reserved.
//

import UIKit

protocol TodayRouting {
    func passDataToNextScene(segue: UIStoryboardSegue)
    
    func navigateToSomewhere()
}

protocol TodayDataPassing {
    var dataStore: TodayDataStore? { get }
}

class TodayRouter: TodayRouting, TodayDataPassing {
    weak var viewController: TodayViewController?
    var dataStore: TodayDataStore?
    
    // MARK: - Navigation
    
    func navigateToSomewhere() {
        
    }
    
    // MARK: - Communication
    
    func passDataToNextScene(segue: UIStoryboardSegue) {
        if segue.identifier == "ShowSomewhereScene" {
            passDataToSomewhereScene(segue: segue)
        }
    }
    
    func passDataToSomewhereScene(segue: UIStoryboardSegue) {
        
    }
}
