//
//  ProfileViewModel.swift
//  Univinity
//
//  Created by Sara Kanu on 4/22/26.
//
import Foundation
import Combine

final class ProfileViewModel: ObservableObject {
    @Published var preferences = UserPreferences()

    private let key = "univinity_user_preferences"

    init() {
        load()
    }

    func save() {
        if let data = try? JSONEncoder().encode(preferences) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let prefs = try? JSONDecoder().decode(UserPreferences.self, from: data) else {
            return
        }
        preferences = prefs
    }
}
