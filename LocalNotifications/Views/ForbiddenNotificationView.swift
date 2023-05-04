//
//  ForbiddenNotificationView.swift
//  LocalNotifications
//
//  Created by  Юлия Григорьева on 04.05.2023.
//

import SwiftUI

struct ForbiddenNotificationView: View {
    let action: () -> Void
    
    var body: some View {
        HStack {
            Text(Strings.settings_warning_text)
                .foregroundColor(.white)
            Button(action: action,
                   label: {
                Text(Strings.settings_button_text)
                    .foregroundColor(.blue)
            })
            .padding()
        }
        }
    }


struct ForbiddenNotificationView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.background
                .ignoresSafeArea()
            ForbiddenNotificationView(action: {})
        }
    }
}
