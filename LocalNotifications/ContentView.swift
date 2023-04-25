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


    @AppStorage("TOGGlE_KEY") var toggleIsOn = false
    @AppStorage("REMINDER_TIME") var reminderTime = Date()

    var body: some View {
        ZStack {
            Color.background
                .ignoresSafeArea()
            VStack() {
                Text(Strings.settings_title)
                    .titleStyle()
                notificationItems(isGranted: localNotificationManager.isGranted)
                Spacer()
            }
        }
            .onChange(of: scenePhase) { newPhase in // watch changes in user settings
                switch newPhase {
                case .active:
                    print("App became active")
                    Task {
                        await localNotificationManager.getCurrentSettings()
                        await localNotificationManager.getPendingRequests()
                    }
                    UIApplication.shared.applicationIconBadgeNumber = 0 // set to 0 (number of notifications on icon)
                case .inactive:
                    print("App became inactive")
                case .background:
                    print("App is running in the background")
                @unknown default:
                    print("Fallback for future cases")
                }
            }
            .onAppear() {

                Task {
                    try await localNotificationManager.requestAuthorization()
                }
            }
    }

        @ViewBuilder
        func notificationItems(isGranted: Bool) -> some View {
                if !isGranted {
                    HStack {
                        Text(Strings.settings_warning_text)
                            .foregroundColor(.white)
                        Button(action: {
                            localNotificationManager.openSettings()
                        }, label: {
                            Text(Strings.settings_button_text)
                                .foregroundColor(.blue)
                        })
                        .padding()
                    }
                } else {
                    Toggle(isOn: $toggleIsOn) {
                        Text(Strings.settings_toggle_text)
                            .foregroundColor(.white)
                    }
                    .onChange(of: toggleIsOn, perform: { value in
                        if value {
                            print("On")
                        } else {
                            localNotificationManager.clearRequests()
                            print("Off")
                    }
                    })
                    .tint(Color.blue)
                    .padding(.horizontal, 10)

                    if toggleIsOn {
                        DatePicker(selection: $reminderTime, displayedComponents: .hourAndMinute) {
                            Text(Strings.settings_date_picker_text)

                                .foregroundColor(.white)
                        }

                        .onChange(of: reminderTime, perform: { value in
                            localNotificationManager.clearRequests()
                            Task { await localNotificationManager.schedule(date: reminderTime) }
                        })
                        .padding(.horizontal, 10)
                        .environment(\.colorScheme, .dark)
                        .environment(\.locale, Locale(identifier: "en_GB")) // get rid of pm /am format
                    }
        }

    }

}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
