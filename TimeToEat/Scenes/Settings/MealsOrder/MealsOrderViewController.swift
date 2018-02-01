//
//  MealsOrderViewController.swift
//  TimeToEat
//
//  Created by Alexander Berkunov on 17.05.17.
//  Copyright © 2017 MB. All rights reserved.
//

import UIKit

protocol MealsOrderViewControllerInterface: class {
    func displayMeals(viewModel: MealsOrder.ViewModel)
    func displayAddedMeal(viewModel: MealsOrder.ViewModel.DisplayedMeal)
    func displayRemovedMeal(viewModel: MealsOrder.Remove.ViewModel)
}

class MealsOrderViewController: UITableViewController, MealsOrderViewControllerInterface {
    var interactor: MealsOrderInteractorInterface?
    var router: (MealsOrderRouting & MealsOrderDataPassing)?
    
    var displayedMeals = [MealViewModel]()
    
    // MARK: - Object lifecycle
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        let viewController = self
        let interactor = MealsOrderInteractor()
        let presenter = MealsOrderPresenter()
        let router = MealsOrderRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // configure UI elements
        configureSubviews()
        
        // load current meal orders
        interactor?.loadMeals(request: MealsOrder.Load.Request())
    }
    
    // MARK: Routing
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        router?.passDataToNextScene(segue: segue)
    }
    
    // MARK: - Display logic
    func displayMeals(viewModel: MealsOrder.ViewModel) {
        displayedMeals = viewModel.displayedMeals
        self.tableView.reloadData()
    }
    
    func displayAddedMeal(viewModel: MealsOrder.ViewModel.DisplayedMeal) {
        displayedMeals.append(viewModel)
        
        // reload and scroll to bottom
        self.tableView.reloadData()
        let lastIndexPath = IndexPath(row: self.tableView.numberOfRows(inSection: 0) - 1, section: 0)
        self.tableView.scrollToRow(at: lastIndexPath, at: .top, animated: true)
    }
    
    func displayRemovedMeal(viewModel: MealsOrder.Remove.ViewModel) {
        displayedMeals.remove(at: viewModel.atIndex)
        self.tableView.deleteRows(at: [IndexPath(row: viewModel.atIndex, section: 0)], with: .automatic)
    }
    
    // MARK: - Actions
    @IBAction func addAction(_ sender: UIBarButtonItem) {
        router?.presentAddMeal()
    }
    
    // MARK: - Private
    func configureSubviews() {
        // tableview is always in edit mode
        self.setEditing(true, animated: false)
    }
}


// MARK: - AddMealViewControllerDelegate
extension MealsOrderViewController: AddMealViewControllerDelegate {
    func addMealViewController(_ viewController: AddMealViewController, didAddMeal meal: Meal) {
        interactor?.addMeal(request: MealsOrder.Add.Request(meal: meal))
    }
}


// MARK: - UIPopoverPresentationControllerDelegate
extension MealsOrderViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}


// MARK: - UITableViewDataSource
extension MealsOrderViewController {
    private enum CellIdentifiers {
        static let MealOrder: String = "mealOrderCell"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedMeals.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let displayedMeal = displayedMeals[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.MealOrder, for: indexPath)
        cell.textLabel?.text = displayedMeal.name
        cell.imageView?.image = displayedMeal.image
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return } // only delete action is allowed
        
        interactor?.removeMeal(request: MealsOrder.Remove.Request(atIndex: indexPath.row))
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let reorderRequest = MealsOrder.Reorder.Request(fromIndex: sourceIndexPath.row, toIndex: destinationIndexPath.row)
        interactor?.reorderMeals(request: reorderRequest)
        
        // update displayed model
        let meal = displayedMeals[sourceIndexPath.row]
        displayedMeals.remove(at: sourceIndexPath.row)
        displayedMeals.insert(meal, at: destinationIndexPath.row)
    }
}
