//
//  TodayModels.swift
//  TimeToEat
//
//  Created by Alexander Berkunov on 04.05.17.
//  Copyright © 2017 MB. All rights reserved.
//

import UIKit

enum Today {
    enum WakeUp {
        struct Request {
            let date: Date?
        }
        struct Response {
            let date: Date
            let isAwakened: Bool
        }
        // ViewModel will be Today.ViewModel
    }
    
    enum Schedule {
        struct Request {
        }
        struct Response {
            let wakeUpDate: Date?
            let eatings: [Eating]
        }
        // ViewModel will be Today.ViewModel
    }
    
    enum MoveActive {
        struct Request {
            let fromIndex: Int?
            let actualDate: Date?
        }
        struct Response {
            
        }
        struct ViewModel {
            
        }
    }
    
    struct ViewModel {
        struct DisplayedItem {
            let name: String
            let plannedTime: String
            let actualTime: String?
            let image: UIImage?
            let isActive: Bool
            let isDone: Bool
        }
        let displayedScheduleItems: [DisplayedItem]
    }
}
