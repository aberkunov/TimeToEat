//
//  AddMealViewController.swift
//  TimeToEat
//
//  Created by Alexander Berkunov on 19.05.17.
//  Copyright © 2017 MB. All rights reserved.
//

import UIKit

protocol AddMealViewControllerDelegate: class {
    func addMealViewController(_ viewController: AddMealViewController, didAddMeal meal: Meal)
}

class AddMealViewController: UITableViewController {
    weak var delegate: AddMealViewControllerDelegate?
    let mealIndexMapping: [Int: Meal] = [0: .breakfast, 1: .lunch, 2: .dinner, 3: .snack]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.preferredContentSize = CGSize(width: 200, height: self.tableView.rowHeight * 4)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let meal = mealIndexMapping[indexPath.row] {
            delegate?.addMealViewController(self, didAddMeal: meal)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}
