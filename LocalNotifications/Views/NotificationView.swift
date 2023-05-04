//
//  NotificationView.swift
//  LocalNotifications
//
//  Created by  Юлия Григорьева on 04.05.2023.
//

import SwiftUI

struct NotificationView: View {

    @AppStorage("TOGGlE_KEY") var toggleIsOn = false
    @AppStorage("REMINDER_TIME") private var reminderTime = Date()

    let notificationStatus: (Bool) -> Void
    let reminderDate: (Date) -> Void

    private struct Drawing {
        static let horizontalPadding: CGFloat = 10
    }

    var body: some View {
        VStack {
            Toggle(isOn: $toggleIsOn) {
                Text(Strings.settings_toggle_text)
                    .foregroundColor(.white)
            }
            .onChange(of: toggleIsOn, perform: notificationStatus)
            .tint(Color.blue)

            if toggleIsOn {

                DatePicker(selection: $reminderTime, displayedComponents: .hourAndMinute) {
                    Text(Strings.settings_date_picker_text)
                        .foregroundColor(.white)
                }
                .onChange(of: reminderTime, perform: reminderDate)
                .environment(\.colorScheme, .dark)
                .environment(\.locale, Locale(identifier: "en_GB"))
            }
        }
        .padding(.horizontal, Drawing.horizontalPadding)
    }
}

struct NotificationView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.background
                .ignoresSafeArea()
            NotificationView(notificationStatus: { _ in }, reminderDate: { _ in })
        }
    }
}
