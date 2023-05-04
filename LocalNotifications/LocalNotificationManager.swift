//
//  LocalNotificationManager.swift
//  LocalNotifications
//
//  Created by  Юлия Григорьева on 24.04.2023.
//

import SwiftUI
import NotificationCenter

enum LocalNotificationError: Error, LocalizedError {
    case other(Error)
    case scheduleFail(Error)

    var errorDescription: String {
        switch self {
        case .other(let error): return "Unknown error: \(error.localizedDescription)"
        case .scheduleFail(let error): return "Schedule fail. Reason: \(error.localizedDescription)"
        }
    }

    static func map(_ error: Error) -> LocalNotificationError {
        error as? LocalNotificationError ?? LocalNotificationError.other(error)
    }
}

@MainActor
class LocalNotificationManager: NSObject, ObservableObject {

    let notificationCenter = UNUserNotificationCenter.current()
    private var content = UNMutableNotificationContent()

    // To check if the notification access was granted by the user
    @Published var isGranted = false
    // Pending notifications to be displayed to the user
    @Published var pendingRequests: [UNNotificationRequest] = []
    // Errors published from notification manager
    @Published var error: LocalNotificationError?

    //MARK: - init(_:)
    override init() {
        super.init()

        self.content = setNotificationContent()
    }

    //MARK: -Public methods
    /// Request notification authorization
    func requestAuthorization() async {
        do {
            try await notificationCenter
                .requestAuthorization(options: [.sound, .badge, .alert])
        } catch {
            self.error = LocalNotificationError.other(error)
        }
        await getCurrentSettings()
    }

    /// Makes sure that the user has granted access to notifications
    func getCurrentSettings() async {
        let currentSettings = await notificationCenter.notificationSettings()
        switch currentSettings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            isGranted = true
        case .notDetermined, .denied:
            isGranted = false
        @unknown default:
            break
        }
    }

    /// Opens the default device notifications settings so the user can change the access previously given to our app
    func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        if UIApplication.shared.canOpenURL(url) {
            Task {
                await UIApplication.shared.open(url)
            }
        }
    }

    /// Schedule a local notification
    func schedule(date: Date) async {
        let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        do {
            try await notificationCenter.add(request)
        } catch {
            self.error = LocalNotificationError.scheduleFail(error)
        }
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
        guard let index = pendingRequests.firstIndex(where: {$0.identifier == identifier}) else {
            return
        }
        pendingRequests.remove(at: index)
        print("Pending notifications: \(pendingRequests.count)")
    }

    /// Removes all pending local notifications
    func clearRequests(ignoreNotifications: [String] = []) {
        // Handles
        if ignoreNotifications.isEmpty {
            notificationCenter.removeAllPendingNotificationRequests()
            pendingRequests.removeAll()
        } else {
            for request in pendingRequests {
                guard !(ignoreNotifications.contains(request.identifier)) else {
                    continue
                }
                removeRequest(withIdentifier: request.identifier)
            }
        }
        print("Pending: \(pendingRequests.count)")
    }
    //MARK: - Private methods
    private func setNotificationContent() -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = Strings.notification_title
        content.body = Strings.notification_body
        content.badge = 1
        content.sound = UNNotificationSound.default
        return content
    }
}

