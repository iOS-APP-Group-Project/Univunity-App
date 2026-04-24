//
//  CollegeNotesView.swift
//  Univinity
//
//  Created by Sara Kanu on 4/24/26.
//
import SwiftUI

struct CollegeNotesView: View {
    let college: College
    @ObservedObject var notesStore: SavedNotesStore

    @Environment(\.dismiss) private var dismiss
    @State private var noteText = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("School") {
                    Text(college.name ?? "Unknown College")
                        .font(.headline)

                    Text(college.location ?? "Unknown Location")
                        .foregroundStyle(.secondary)
                }

                Section("Notes") {
                    TextEditor(text: $noteText)
                        .frame(minHeight: 160)
                }

                Button {
                    guard let id = college.objectId else { return }

                    let existing = notesStore.note(for: id)

                    notesStore.update(
                        collegeId: id,
                        note: noteText,
                        isFavorite: existing.isFavorite
                    )
                    HapticsManager.shared.notifySuccess()
                    dismiss()
                } label: {
                    Text("Save Note")
                        .frame(maxWidth: .infinity)
                        .fontWeight(.semibold)
                }
            }
            .navigationTitle("College Notes")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                guard let id = college.objectId else { return }
                let savedNote = notesStore.note(for: id)
                noteText = savedNote.note 
            }
        }
    }
}
