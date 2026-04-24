//
//  SavedView.swift
//  Univinity
//
//  Created by Sara Kanu on 4/21/26.
//
import SwiftUI
import ParseSwift

struct SavedView: View {
    @StateObject private var viewModel = SavedViewModel()
    @StateObject private var notesStore = SavedNotesStore()
    @StateObject private var compareViewModel = CompareViewModel()

    @State private var selectedNoteCollege: College?

    var body: some View {
        Group {
            if viewModel.savedColleges.isEmpty {
                ContentUnavailableView(
                    "No Saved Colleges",
                    systemImage: "heart.slash",
                    description: Text("Swipe right on colleges you like to save them here.")
                )
            } else {
                VStack(spacing: 12) {
                    Picker("Sort", selection: $viewModel.sortOption) {
                        Text("Name").tag("Name")
                        Text("Tuition").tag("Tuition")
                        Text("GPA").tag("GPA")
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .onChange(of: viewModel.sortOption) { _ in
                        viewModel.sortSavedColleges()
                    }

                    HStack {
                        Text("Tap the circle to select up to 3 colleges to compare")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Spacer()
                    }
                    .padding(.horizontal)

                    NavigationLink {
                        CompareCollegesView(colleges: compareViewModel.selected)
                    } label: {
                        HStack {
                            Image(systemName: "square.split.2x2")
                            Text("Compare Selected (\(compareViewModel.selected.count))")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(compareViewModel.selected.isEmpty ? Color.gray.opacity(0.15) : Color.indigo.opacity(0.15))
                        .foregroundStyle(compareViewModel.selected.isEmpty ? Color.gray : Color.indigo)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .disabled(compareViewModel.selected.count < 2)
                    .padding(.horizontal)

                    List(viewModel.savedColleges, id: \.id) { college in
                        NavigationLink(destination: CollegeDetailView(college: college)) {
                            HStack(alignment: .top, spacing: 12) {
                                collegeLogo(college)

                                VStack(alignment: .leading, spacing: 4) {
                                    HStack(alignment: .top) {
                                        Text(college.name ?? "Unknown School")
                                            .font(.headline)

                                        Spacer()

                                        Button {
                                            guard let id = college.objectId else { return }

                                            let existing = notesStore.note(for: id)

                                            notesStore.update(
                                                collegeId: id,
                                                note: existing.note,
                                                isFavorite: !existing.isFavorite
                                            )

                                            HapticsManager.shared.light()
                                        } label: {
                                            Image(systemName: notesStore.note(for: college.objectId ?? "").isFavorite ? "star.fill" : "star")
                                                .foregroundStyle(
                                                    notesStore.note(for: college.objectId ?? "").isFavorite ? .yellow : .gray
                                                )
                                        }
                                        .buttonStyle(.plain)
                                    }

                                    Text(college.location ?? "Unknown Location")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)

                                    Text("Minimum GPA: \(college.minimumGPA ?? "N/A")")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)

                                    let savedNote = notesStore.note(for: college.objectId ?? "")

                                    if !savedNote.note.isEmpty {
                                        Text(savedNote.note)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                            .lineLimit(2)
                                    }
                                }

                                VStack(spacing: 12) {
                                    Button {
                                        compareViewModel.toggle(college)
                                    } label: {
                                        Image(systemName: compareViewModel.isSelected(college) ? "checkmark.circle.fill" : "circle")
                                            .font(.title3)
                                            .foregroundStyle(compareViewModel.isSelected(college) ? .indigo : .gray)
                                    }
                                    .buttonStyle(.plain)

                                    Button {
                                        selectedNoteCollege = college
                                    } label: {
                                        Image(systemName: "note.text")
                                            .font(.title3)
                                            .foregroundStyle(.indigo)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.vertical, 4)
                            .contentShape(Rectangle())
                            .background(
                                compareViewModel.isSelected(college)
                                ? Color.indigo.opacity(0.08)
                                : Color.clear
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                ParseManager.shared.deleteSavedCollege(college) { _ in
                                    compareViewModel.selected.removeAll { $0.id == college.id }
                                    notesStore.remove(collegeId: college.objectId ?? "")
                                    viewModel.fetchSavedColleges()
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
        }
        .navigationTitle("Saved")
        .onAppear {
            if viewModel.savedColleges.isEmpty {
                viewModel.fetchSavedColleges()
            }
        }
        .sheet(item: $selectedNoteCollege) { college in
            CollegeNotesView(college: college, notesStore: notesStore)
        }
    }

    @ViewBuilder
    private func collegeLogo(_ college: College) -> some View {
        Group {
            if let file = college.logoUrl,
               let url = file.url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
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
