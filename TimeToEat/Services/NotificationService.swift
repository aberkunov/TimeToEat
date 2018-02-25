//
//  NotificationService.swift
//  TimeToEat
//
//  Created by Alexander Berkunov on 20.02.18.
//  Copyright © 2018 MB. All rights reserved.
//

import Foundation
import UserNotifications

class NotificationService: NSObject {
    enum Constants {
        enum Category {
            static let Dismiss = "Dismiss"
            static let TimeToEat = "TimeToEat"
        }
        enum Action {
            static let Done = "Done"
            static let Skip = "Skip"
        }
        static let Request = "Request"
    }
    
    var notificationCenter = UNUserNotificationCenter.current()
    
    func requestAuthorization() {
        let dismissCategory = UNNotificationCategory(identifier: Constants.Category.Dismiss, actions: [], intentIdentifiers: [], options: .customDismissAction)
        
        let skipAction = UNNotificationAction(identifier: Constants.Action.Skip, title: "Skip", options: UNNotificationActionOptions(rawValue: 0))
        let doneAction = UNNotificationAction(identifier: Constants.Action.Done, title: "Done", options: .foreground)
        let timeToEatCategory = UNNotificationCategory(identifier: Constants.Category.TimeToEat,
                                                       actions: [skipAction, doneAction],
                                                       intentIdentifiers: [],
                                                       options: UNNotificationCategoryOptions(rawValue: 0))
        
        notificationCenter.setNotificationCategories([dismissCategory, timeToEatCategory])
        notificationCenter.delegate = self
        notificationCenter.requestAuthorization(options: [.badge, .sound, .alert]) { granted, error in
            if let error = error {
                print(error)
            }
        }
    }
    
    func scheduleNotification(at time: Date, text: String) {
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: "Time to eat %@", arguments: [text])
        content.body = NSString.localizedUserNotificationString(forKey: "Go go go!", arguments: nil)
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = Constants.Category.TimeToEat
        
        let components = Calendar.current.dateComponents([.minute, .hour, .day, .month, .year], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let id = Constants.Request + DateFormatter.localizedString(from: time, dateStyle: .short, timeStyle: .short)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func cancelNotification(identifier: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension NotificationService: UNUserNotificationCenterDelegate {
    // Foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Update the app interface directly.
        
        // Play a sound.
        completionHandler(UNNotificationPresentationOptions.sound)
    }
    
    // Which action was selected by the user
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        print("response.actionIdentifier = \(response.actionIdentifier)")
        
        if response.actionIdentifier == UNNotificationDismissActionIdentifier {
            // The user dismissed the notification without taking action
        }
        else if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            // The user launched the app
        }
        else {
            
        }
        
        completionHandler()
    }
}
