//
//  TodayInteractor.swift
//  TimeToEat
//
//  Created by Alexander Berkunov on 04.05.17.
//  Copyright © 2017 MB. All rights reserved.
//

import UIKit

protocol TodayInteractorInterface {
    func updateWakeUpItem(request: Today.WakeUp.Request)
    func prepareSchedule(request: Today.Schedule.Request)
    func updateSchedule(request: Today.Schedule.Request)
    func updateScheduleStatuses(request: Today.ScheduleStatuses.Request)
    func moveActiveItem(request: Today.MoveActive.Request)
}

protocol TodayDataStore {
    var today: Day { get }
    var eatings: [Eating] { get }
}

class TodayInteractor: TodayInteractorInterface, TodayDataStore {
    var presenter: TodayPresenterInterface?
    var worker = TodayWorker()
    var notificationService = NotificationService()
    
    private(set) var today = Day()
    private(set) var eatings = [Eating]()
    private var notificationObservers: [NSObjectProtocol] = []
    private var timer: Timer?
    
    init() {
        today = worker.today()
        
        // notifications
        let onDayChanged = NotificationCenter.default.addObserver(forName: .NSCalendarDayChanged, object: nil, queue: .main) { [weak self] _ in
            if let day = self?.worker.today() {
                self?.today = day
            }
            self?.updateWakeUpItem(request: Today.WakeUp.Request(date: nil))
            self?.prepareSchedule(request: Today.Schedule.Request())
        }
        let onEnterForeground = NotificationCenter.default.addObserver(forName: .UIApplicationWillEnterForeground, object: nil, queue: .main) { [weak self] _ in
            self?.updateScheduleStatuses(request: Today.ScheduleStatuses.Request())
        }
        notificationObservers = [onDayChanged, onEnterForeground]
    }
    
    deinit {
        for observer in notificationObservers {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    // MARK: - Business logic
    func updateWakeUpItem(request: Today.WakeUp.Request) {
        // wake up should happen only once a day, just present the wake up time if actualWakeUp is available
        if let wakeUpTime = today.actualWakeUp {
            presenter?.presentWakeUp(response: Today.WakeUp.Response(date: wakeUpTime, isAwakened: true))
            return
        }
        
        // update the current day with provided wakeUpDate if it's there in the request
        if let wakeUpDate = request.date {
            let day = worker.today()
            worker.update(day: day, with: wakeUpDate)
        }
        
        let now = request.date ?? Date()
        presenter?.presentWakeUp(response: Today.WakeUp.Response(date: now, isAwakened: request.date != nil))
    }
    
    ///
    func prepareSchedule(request: Today.Schedule.Request) {
        let today = worker.today()
        eatings = worker.fetchEatings(for: today)
        if eatings.count == 0 {
            eatings = worker.createEatings(for: today)
        }
        
        let response = Today.Schedule.Response(wakeUpDate: today.actualWakeUp, eatings: eatings)
        presenter?.presentSchedule(response: response)
    }
    
    /// Updates the schedule with actual wake-up time and current time
    func updateSchedule(request: Today.Schedule.Request) {
        let today = worker.today()
        eatings = worker.updateEatings(for: today)
        eatings.forEach { scheduleNotification(for: $0) }
        
        let response = Today.Schedule.Response(wakeUpDate: today.actualWakeUp, eatings: eatings)
        presenter?.presentSchedule(response: response)
    }
    
    /// Updates the statuses of the current schedule
    func updateScheduleStatuses(request: Today.ScheduleStatuses.Request) {
        guard let actualWakeUp = today.actualWakeUp else { return }
        
        eatings = worker.updateTodayStatuses()
        let response = Today.Schedule.Response(wakeUpDate: actualWakeUp, eatings: eatings)
        presenter?.presentSchedule(response: response)
    }
    
    /// Updates the given eating and asks the presenter to reload the whole schedule
    func moveActiveItem(request: Today.MoveActive.Request) {
        defer {
            let response = Today.Schedule.Response(wakeUpDate: today.actualWakeUp, eatings: eatings)
            presenter?.presentSchedule(response: response)
        }
        
        // guard handles the case for the very first item, e.g. when user presses 'I woke up'
        guard let fromIndex = request.fromIndex else {
            if let firstEating = eatings.first {
                firstEating.status = .active
                worker.updateActive(eating: firstEating)
                scheduleNotification(for: firstEating)
                // presenter?.presentSchedule takes place in defer
            }
            return
        }
        
        let fromEating = eatings[fromIndex]
        fromEating.status = .done
        fromEating.actualDate = request.actualDate
        worker.updateActive(eating: fromEating)
        cancelNotification(for: fromEating)
        
        let toIndex = fromIndex + 1
        if toIndex < eatings.count {
            let toEating = eatings[toIndex]
            toEating.status = .active
            worker.updateActive(eating: toEating)
        }
    }
    
    // MARK: - Local Notifications
    func scheduleNotification(for eating: Eating) {
        notificationService.scheduleNotification(at: eating.plannedDate, text: eating.kind.stringValue)
        
        let interval: TimeInterval = eating.plannedDate.timeIntervalSince(Date())
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] timer in
            self?.updateScheduleStatuses(request: Today.ScheduleStatuses.Request())
        }
    }
    
    func cancelNotification(for eating: Eating) {
        let id = "Request" + DateFormatter.localizedString(from: eating.plannedDate, dateStyle: .medium, timeStyle: .medium)
        notificationService.cancelNotification(identifier: id)
        
        timer?.invalidate()
        timer = nil
    }
}
