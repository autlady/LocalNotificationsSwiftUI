//
//  LocalNotificationsApp.swift
//  LocalNotifications
//
//  Created by  Юлия Григорьева on 24.04.2023.
//

import SwiftUI

@main
struct LocalNotificationsApp: App {
    
    @StateObject var localNotificationManager = LocalNotificationManager()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(localNotificationManager)
        }
    }
}
