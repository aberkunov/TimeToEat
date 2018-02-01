//
//  SettingsInteractorTests.swift
//  TimeToEat
//
//  Created by Alexander Berkunov on 05.06.17.
//  Copyright © 2017 MB. All rights reserved.
//

@testable import TimeToEat
import XCTest

class SettingsInteractorTests: XCTestCase {
    // MARK: - Subject under test
    var sut: SettingsInteractor!
    
    // MARK: - Test lifecycle
    override func setUp() {
        super.setUp()
        setupSettingsInteractor()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: - Test setup
    func setupSettingsInteractor() {
        sut = SettingsInteractor()
    }
    
    // MARK: - Test doubles
    class SettingsPresenterSpy: SettingsPresenterInterface {
        var presentSettingsResponse: SettingsModel.Load.Response!
        var presentSavedSettingsResponse: SettingsModel.Save.Response!
        var presentDrinkingWaterSettingResponse: SettingsModel.Select.Response!
        var presentMealsOrderSettingResponse: SettingsModel.Select.Response!
        
        func presentSettings(response: SettingsModel.Load.Response) {
            presentSettingsResponse = response
        }
        
        func presentSavedSettings(response: SettingsModel.Save.Response) {
            presentSavedSettingsResponse = response
        }
        
        func presentDrinkingWaterSetting(response: SettingsModel.Select.Response) {
            presentDrinkingWaterSettingResponse = response
        }
        
        func presentMealsOrderSetting(response: SettingsModel.Select.Response) {
            presentMealsOrderSettingResponse = response
        }
    }
    
    class MockStorage: UserDefaultsSettingsStorage {
        var currentSettings: Settings!
        var saveCalled = false
        
        init(volume: Int, count: Int, meals: [Meal]) {
            currentSettings = Settings(glassVolume: volume, glassesPerDay: count, meals: meals)
        }
        
        override func registerInitial() {
        }
        
        override func save(_ item: Settings) {
            saveCalled = true
        }
        
        override var item: Settings {
            return currentSettings
        }
    }
    
    // MARK: - Tests
    func testLoadSettings() {
        // Given
        let settingsPresenterSpy = SettingsPresenterSpy()
        sut.presenter = settingsPresenterSpy
        sut.settingsStorable = MockStorage(volume: 200, count: 10, meals: [.breakfast, .dinner])
        
        // When
        let request = SettingsModel.Load.Request()
        sut.loadSettings(request: request)
        
        // Then
        let response = settingsPresenterSpy.presentSettingsResponse!
        XCTAssertNotNil(response)
        XCTAssertEqual(response.glassVolume, 200)
        XCTAssertEqual(response.numberOfGlasses, 10)
        XCTAssertEqual(response.meals, [.breakfast, .dinner])
    }
    
    func testSaveSettings() {
        // Given
        let settingsPresenterSpy = SettingsPresenterSpy()
        sut.presenter = settingsPresenterSpy
        let mockStorable = MockStorage(volume: 200, count: 10, meals: [.breakfast, .dinner])
        sut.settingsStorable = mockStorable
        
        // When
        let request = SettingsModel.Save.Request(numberOfGlasses: 2, glassVolume: 250)
        sut.saveSettings(request: request)
        
        // Then
        let response = settingsPresenterSpy.presentSavedSettingsResponse!
        XCTAssertNotNil(response)
        XCTAssertEqual(response.glassVolume, 250)
        XCTAssertEqual(response.numberOfGlasses, 2)
        // check that the interactor triggers the 'save' function on storable
        XCTAssertTrue(mockStorable.saveCalled)
    }
    
    func testSelectSetting() {
        // Given
        let settingsPresenterSpy = SettingsPresenterSpy()
        sut.presenter = settingsPresenterSpy
        
        // When 1
        let request1 = SettingsModel.Select.Request(type: .drinkingWater)
        sut.selectSetting(request: request1)
        // Then 1
        XCTAssertNotNil(settingsPresenterSpy.presentDrinkingWaterSettingResponse)
        
        // When 2
        let request2 = SettingsModel.Select.Request(type: .mealOrder)
        sut.selectSetting(request: request2)
        // Then 2
        XCTAssertNotNil(settingsPresenterSpy.presentMealsOrderSettingResponse)
    }
}
