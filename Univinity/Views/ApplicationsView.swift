//
//  ApplicationsView.swift
//  Univinity
//
//  Created by Sara Kanu on 4/24/26.
//
import SwiftUI
import ParseSwift

struct ApplicationsView: View {
    @StateObject private var savedViewModel = SavedViewModel()
    @StateObject private var applicationStore = ApplicationStore()

    private var applicationColleges: [College] {
        savedViewModel.savedColleges.filter { college in
            guard let id = college.objectId else { return false }
            return applicationStore.status(for: id) != nil
        }
    }

    var body: some View {
        Group {
            if applicationColleges.isEmpty {
                ContentUnavailableView(
                    "No Applications Yet",
                    systemImage: "doc.text.magnifyingglass",
                    description: Text("Tap Apply on a saved college detail page to track it here.")
                )
            } else {
                List(applicationColleges, id: \.id) { college in
                    HStack(spacing: 12) {
                        collegeLogo(college)

                        VStack(alignment: .leading, spacing: 5) {
                            Text(college.name ?? "Unknown School")
                                .font(.headline)

                            Text(college.location ?? "Unknown Location")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Picker("Status", selection: Binding(
                                get: {
                                    applicationStore.status(for: college.objectId ?? "") ?? .notStarted
                                },
                                set: { newStatus in
                                    applicationStore.updateStatus(for: college, status: newStatus)
                                    HapticsManager.shared.light()
                                }
                            )) {
                                ForEach(ApplicationStatus.allCases) { status in
                                    Text(status.rawValue).tag(status)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(.indigo)
                        }

                        Spacer()
                    }
                    .padding(.vertical, 6)
                    .swipeActions {
                        Button(role: .destructive) {
                            applicationStore.removeCollege(college)
                        } label: {
                            Label("Remove", systemImage: "trash")
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Applications")
        .onAppear {
            applicationStore.reload()

            if savedViewModel.savedColleges.isEmpty {
                savedViewModel.fetchSavedColleges()
            }
        }
    }

    @ViewBuilder
    private func collegeLogo(_ college: College) -> some View {
        Group {
            if let url = college.logoUrl?.url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFit()
                    case .failure:
                        placeholderImage
                    case .empty:
                        ProgressView()
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                placeholderImage
            }
        }
        .frame(width: 56, height: 56)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var placeholderImage: some View {
        Image(systemName: "building.columns.fill")
            .resizable()
            .scaledToFit()
            .foregroundStyle(.gray)
            .padding(8)
    }
}
