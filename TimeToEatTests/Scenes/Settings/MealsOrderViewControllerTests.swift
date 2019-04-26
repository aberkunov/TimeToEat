//
//  MealsOrderViewControllerTests.swift
//  TimeToEat
//
//  Created by Alexander Berkunov on 12.06.17.
//  Copyright © 2017 MB. All rights reserved.
//

import XCTest
@testable import TimeToEat

class MealsOrderViewControllerTests: XCTestCase {
    // MARK: - Subject under test
    var sut: MealsOrderViewController!
    var window: UIWindow!
    
    // MARK: - Test lifecycle
    override func setUp() {
        super.setUp()
        window = UIWindow()
        setupMealsOrderViewController()
    }
    
    override func tearDown() {
        window = nil
        super.tearDown()
    }
    
    // MARK: - Test setup
    func setupMealsOrderViewController() {
        let bundle = Bundle.main
        let storyboard = UIStoryboard(name: "Main", bundle: bundle)
        sut = storyboard.instantiateViewController(withIdentifier: "MealsOrderViewController") as? MealsOrderViewController
    }
    
    func loadView() {
        window.addSubview(sut.view)
        RunLoop.current.run(until: Date())
    }
    
    // MARK: - Test doubles
    class MealsOrderInteractorSpy: MealsOrderInteractorInterface {
        var loadMealsCalled = false
        var addMealCalled = false
        var removeMealCalled = false
        var reorderMealsCalled = false
        
        func loadMeals(request: MealsOrder.Load.Request) {
            loadMealsCalled = true
        }
        
        func addMeal(request: MealsOrder.Add.Request) {
            addMealCalled = true
        }
        
        func removeMeal(request: MealsOrder.Remove.Request) {
            removeMealCalled = true
        }
        
        func reorderMeals(request: MealsOrder.Reorder.Request) {
            reorderMealsCalled = true
        }
    }
    
    class TableViewSpy: UITableView {
        // MARK: Method call expectations
        var deleteRowsCalled = false
        
        // MARK: Spied methods
        override func deleteRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
            deleteRowsCalled = true
        }
    }
    
    // MARK: - Tests
    func testOutletsConnectedWhenViewIsLoaded() {
        // Given
        let mealsOrderViewControllerOutputSpy = MealsOrderInteractorSpy()
        sut.interactor = mealsOrderViewControllerOutputSpy
        
        // When
        loadView()
        
        // Then
        XCTAssertNotNil(sut.tableView)
    }
    
    func testLoadMealsOnLoad() {
        // Given
        let mealsOrderViewControllerOutputSpy = MealsOrderInteractorSpy()
        sut.interactor = mealsOrderViewControllerOutputSpy
        
        // When
        loadView()
        
        // Then
        XCTAssertTrue(mealsOrderViewControllerOutputSpy.loadMealsCalled)
    }
    
    func testDisplayRemovedMeal() {
        // Given
        let mealsOrderViewControllerOutputSpy = MealsOrderInteractorSpy()
        let tableViewSpy = TableViewSpy()
        sut.interactor = mealsOrderViewControllerOutputSpy
        sut.tableView = tableViewSpy
        sut.displayedMeals = [MealViewModel(name: "1", image: nil),
                              MealViewModel(name: "Meal 2", image: nil),
                              MealViewModel(name: "3", image: nil)]
        
        // When
        loadView()
        let removeViewModel = MealsOrder.Remove.ViewModel(atIndex: 1)
        sut.displayRemovedMeal(viewModel: removeViewModel)
        
        // Then
        XCTAssertTrue(tableViewSpy.deleteRowsCalled)
        XCTAssertEqual(sut.displayedMeals.count, 2)
    }
}
