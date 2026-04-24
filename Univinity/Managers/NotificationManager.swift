//
//  NotificationManager.swift
//  Univinity
//
//  Created by Sara Kanu on 4/22/26.
//
import Foundation
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { _, _ in }
    }

    func scheduleReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Univinity"
        content.body = "Come back and discover more colleges today."
        content.sound = .default

        var date = DateComponents()
        date.hour = 18

        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        let request = UNNotificationRequest(
            identifier: "daily_college_reminder",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }
}
