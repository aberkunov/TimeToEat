//
//  SettingsViewControllerTests.swift
//  TimeToEat
//
//  Created by Alexander Berkunov on 05.06.17.
//  Copyright © 2017 MB. All rights reserved.
//

import XCTest
@testable import TimeToEat

class SettingsViewControllerTests: XCTestCase {
    // MARK: - Subject under test
    var sut: SettingsViewController!
    var window: UIWindow!
    
    // MARK: - Test lifecycle
    override func setUp() {
        super.setUp()
        window = UIWindow()
        setupSettingsViewController()
    }
    
    override func tearDown() {
        window = nil
        super.tearDown()
    }
    
    // MARK: - Test setup
    func setupSettingsViewController() {
        let bundle = Bundle.main
        let storyboard = UIStoryboard(name: "Main", bundle: bundle)
        sut = storyboard.instantiateViewController(withIdentifier: "SettingsViewController") as? SettingsViewController
    }
    
    func loadView() {
        window.addSubview(sut.view)
        RunLoop.current.run(until: Date())
    }
    
    // MARK: - Test doubles
    class SettingsInteractorSpy: SettingsInteractorInterface {
        var loadSettingsCalled = false
        var saveSettingsCalled = false
        var selectSettingCalled = false
        
        func loadSettings(request: SettingsModel.Load.Request) {
            loadSettingsCalled = true
        }
        
        func saveSettings(request: SettingsModel.Save.Request) {
            saveSettingsCalled = true
        }
        
        func selectSetting(request: SettingsModel.Select.Request) {
            selectSettingCalled = true
        }
    }
    
    class SettingsRouterSpy: SettingsRouter {
        var navigateToMealsOrderSceneCalled = false
        
        override func navigateToMealsOrderScene() {
            navigateToMealsOrderSceneCalled = true
        }
    }
    
    // MARK: - Tests
    func testOutletsConnectedWhenViewIsLoaded() {
        // Given
        let settingsInteractorSpy = SettingsInteractorSpy()
        sut.interactor = settingsInteractorSpy
        
        // When
        loadView()
        
        // Then
        XCTAssertNotNil(sut.consumedWaterLabel)
        XCTAssertNotNil(sut.mealOrderLabel)
        XCTAssertNotNil(sut.hiddenTextField)
        XCTAssertNotNil(sut.pickerView)
        XCTAssertNotNil(sut.toolbar)
        
        XCTAssertTrue(sut.hiddenTextField.isHidden)
        XCTAssertNotNil(sut.hiddenTextField.inputView)
        XCTAssertNotNil(sut.hiddenTextField.inputAccessoryView)
    }
    
    func testLoadSettingsOnLoad() {
        // Given
        let settingsInteractorSpy = SettingsInteractorSpy()
        sut.interactor = settingsInteractorSpy
        
        // When
        loadView()
        
        // Then
        XCTAssertTrue(settingsInteractorSpy.loadSettingsCalled)
    }
    
    func testDisplayMealsOrder() {
        // Given
        let settingsInteractorSpy = SettingsInteractorSpy()
        let settingsRouterSpy = SettingsRouterSpy()
        sut.interactor = settingsInteractorSpy
        sut.router = settingsRouterSpy
        
        // When
        loadView()
        sut.displayMealsOrderSetting(viewModel: SettingsModel.Select.ViewModel())
        
        // Then
        XCTAssertTrue(settingsRouterSpy.navigateToMealsOrderSceneCalled)
    }
}
