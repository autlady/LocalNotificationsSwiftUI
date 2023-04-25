//
//  Text.swift
//  LocalNotifications
//
//  Created by  Юлия Григорьева on 24.04.2023.
//

import SwiftUI

extension Text {
    func titleStyle(size: CGFloat = 30) -> some View {
        self.font(Font.custom("Geneva-Bold", size: size))
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
    }
}
