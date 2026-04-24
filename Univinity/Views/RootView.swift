//
//  RootView.swift
//  Univinity
//
//  Created by Sara Kanu on 4/21/26.
//
import SwiftUI
import ParseSwift

struct RootView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @State private var hasSeenOnboarding = false

    var body: some View {
        Group {
            if authViewModel.isLoggedIn {
                if !hasSeenOnboarding {
                    OnboardingView(hasSeenOnboarding: $hasSeenOnboarding)
                } else {
                    MainTabView()
                        .environmentObject(authViewModel)
                }
            } else {
                LoginView()
                    .environmentObject(authViewModel)
            }
        }
        .onAppear {
            refreshOnboardingState()
        }
        .onChange(of: authViewModel.isLoggedIn) { _ in
            refreshOnboardingState()
        }
    }

    private func refreshOnboardingState() {
        guard let userId = User.current?.objectId else {
            hasSeenOnboarding = false
            return
        }

        hasSeenOnboarding = UserDefaults.standard.bool(
            forKey: "hasSeenOnboarding_\(userId)"
        )
    }
}
