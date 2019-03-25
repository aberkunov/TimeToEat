//
//  SettingsPresenterTests.swift
//  TimeToEat
//
//  Created by Alexander Berkunov on 05.06.17.
//  Copyright © 2017 MB. All rights reserved.
//

@testable import TimeToEat
import XCTest

class SettingsPresenterTests: XCTestCase {
    // MARK: - Subject under test
    var sut: SettingsPresenter!
    
    // MARK: - Test lifecycle
    override func setUp() {
        super.setUp()
        setupSettingsPresenter()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: - Test setup
    func setupSettingsPresenter() {
        sut = SettingsPresenter()
    }
    
    // MARK: - Test doubles
    class SettingsViewControllerSpy: SettingsViewControllerInterface {
        // MARK: Argument expectations
        var loadViewModel: SettingsModel.Load.ViewModel!
        var saveViewModel: SettingsModel.Save.ViewModel!
        var selectDrinkingWaterViewModel: SettingsModel.Select.ViewModel!
        var selectMealsOrderViewModel: SettingsModel.Select.ViewModel!
        
        func displaySettings(viewModel: SettingsModel.Load.ViewModel) {
            loadViewModel = viewModel
        }
        
        func displaySavedSettings(viewModel: SettingsModel.Save.ViewModel) {
            saveViewModel = viewModel
        }
        
        func displayDrinkingWaterPicker(viewModel: SettingsModel.Select.ViewModel) {
            selectDrinkingWaterViewModel = viewModel
        }
        
        func displayMealsOrderSetting(viewModel: SettingsModel.Select.ViewModel) {
            selectMealsOrderViewModel = viewModel
        }
    }
    
    // MARK: - Tests
    func testPresentSettings() {
        // Given
        let settingsViewControllerSpy = SettingsViewControllerSpy()
        sut.viewController = settingsViewControllerSpy
        
        // When
        let response = SettingsModel.Load.Response(numberOfGlasses: 5, glassVolume: 250, meals: [.breakfast, .dinner])
        sut.presentSettings(response: response)
        
        // Then
        let viewModel = settingsViewControllerSpy.loadViewModel
        XCTAssertNotNil(viewModel)
        XCTAssertEqual(viewModel!.consumedDrinkingWater, "5 glasses (1.2 liter)")
        XCTAssertEqual(viewModel!.orderedMeals, "Breakfast, Dinner")
        XCTAssertEqual(viewModel!.numberOfGlasses, 5)
        XCTAssertEqual(viewModel!.glassVolume, 250)
    }
    
    func testPresentSavedSettings() {
        // Given
        let settingsViewControllerSpy = SettingsViewControllerSpy()
        sut.viewController = settingsViewControllerSpy
        
        // When
        let response = SettingsModel.Save.Response(numberOfGlasses: 4, glassVolume: 250)
        sut.presentSavedSettings(response: response)
        
        // Then
        let viewModel = settingsViewControllerSpy.saveViewModel
        XCTAssertNotNil(viewModel)
        XCTAssertEqual(viewModel!.consumedDrinkingWater, "4 glasses (1.0 liter)")
    }
    
    func testPresentDrinkingWaterSetting() {
        // Given
        let settingsViewControllerSpy = SettingsViewControllerSpy()
        sut.viewController = settingsViewControllerSpy
        
        // When
        let response = SettingsModel.Select.Response()
        sut.presentDrinkingWaterSetting(response: response)
        
        // Then
        XCTAssertNotNil(settingsViewControllerSpy.selectDrinkingWaterViewModel)
    }
    
    func testPresentMealsOrderSetting() {
        // Given
        let settingsViewControllerSpy = SettingsViewControllerSpy()
        sut.viewController = settingsViewControllerSpy
        
        // When
        let response = SettingsModel.Select.Response()
        sut.presentMealsOrderSetting(response: response)
        
        // Then
        XCTAssertNotNil(settingsViewControllerSpy.selectMealsOrderViewModel)
    }
}
