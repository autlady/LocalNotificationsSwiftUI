//
//  ContentView.swift
//  LocalNotifications
//
//  Created by  Юлия Григорьева on 24.04.2023.
//

import SwiftUI

struct ContentView: View {

    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject var localNotificationManager: LocalNotificationManager
    @State private var isError: Bool = false

    var body: some View {
        ZStack {
            Color.background
                .ignoresSafeArea()
            VStack() {
                Text(Strings.settings_title)
                    .titleStyle()
                if localNotificationManager.isGranted {
                    NotificationView(
                        notificationStatus: setStatus(_:),
                        reminderDate: schedule(date:))
                } else {
                    ForbiddenNotificationView(
                        action: localNotificationManager.openSettings)
                }
                Spacer()
            }
        }
        .onAppear() {
                UIApplication.shared.applicationIconBadgeNumber = 0
            }
        .onChange(of: scenePhase, perform: manage(phase:))
        .task(localNotificationManager.requestAuthorization)
        .alert(
            isPresented: $isError,
            error: localNotificationManager.error,
            actions: { Text("Ok")} )
    }

    private func manage(phase: ScenePhase) {
        switch phase {
        case .active:
            print("App became active")
            Task {
                await localNotificationManager.getCurrentSettings()
                await localNotificationManager.getPendingRequests()
            }

        case .inactive:
            print("App became inactive")
        case .background:
            print("App is running in the background")
        @unknown default:
            print("Fallback for future cases")
        }
    }

    private func schedule(date: Date) {
        localNotificationManager.clearRequests()
        Task { await localNotificationManager.schedule(date: date) }
    }

    private func setStatus(_ isOn: Bool) {
        if isOn {
            print("On")
        } else {
            localNotificationManager.clearRequests()
            print("Off")
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(LocalNotificationManager())
    }
}
