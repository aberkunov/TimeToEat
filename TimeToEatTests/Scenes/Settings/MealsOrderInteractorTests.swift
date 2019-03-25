//
//  MealsOrderInteractorTests.swift
//  TimeToEat
//
//  Created by Alexander Berkunov on 12.06.17.
//  Copyright © 2017 MB. All rights reserved.
//

@testable import TimeToEat
import XCTest

class MealsOrderInteractorTests: XCTestCase {
    // MARK: - Subject under test
    var sut: MealsOrderInteractor!
    
    // MARK: - Test lifecycle
    override func setUp() {
        super.setUp()
        setupMealsOrderInteractor()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: - Test setup
    func setupMealsOrderInteractor() {
        sut = MealsOrderInteractor()
    }
    
    // MARK: - Test doubles
    class MealsOrderPresenterSpy: MealsOrderPresenterInterface {
        var presentMealsResponse: MealsOrder.Load.Response!
        var presentAddedMealResponse: MealsOrder.Add.Response!
        var presentRemoveMealResponse: MealsOrder.Remove.Response!
        
        func presentMeals(response: MealsOrder.Load.Response) {
            presentMealsResponse = response
        }
        
        func presentAddedMeal(response: MealsOrder.Add.Response) {
            presentAddedMealResponse = response
        }
        
        func presentRemovedMeal(response: MealsOrder.Remove.Response) {
            presentRemoveMealResponse = response
        }
    }
    
    class MockStorage: UserDefaultsSettingsStorage {
        var currentSettings: Settings
        
        init(meals: [Meal]) {
            currentSettings = Settings(glassVolume: 0, glassesPerDay: 0, meals: meals)
        }
        
        override func registerInitial() {
        }
        
        override func save(_ item: Settings) {
            currentSettings = item
        }
        
        override var item: Settings {
            return currentSettings
        }
    }
    
    // MARK: - Tests
    func testLoadMeals() {
        // Given
        let mealsOrderInteractorOutputSpy = MealsOrderPresenterSpy()
        sut.presenter = mealsOrderInteractorOutputSpy
        sut.settingsStorable = MockStorage(meals: [.breakfast, .dinner])
        
        // When 1
        let request = MealsOrder.Load.Request()
        sut.loadMeals(request: request)
        
        // Then 1
        let response = mealsOrderInteractorOutputSpy.presentMealsResponse!
        XCTAssertNotNil(response)
        XCTAssertEqual(response.meals, [.breakfast, .dinner])
        
        // Then 2
        sut.settingsStorable = MockStorage(meals: [.breakfast, .snack, .snack, .snack])
        sut.loadMeals(request: request)
        XCTAssertEqual(mealsOrderInteractorOutputSpy.presentMealsResponse.meals, [.breakfast, .snack, .snack, .snack])
        
        // Then 3
        sut.settingsStorable = MockStorage(meals: [])
        sut.loadMeals(request: request)
        XCTAssertEqual(mealsOrderInteractorOutputSpy.presentMealsResponse.meals.count, 0)
        
        // Then 4
        sut.settingsStorable = MockStorage(meals: [.dinner, .dinner, .dinner, .dinner, .dinner, .dinner])
        sut.loadMeals(request: request)
        XCTAssertEqual(mealsOrderInteractorOutputSpy.presentMealsResponse.meals, [.dinner, .dinner, .dinner, .dinner, .dinner, .dinner])
        
    }
    
    func testAddMeal() {
        // Given
        let mealsOrderInteractorOutputSpy = MealsOrderPresenterSpy()
        let mock = MockStorage(meals: [.breakfast])
        sut.presenter = mealsOrderInteractorOutputSpy
        sut.settingsStorable = mock
        
        // When 1
        let request1 = MealsOrder.Add.Request(meal: .snack)
        sut.addMeal(request: request1)
        
        // Then 1
        let response = mealsOrderInteractorOutputSpy.presentAddedMealResponse!
        XCTAssertNotNil(response)
        XCTAssertEqual(sut.settingsStorable.item.meals.count, 2)
        XCTAssertEqual(sut.settingsStorable.item.meals, [.breakfast, .snack])
        
        // When 2
        let request2 = MealsOrder.Add.Request(meal: .lunch)
        sut.addMeal(request: request2)
        
        // Then 2
        XCTAssertEqual(sut.settingsStorable.item.meals.count, 3)
        XCTAssertEqual(sut.settingsStorable.item.meals, [.breakfast, .snack, .lunch])
    }
    
    func testRemoveMeals() {
        // Given
        let mealsOrderInteractorOutputSpy = MealsOrderPresenterSpy()
        let mock = MockStorage(meals: [.breakfast, .dinner, .lunch])
        sut.presenter = mealsOrderInteractorOutputSpy
        sut.settingsStorable = mock
        
        // When 1
        let request1 = MealsOrder.Remove.Request(atIndex: 20)
        sut.removeMeal(request: request1)
        // Then 1
        XCTAssertNil(mealsOrderInteractorOutputSpy.presentRemoveMealResponse)
        
        // When 2
        let request2 = MealsOrder.Remove.Request(atIndex: 1)
        sut.removeMeal(request: request2)
        // Then 2
        let response = mealsOrderInteractorOutputSpy.presentRemoveMealResponse!
        XCTAssertNotNil(response)
        XCTAssertEqual(sut.settingsStorable.item.meals.count, 2)
        XCTAssertEqual(sut.settingsStorable.item.meals, [.breakfast, .lunch])
        
        // When 3
        let request3 = MealsOrder.Remove.Request(atIndex: 1)
        sut.removeMeal(request: request3)
        // Then 3
        XCTAssertEqual(sut.settingsStorable.item.meals.count, 1)
        XCTAssertEqual(sut.settingsStorable.item.meals, [.breakfast])
        
        // When 4
        let request4 = MealsOrder.Remove.Request(atIndex: 0)
        sut.removeMeal(request: request4)
        // Then 4
        XCTAssertEqual(sut.settingsStorable.item.meals.count, 0)
        XCTAssertEqual(sut.settingsStorable.item.meals, [])
        
        // When 5
        mealsOrderInteractorOutputSpy.presentRemoveMealResponse = nil
        let request5 = MealsOrder.Remove.Request(atIndex: 0)
        sut.removeMeal(request: request5)
        // Then 5
        XCTAssertNil(mealsOrderInteractorOutputSpy.presentRemoveMealResponse)
    }
    
    func testReorderMeals() {
        // Given
        let mealsOrderInteractorOutputSpy = MealsOrderPresenterSpy()
        let mock = MockStorage(meals: [.breakfast, .snack, .dinner, .snack, .lunch, .snack])
        sut.presenter = mealsOrderInteractorOutputSpy
        sut.settingsStorable = mock
        
        // When 1
        let request1 = MealsOrder.Reorder.Request(fromIndex: -20, toIndex: 2)
        sut.reorderMeals(request: request1)
        // Then 1
        XCTAssertEqual(sut.settingsStorable.item.meals.count, 6)
        XCTAssertEqual(sut.settingsStorable.item.meals[2], .dinner)
        
        // When 2
        let request2 = MealsOrder.Reorder.Request(fromIndex: 0, toIndex: 1)
        sut.reorderMeals(request: request2)
        // Then 2
        XCTAssertEqual(sut.settingsStorable.item.meals.count, 6)
        XCTAssertEqual(sut.settingsStorable.item.meals[0], .snack)
        XCTAssertEqual(sut.settingsStorable.item.meals[1], .breakfast)
        
        // When 3
        let request3 = MealsOrder.Reorder.Request(fromIndex: 1, toIndex: 5)
        sut.reorderMeals(request: request3)
        // Then 3
        XCTAssertEqual(sut.settingsStorable.item.meals[1], .dinner)
        XCTAssertEqual(sut.settingsStorable.item.meals[5], .breakfast)
        
        // When 4
        let request4 = MealsOrder.Reorder.Request(fromIndex: 4, toIndex: 1)
        sut.reorderMeals(request: request4)
        // Then 4
        XCTAssertEqual(sut.settingsStorable.item.meals[0], .snack)
        XCTAssertEqual(sut.settingsStorable.item.meals[1], .snack)
        XCTAssertEqual(sut.settingsStorable.item.meals[2], .dinner)
        XCTAssertEqual(sut.settingsStorable.item.meals[3], .snack)
        XCTAssertEqual(sut.settingsStorable.item.meals[4], .lunch)
        XCTAssertEqual(sut.settingsStorable.item.meals[5], .breakfast)
    }
}
