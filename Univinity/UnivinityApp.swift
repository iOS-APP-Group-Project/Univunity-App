//
//  UnivinityApp.swift
//  Univinity
//
//  Created by Sara Kanu on 4/21/26.
//
import SwiftUI
import ParseSwift

@main
struct UnivinityApp: App {
    init() {
        ParseSwift.initialize(
            applicationId: "jCvYgqwoSp6fjLmdtsU4INjzeopCtyRXE8Wp2FBV",
            clientKey: "j32MsS7iZfM27nPcdZuOzyvhJuJLDe1UAeFWLsPn",
            serverURL: URL(string: "https://parseapi.back4app.com")!
        )

        NotificationManager.shared.requestPermission()
        NotificationManager.shared.scheduleReminder()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
