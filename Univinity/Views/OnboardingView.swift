//
//  OnboardingScreenView.swift
//  Univinity
//
//  Created by Sara Kanu on 4/23/26.
//
import SwiftUI
import ParseSwift

struct OnboardingView: View {
    @Binding var hasSeenOnboarding: Bool

    var body: some View {
        TabView {
            OnboardingPageView(
                image: "rectangle.stack.fill",
                title: "Discover Colleges",
                subtitle: "Swipe through college cards, search schools, and use filters to find schools that match your goals."
            )

            OnboardingPageView(
                image: "heart.fill",
                title: "Save Schools",
                subtitle: "Swipe right or tap the heart to save colleges you are interested in."
            )

            OnboardingPageView(
                image: "star.fill",
                title: "Favorite Top Picks",
                subtitle: "Tap the star on saved colleges to move your favorite schools into the Favorites tab."
            )

            OnboardingPageView(
                image: "note.text",
                title: "Add Notes",
                subtitle: "Use notes to remember why you liked a school, deadlines, or application details."
            )

            OnboardingPageView(
                image: "square.split.2x2.fill",
                title: "Compare Colleges",
                subtitle: "Select up to 3 saved colleges and compare GPA, tuition, location, type, and majors."
            )

            OnboardingPageView(
                image: "doc.text.fill",
                title: "Track Applications",
                subtitle: "Tap Apply on a college detail page to track your status: Not Started, Started, Applied, or Reviewed."
            )

            OnboardingPageView(
                image: "map.fill",
                title: "Explore the Map",
                subtitle: "View colleges on the map, tap pins for details, and open directions when you want to visit campus."
            )

            OnboardingSurveyPage(hasSeenOnboarding: $hasSeenOnboarding)
        }
        .tabViewStyle(.page)
        .background(
            LinearGradient(
                colors: [Color.purple.opacity(0.14), Color.blue.opacity(0.10)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
    }
}

struct OnboardingPageView: View {
    let image: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: image)
                .font(.system(size: 72))
                .foregroundStyle(.indigo)

            Text(title)
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)

            Text(subtitle)
                .font(.title3)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)

            Spacer()
        }
        .padding()
    }
}

struct OnboardingSurveyPage: View {
    @Binding var hasSeenOnboarding: Bool
    @StateObject private var profileViewModel = ProfileViewModel()

    var body: some View {
        VStack(spacing: 18) {
            Text("Set Up Your Preferences")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
                .padding(.top, 24)

            Text("These help Univinity personalize your match scores and recommendations.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Form {
                Section("Academic Profile") {
                    Stepper(
                        "GPA: \(profileViewModel.preferences.gpa, specifier: "%.1f")",
                        value: $profileViewModel.preferences.gpa,
                        in: 0...4,
                        step: 0.1
                    )

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Max Tuition: $\(Int(profileViewModel.preferences.maxTuition))")

                        Slider(
                            value: $profileViewModel.preferences.maxTuition,
                            in: 0...90000,
                            step: 1000
                        )
                    }
                    .padding(.vertical, 4)
                }

                Section("Preferences") {
                    Picker("School Type", selection: $profileViewModel.preferences.preferredType) {
                        Text("Any").tag("Any")
                        Text("Public").tag("Public")
                        Text("Private").tag("Private")
                    }

                    Picker("Campus Size", selection: $profileViewModel.preferences.preferredSize) {
                        Text("Any").tag("Any")
                        Text("Small").tag("Small")
                        Text("Medium").tag("Medium")
                        Text("Large").tag("Large")
                    }

                    TextField("Preferred State, e.g. NC", text: $profileViewModel.preferences.preferredState)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()

                    TextField("Preferred Major", text: $profileViewModel.preferences.preferredMajor)
                        .autocorrectionDisabled()
                }
            }
            .scrollContentBackground(.hidden)

            Button {
                profileViewModel.save()
                HapticsManager.shared.notifySuccess()

                hasSeenOnboarding = true

                if let userId = User.current?.objectId {
                    UserDefaults.standard.set(true, forKey: "hasSeenOnboarding_\(userId)")
                }
            } label: {
                Text("Save & Start")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.indigo)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal)
            .padding(.bottom, 24)
        }
    }
}
