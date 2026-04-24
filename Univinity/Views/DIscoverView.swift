//
//  DIscoverView.swift
//  Univinity
//
//  Created by Sara Kanu on 4/21/26.
//
import SwiftUI

struct DiscoverView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = DiscoverViewModel()
    @State private var showFilters = false
    @State private var showActionButtons = true

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.purple.opacity(0.14), Color.blue.opacity(0.10)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 18) {
                // HEADER
                // HEADER + SEARCH
                VStack(spacing: 14) {
                    HStack {
                        Text("Discover")
                            .font(.system(size: 34, weight: .bold))

                        Spacer()

                        Button("Logout") {
                            authViewModel.logout()
                        }
                        .font(.subheadline.weight(.semibold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.9))
                        .clipShape(Capsule())
                    }
                    .padding(.horizontal)

                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)

                        TextField("Search colleges, states, or majors", text: $viewModel.searchText)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .onChange(of: viewModel.searchText) { _ in
                                viewModel.applyFilters()
                            }
                    }
                    .padding(12)
                    .background(Color.white.opacity(0.9))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal)
                }
                .padding(.top, 110)

                // EVERYTHING BELOW HEADER
                VStack(spacing: 18) {
                    // FILTER ROW
                    HStack {
                        Button {
                            HapticsManager.shared.light()
                            showFilters = true
                        } label: {
                            Label("Filters", systemImage: "line.3.horizontal.decrease.circle")
                                .font(.subheadline.weight(.semibold))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(Color.white.opacity(0.9))
                                .foregroundStyle(.indigo)
                                .clipShape(Capsule())
                        }

                        Spacer()

                        Text("\(viewModel.colleges.count) left")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)

                    // CARD STACK
                    ZStack {
                        if viewModel.colleges.indices.contains(2) {
                            SwipeCardBackgroundView()
                                .scaleEffect(0.93)
                                .offset(y: 18)
                        }

                        if viewModel.colleges.indices.contains(1) {
                            SwipeCardBackgroundView()
                                .scaleEffect(0.97)
                                .offset(y: 8)
                        }

                        if let topCollege = viewModel.colleges.first {
                            SwipeCardView(
                                college: topCollege,
                                matchScore: viewModel.matchScore(
                                    for: topCollege,
                                    preferredSize: viewModel.selectedSize
                                ),
                                onSwipeLeft: {
                                    viewModel.removeTopCollege()
                                },
                                onSwipeRight: {
                                    viewModel.saveTopCollege()
                                }
                            )
                        } else {
                            ContentUnavailableView(
                                "No More Colleges",
                                systemImage: "graduationcap.fill",
                                description: Text("Adjust your filters or add more schools in Parse.")
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 6)

                Spacer(minLength: 0)
            }
            .padding(.top, 12)

            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 10) {

                    if viewModel.showActionButtons {
                        HStack(spacing: 26) {
                            actionButton(
                                systemImage: "arrow.uturn.backward",
                                background: Color.white,
                                foreground: .indigo
                            ) {
                                HapticsManager.shared.light()
                                viewModel.undoLast()
                            }

                            actionButton(
                                systemImage: "xmark",
                                background: Color.red.opacity(0.12),
                                foreground: .red
                            ) {
                                HapticsManager.shared.light()
                                viewModel.removeTopCollege()
                            }

                            actionButton(
                                systemImage: "heart.fill",
                                background: Color.green.opacity(0.14),
                                foreground: .green
                            ) {
                                HapticsManager.shared.medium()
                                viewModel.saveTopCollege()
                            }
                        }
                        .padding(.bottom, 30)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    Color.clear
                        .frame(height: 70)
                }
            }
        }
        .onAppear {
            viewModel.fetchColleges()
        }
        .sheet(isPresented: $showFilters) {
            DiscoverFilterSheet(viewModel: viewModel)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .alert("Error", isPresented: .constant(!viewModel.errorMessage.isEmpty)) {
            Button("OK") {
                viewModel.errorMessage = ""
            }
        } message: {
            Text(viewModel.errorMessage)
        }
    }

    private func actionButton(
        systemImage: String,
        background: Color,
        foreground: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(foreground)
                .frame(width: 62, height: 62)
                .background(background)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        }
    }
}

private struct SwipeCardBackgroundView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 28)
            .fill(Color.white.opacity(0.72))
            .frame(height: 500)
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}
