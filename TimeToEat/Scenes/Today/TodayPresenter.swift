//
//  TodayPresenter.swift
//  TimeToEat
//
//  Created by Alexander Berkunov on 04.05.17.
//  Copyright © 2017 MB. All rights reserved.
//

import UIKit

protocol TodayPresenterInterface {
    func presentWakeUp(response: Today.WakeUp.Response)
    func presentSchedule(response: Today.Schedule.Response)
}

class TodayPresenter: TodayPresenterInterface {
    weak var viewController: TodayViewControllerInterface?
    
    // MARK: - Presentation logic
    func presentWakeUp(response: Today.WakeUp.Response) {
        let name = response.isAwakened ? "I woke up at" : "I woke up!"
        let timeText = response.isAwakened ? DateFormatter.localizedString(from: response.date, dateStyle: .none, timeStyle: .short) : String()
        let actualWakeUpTime = response.isAwakened ? timeText : nil
        let viewModel = Today.ViewModel.DisplayedItem(name: name, plannedTime: timeText, actualTime: actualWakeUpTime, image:nil, isActive: true, isDone: false)
        viewController?.displayWakeUp(viewModel: viewModel)
    }
    
    func presentSchedule(response: Today.Schedule.Response) {
        let allEatingModels = response.eatings.map { eating -> Today.ViewModel.DisplayedItem in
            let name = NSLocalizedString(eating.kind.stringValue, comment: "")
            let plannedTimeText = DateFormatter.localizedString(from: eating.plannedDate, dateStyle: .none, timeStyle: .short)
            var actualTimeText: String?
            if let actualDate = eating.actualDate {
                actualTimeText = "Finished at " + DateFormatter.localizedString(from: actualDate, dateStyle: .none, timeStyle: .short)
            }
            let image = eating.kind.image
            let isActive = eating.status == .active
            let isDone = eating.status == .done
            let viewModel = Today.ViewModel.DisplayedItem(name: name, plannedTime: plannedTimeText, actualTime: actualTimeText, image: image, isActive: isActive, isDone: isDone)
            return viewModel
        }
        viewController?.displaySchedule(viewModel: Today.ViewModel(displayedScheduleItems: allEatingModels))
    }
    
    // MARK: - Private
}
