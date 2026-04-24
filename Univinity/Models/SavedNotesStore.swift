//
//  SavedNotesStore.swift
//  Univinity
//
//  Created by Sara Kanu on 4/22/26.
//
import Foundation
import Combine

final class SavedNotesStore: ObservableObject {
    @Published private(set) var notes: [String: SavedCollegeNote] = [:]

    private let key = "saved_college_notes"

    init() {
        reload()
    }

    func note(for collegeId: String) -> SavedCollegeNote {
        notes[collegeId] ?? SavedCollegeNote(note: "", isFavorite: false)
    }

    func update(collegeId: String, note: String, isFavorite: Bool) {
        notes[collegeId] = SavedCollegeNote(note: note, isFavorite: isFavorite)
        save()
    }

    func remove(collegeId: String) {
        notes.removeValue(forKey: collegeId)
        save()
    }

    func reload() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let saved = try? JSONDecoder().decode([String: SavedCollegeNote].self, from: data) else {
            notes = [:]
            return
        }

        notes = saved
    }

    private func save() {
        if let data = try? JSONEncoder().encode(notes) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
