//
//  ProfileView.swift
//  Univinity
//
//  Created by Sara Kanu on 4/22/26.
//
import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color.purple.opacity(0.12), Color.blue.opacity(0.10)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                Form {
                    Section("Academic Profile") {
                        Stepper(
                            "GPA: \(viewModel.preferences.gpa, specifier: "%.1f")",
                            value: $viewModel.preferences.gpa,
                            in: 0...4,
                            step: 0.1
                        )

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Max Tuition: $\(Int(viewModel.preferences.maxTuition))")
                            Slider(
                                value: $viewModel.preferences.maxTuition,
                                in: 0...90000,
                                step: 1000
                            )
                        }
                        .padding(.vertical, 4)
                    }

                    Section("Preferences") {
                        Picker("Preferred Type", selection: $viewModel.preferences.preferredType) {
                            Text("Any").tag("Any")
                            Text("Public").tag("Public")
                            Text("Private").tag("Private")
                        }

                        Picker("Preferred Size", selection: $viewModel.preferences.preferredSize) {
                            Text("Any").tag("Any")
                            Text("Small").tag("Small")
                            Text("Medium").tag("Medium")
                            Text("Large").tag("Large")
                        }

                        TextField("Preferred State (optional)", text: $viewModel.preferences.preferredState)
                            .textInputAutocapitalization(.characters)
                            .autocorrectionDisabled()

                        TextField("Preferred Major (optional)", text: $viewModel.preferences.preferredMajor)
                            .autocorrectionDisabled()
                    }

                    Section {
                        Button {
                            viewModel.save()
                            HapticsManager.shared.notifySuccess()
                        } label: {
                            Text("Save Preferences")
                                .frame(maxWidth: .infinity, alignment: .center)
                                .fontWeight(.semibold)
                        }
                    }

                    Section("How this affects Discover") {
                        Text("Your GPA and budget improve match scores. Type and size can help personalize recommendations. State and major are saved for future features, but they won’t hide all colleges.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Profile")
        }
    }
}
