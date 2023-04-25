//
//  Date.swift
//  LocalNotifications
//
//  Created by  Юлия Григорьева on 24.04.2023.
//

import SwiftUI

// For correct saving Data using @AppStorage

extension Date: RawRepresentable {
    public var rawValue: String {
        self.timeIntervalSinceReferenceDate.description
    }
    public init?(rawValue: String) {
        self = Date(timeIntervalSinceReferenceDate: Double(rawValue) ?? 0.0)
    }
}
