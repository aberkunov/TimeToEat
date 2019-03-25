//
//  UserDefaultsSettingsStorageTests.swift
//  TimeToEat
//
//  Created by Alexander Berkunov on 22.06.17.
//  Copyright © 2017 MB. All rights reserved.
//

import XCTest
@testable import TimeToEat

class UserDefaultsSettingsStorageTests: XCTestCase {
    // MARK: - Subject under test
    var sut: UserDefaultsSettingsStorage!
    
    private var testableUserDefaults: UserDefaults!
    private let userDefaultsSuiteName = "TestableUserDefaults"
    
    // MARK: Test setup
    override func setUp() {
        super.setUp()
        testableUserDefaults = UserDefaults(suiteName: userDefaultsSuiteName)
    }
    
    override func tearDown() {
        UserDefaults().removePersistentDomain(forName: userDefaultsSuiteName)
        super.tearDown()
    }
    
    // MARK: - Tests
    func testRegisterInitial() {
        // Given
        sut = UserDefaultsSettingsStorage(userDefaults: testableUserDefaults)
        
        // When
        sut.registerInitial()
        
        // Then
        let volume = testableUserDefaults.object(forKey: Constants.UserDefaults.Settings.GlassVolume)
        let count = testableUserDefaults.object(forKey: Constants.UserDefaults.Settings.GlassesPerDay)
        let meals = testableUserDefaults.object(forKey: Constants.UserDefaults.Settings.Meals)
        
        // default values might be updated, just check theirs type
        XCTAssertTrue(volume is Int)            // 200 ml
        XCTAssertTrue(count is Int)             // 5
        XCTAssertTrue(meals is [String])        // [Breakfast, Snack, Lunch, Snack, Dinner]
    }
    
    func testSave() {
        // Given
        sut = UserDefaultsSettingsStorage(userDefaults: testableUserDefaults)
        
        // When
        let settings = Settings(glassVolume: 200, glassesPerDay: 1, meals: [.snack])
        sut.save(settings)
        
        // Then
        let volume = testableUserDefaults.object(forKey: Constants.UserDefaults.Settings.GlassVolume)
        let count = testableUserDefaults.object(forKey: Constants.UserDefaults.Settings.GlassesPerDay)
        let meals = testableUserDefaults.array(forKey: Constants.UserDefaults.Settings.Meals)
        XCTAssertEqual(volume as? Int, 200)
        XCTAssertEqual(count as? Int, 1)
        XCTAssertEqual(meals as! [String], [Meal.snack.rawValue])
    }
    
    func testGetSettings() {
        // Given
        sut = UserDefaultsSettingsStorage(userDefaults: testableUserDefaults)
        
        // When
        let originalSettings = sut.item
        // Then
        XCTAssertEqual(originalSettings.glassVolume, 200)
        XCTAssertEqual(originalSettings.glassesPerDay, 5)
        
        // When
        let settings = Settings(glassVolume: 400, glassesPerDay: 3, meals: [.breakfast, .lunch])
        sut.save(settings)
        let testSettings = sut.item
        // Then
        XCTAssertEqual(testSettings.glassVolume, 400)
        XCTAssertEqual(testSettings.glassesPerDay, 3)
        XCTAssertEqual(testSettings.meals, [.breakfast, .lunch])
    }
}
