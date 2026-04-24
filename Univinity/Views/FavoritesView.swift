//
//  FavoritesView.swift
//  Univinity
//
//  Created by Sara Kanu on 4/24/26.
//
import SwiftUI
import ParseSwift

struct FavoritesView: View {
    @StateObject private var viewModel = SavedViewModel()
    @StateObject private var notesStore = SavedNotesStore()

    private var favoriteColleges: [College] {
        viewModel.savedColleges.filter { college in
            guard let id = college.objectId else { return false }
            return notesStore.note(for: id).isFavorite
        }
    }

    var body: some View {
        Group {
            if favoriteColleges.isEmpty {
                ContentUnavailableView(
                    "No Favorites Yet",
                    systemImage: "star.slash",
                    description: Text("Tap the notes icon on a saved college and turn on Favorite.")
                )
            } else {
                List(favoriteColleges, id: \.id) { college in
                    NavigationLink(destination: CollegeDetailView(college: college)) {
                        HStack(spacing: 12) {
                            collegeLogo(college)

                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(college.name ?? "Unknown School")
                                        .font(.headline)

                                    Image(systemName: "star.fill")
                                        .foregroundStyle(.yellow)
                                }

                                Text(college.location ?? "Unknown Location")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)

                                if let id = college.objectId {
                                    let savedNote = notesStore.note(for: id)

                                    if !savedNote.note.isEmpty {
                                        Text(savedNote.note)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                            .lineLimit(2)
                                    }
                                }

                                Button {
                                    removeFavorite(college)
                                } label: {
                                    Label("Remove Favorite", systemImage: "star.slash")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(.orange)
                                }
                                .buttonStyle(.plain)
                                .padding(.top, 2)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .swipeActions(edge: .trailing) {
                        Button {
                            removeFavorite(college)
                        } label: {
                            Label("Remove", systemImage: "star.slash")
                        }
                        .tint(.orange)
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Favorites")
        .onAppear {
            notesStore.reload()

            if viewModel.savedColleges.isEmpty {
                viewModel.fetchSavedColleges()
            }
        }
    }

    private func removeFavorite(_ college: College) {
        guard let id = college.objectId else { return }

        let existing = notesStore.note(for: id)

        notesStore.update(
            collegeId: id,
            note: existing.note,
            isFavorite: false
        )

        HapticsManager.shared.light()
    }

    @ViewBuilder
    private func collegeLogo(_ college: College) -> some View {
        Group {
            if let url = college.logoUrl?.url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFit()
                    case .failure(_):
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
