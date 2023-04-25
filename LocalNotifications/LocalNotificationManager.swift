//
//  LocalNotificationManager.swift
//  LocalNotifications
//
//  Created by  Юлия Григорьева on 24.04.2023.
//

import SwiftUI
import NotificationCenter

@MainActor
class LocalNotificationManager: NSObject, ObservableObject {

    let notificationCenter = UNUserNotificationCenter.current()

    // To check if the notification access was granted by the user
    @Published var isGranted = false
    // Pending notifications to be displayed to the user
    @Published var pendingRequests: [UNNotificationRequest] = []

    /// Request notification authorization
    func requestAuthorization() async throws {
        try await notificationCenter
            .requestAuthorization(options: [.sound, .badge, .alert])

        await getCurrentSettings()
    }

    /// Makes sure that the user has granted access to notifications
    func getCurrentSettings() async {
        let currentSettings = await notificationCenter.notificationSettings()
        isGranted = (currentSettings.authorizationStatus == .authorized)
    }

    /// Opens the default device notifications settings so the user can change the access previously given to our app
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                Task {
                    await UIApplication.shared.open(url)
                }
            }
        }
    }

    /// Schedule a local notification
    func schedule(date: Date) async {

        let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let content = UNMutableNotificationContent()
        content.title = "НАПОМИНАЛКА"
        content.body = "Позвонить маме"
        content.badge = 1
        content.sound = UNNotificationSound.default

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        try? await notificationCenter.add(request)
        await getPendingRequests()
    }

    /// Check how many pending local notifications requests we have
    func getPendingRequests() async {
        pendingRequests = await notificationCenter.pendingNotificationRequests()
        print("Pending notifications: \(pendingRequests.count)")
    }

    /// Remove a specific local notification request given its id
    func removeRequest(withIdentifier identifier: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        if let index = pendingRequests.firstIndex(where: {$0.identifier == identifier}) {
            pendingRequests.remove(at: index)
            print("Pending notifications: \(pendingRequests.count)")
        }
    }

    /// Removes all pending local notifications
    func clearRequests(ignoreNotifications: [String] = []) {
        // Handles
        if ignoreNotifications.isEmpty {
            notificationCenter.removeAllPendingNotificationRequests()
            pendingRequests.removeAll()
        } else {
            for request in pendingRequests {
                if(!(ignoreNotifications.contains(request.identifier))) {
                    removeRequest(withIdentifier: request.identifier)
                }
            }
        }

        print("Pending: \(pendingRequests.count)")
    }
}


