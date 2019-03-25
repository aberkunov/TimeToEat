//
//  TodayWorkerTests.swift
//  TimeToEat
//
//  Created by Alexander Berkunov on 06.10.17.
//  Copyright © 2017 MB. All rights reserved.
//

import XCTest
@testable import TimeToEat

class TodayWorkerTests: XCTestCase {
    // MARK: - Subject under test
    var sut: TodayWorker!
    
    // MARK: - Test lifecycle
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: - Test doubles and data
    class UserDefaultsSettingsStorageFake: UserDefaultsSettingsStorage {
        override var item: Settings {
            let meals: [Meal] = [.breakfast, .snack, .lunch, .snack, .snack, .dinner, .snack]
            let settings = Settings(glassVolume: 200, glassesPerDay: 10, meals: meals)
            return settings
        }
    }
    
    // MARK: - Tests
    func testFetchEatings() {
        
    }
    
    func testCreateEatings() {
        // Given
        sut = TodayWorker()
        sut.settingsStorage = UserDefaultsSettingsStorageFake()
        
        var dateComponents = DateComponents()
        dateComponents.year = 2017
        dateComponents.month = 10
        dateComponents.day = 6
        dateComponents.hour = 7
        let date = Calendar.current.date(from: dateComponents)!
        let day = Day(plannedWakeUpTime: date)
        
        // When
        let eatings = sut.createEatings(for: day)
        
        // Then
        XCTAssertEqual(eatings.count, 7, "Eatings count is not equal to the meals count in settings")
        
        let eating0 = eatings[0]
        var mealTimeComponents = Calendar.current.dateComponents([.hour, .minute], from: eating0.plannedDate)
        XCTAssertEqual(eating0.kind.stringValue, Meal.breakfast.rawValue)
        XCTAssertEqual(mealTimeComponents.hour!, 8)
        XCTAssertEqual(mealTimeComponents.minute!, 0)
        
        let eating1 = eatings[1]
        mealTimeComponents = Calendar.current.dateComponents([.hour, .minute], from: eating1.plannedDate)
        XCTAssertEqual(eating1.kind.stringValue, Meal.snack.rawValue)
        XCTAssertEqual(mealTimeComponents.hour!, 9)
        XCTAssertEqual(mealTimeComponents.minute!, 50)
        
        let eating2 = eatings[2]
        mealTimeComponents = Calendar.current.dateComponents([.hour, .minute], from: eating2.plannedDate)
        XCTAssertEqual(eating2.kind.stringValue, Meal.lunch.rawValue)
        XCTAssertEqual(mealTimeComponents.hour!, 11)
        XCTAssertEqual(mealTimeComponents.minute!, 40)
        
        let eatingLast = eatings.last!
        mealTimeComponents = Calendar.current.dateComponents([.hour, .minute], from: eatingLast.plannedDate)
        XCTAssertEqual(eatingLast.kind.stringValue, Meal.snack.rawValue)
        XCTAssertEqual(mealTimeComponents.hour!, 19)
        XCTAssertEqual(mealTimeComponents.minute!, 0)
    }
}
