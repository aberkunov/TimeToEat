//
//  MealsOrderPresenterTests.swift
//  TimeToEat
//
//  Created by Alexander Berkunov on 12.06.17.
//  Copyright © 2017 MB. All rights reserved.
//

@testable import TimeToEat
import XCTest

class MealsOrderPresenterTests: XCTestCase {
    // MARK: - Subject under test
    var sut: MealsOrderPresenter!
    
    // MARK: - Test lifecycle
    override func setUp() {
        super.setUp()
        setupMealsOrderPresenter()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: - Test setup
    func setupMealsOrderPresenter() {
        sut = MealsOrderPresenter()
    }
    
    // MARK: - Test doubles
    class MealsOrderViewControllerSpy: MealsOrderViewControllerInterface {
        // MARK: Argument expectations
        var mealViewModel: MealsOrder.ViewModel!
        var addedViewModel: MealsOrder.ViewModel.DisplayedMeal!
        var removeViewModel: MealsOrder.Remove.ViewModel!
        
        func displayMeals(viewModel: MealsOrder.ViewModel) {
            mealViewModel = viewModel
        }
        
        func displayAddedMeal(viewModel: MealsOrder.ViewModel.DisplayedMeal) {
            addedViewModel = viewModel
        }
        
        func displayRemovedMeal(viewModel: MealsOrder.Remove.ViewModel) {
            removeViewModel = viewModel
        }
    }
    
    // MARK: - Tests
    func testPresentMeals() {
        // Given
        let mealsOrderPresenterOutputSpy = MealsOrderViewControllerSpy()
        sut.viewController = mealsOrderPresenterOutputSpy
        
        // When
        let response = MealsOrder.Load.Response(meals: [.breakfast, .snack, .snack, .snack])
        sut.presentMeals(response: response)
        
        // Then
        let viewModel = mealsOrderPresenterOutputSpy.mealViewModel
        XCTAssertNotNil(viewModel)
        XCTAssertEqual(viewModel?.displayedMeals.count, 4)
        XCTAssertEqual(viewModel?.displayedMeals[0].name, NSLocalizedString("breakfast", comment: ""))
        XCTAssertNotNil(viewModel?.displayedMeals[0].image)
        XCTAssertEqual(viewModel?.displayedMeals[1].name, NSLocalizedString("snack", comment: ""))
        XCTAssertNotNil(viewModel?.displayedMeals[1].image)
        XCTAssertEqual(viewModel?.displayedMeals[2].name, NSLocalizedString("snack", comment: ""))
        XCTAssertEqual(viewModel?.displayedMeals[3].name, NSLocalizedString("snack", comment: ""))
    }
    
    func testPresentAddedMeal() {
        // Given
        let mealsOrderPresenterOutputSpy = MealsOrderViewControllerSpy()
        sut.viewController = mealsOrderPresenterOutputSpy
        
        // When
        let response = MealsOrder.Add.Response(meal: .lunch)
        sut.presentAddedMeal(response: response)
        
        // Then
        XCTAssertNotNil(mealsOrderPresenterOutputSpy.addedViewModel)
        XCTAssertEqual(mealsOrderPresenterOutputSpy.addedViewModel.name, NSLocalizedString("lunch", comment: ""))
    }
    
    func testPresentRemovedMeal() {
        // Given
        let mealsOrderPresenterOutputSpy = MealsOrderViewControllerSpy()
        sut.viewController = mealsOrderPresenterOutputSpy
        
        // When
        let response = MealsOrder.Remove.Response(atIndex: 2)
        sut.presentRemovedMeal(response: response)
        
        // Then
        XCTAssertNotNil(mealsOrderPresenterOutputSpy.removeViewModel)
        XCTAssertEqual(mealsOrderPresenterOutputSpy.removeViewModel.atIndex, 2)
    }
}
