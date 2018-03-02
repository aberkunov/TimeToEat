//
//  TodayViewController.swift
//  TimeToEat
//
//  Created by Alexander Berkunov on 04.05.17.
//  Copyright © 2017 MB. All rights reserved.
//

import UIKit

protocol TodayViewControllerInterface: class {
    func displayWakeUp(viewModel: Today.ViewModel.DisplayedItem)
    func displaySchedule(viewModel: Today.ViewModel)
    func displayActive(viewModel: Today.MoveActive.ViewModel)
}

class TodayViewController: UITableViewController, TodayViewControllerInterface {
    var interactor: (TodayInteractorInterface & TodayDataStore)?
    var router: (TodayRouting & TodayDataPassing)?
    
    var wakeUpItem = Today.ViewModel.DisplayedItem(name: "I woke up!", plannedTime: "", actualTime: nil, image: nil, isActive: true, isDone: false, isMissed: false)
    var displayedItems: [Today.ViewModel.DisplayedItem] = []
    
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
        let interactor = TodayInteractor()
        let presenter = TodayPresenter()
        let router = TodayRouter()
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
        
        displayedItems.append(wakeUpItem)
        interactor?.updateWakeUpItem(request: Today.WakeUp.Request(date: nil))
        interactor?.prepareSchedule(request: Today.Schedule.Request())
        
        // configure UI elements
        configureSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        interactor?.updateScheduleStatuses(request: Today.ScheduleStatuses.Request())
    }
    
    // MARK: Routing
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        router?.passDataToNextScene(segue: segue)
    }
    
    // MARK: - Event handling
    
    
    // MARK: - Display logic
    func displayWakeUp(viewModel: Today.ViewModel.DisplayedItem) {
        wakeUpItem = viewModel
        displayedItems[0] = wakeUpItem
        
        let indexPath = IndexPath(row: 0, section: 0)
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func displaySchedule(viewModel: Today.ViewModel) {
        displayedItems = [wakeUpItem] + viewModel.displayedScheduleItems
        self.tableView.reloadData()
    }
    
    func displayActive(viewModel: Today.MoveActive.ViewModel) {
        self.tableView.reloadData()
    }
    
    // MARK: - Private
    func configureSubviews() {
        self.tableView.tableFooterView = UIView()
    }
}

// MARK: - UITableViewDataSource
extension TodayViewController {
    private enum CellIdentifiers {
        static let WakeUp: String = "wakeUpCell"
        static let Today: String = "todayCell"
        static let Active: String = "activeCell"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedItems.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = displayedItems[indexPath.row]
        return item.isActive && indexPath.row != 0 ? 100.0 : 44.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = displayedItems[indexPath.row]
        
        // WakeUp item
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.WakeUp, for: indexPath)
            cell.textLabel?.text = item.name + " " + item.plannedTime
            return cell
        }
        
        // Active item
        if item.isActive, let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.Active, for: indexPath) as? ActiveTodayCell {
            cell.textLabel?.text = item.name
            cell.detailTextLabel?.text = item.plannedTime
            cell.imageView?.image = item.image
            cell.delegate = self
            return cell
        }
        
        // normal item
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.Today, for: indexPath)
        cell.textLabel?.text = item.name
        cell.detailTextLabel?.text = item.actualTime ?? item.plannedTime
        cell.imageView?.image = item.image
        
        // marks the cell as 'inactive' or 'done'
        cell.textLabel?.alpha = item.isDone ? 1.0 : 0.2
        cell.detailTextLabel?.alpha = item.isDone ? 1.0 : 0.2
        cell.imageView?.alpha = item.isDone ? 1.0 : 0.2
        cell.accessoryType = item.isDone ? .checkmark : .none
        
        // marks the cell as 'missed'
        cell.contentView.backgroundColor = item.isMissed ? UIColor.red.withAlphaComponent(0.1) : .white
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let willSelectMealWhileNotAwakened = (indexPath.row > 0 && wakeUpItem.actualTime == nil)
        return willSelectMealWhileNotAwakened ? nil : indexPath
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // The Wake Up item
        if indexPath.row == 0 && wakeUpItem.actualTime == nil {
            interactor?.updateWakeUpItem(request: Today.WakeUp.Request(date: Date()))
            interactor?.updateSchedule(request: Today.Schedule.Request())
            interactor?.moveActiveItem(request: Today.MoveActive.Request(fromIndex: nil, actualDate: nil)) // move active from the change the first eating's status
        }
    }
}

extension TodayViewController: ActiveTodayCellDelegate {
    func didTouchDone(_ cell: ActiveTodayCell) {
        guard let indexPath = self.tableView.indexPath(for: cell) else { return }
        
        let item = displayedItems[indexPath.row]
        if item.isActive {
            interactor?.moveActiveItem(request: Today.MoveActive.Request(fromIndex: indexPath.row - 1, actualDate: Date())) // -1 because of the first WakeUp item
        }
    }
}
