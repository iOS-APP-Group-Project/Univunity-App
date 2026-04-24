//
//  ApplicationStore.swift
//  Univinity
//
//  Created by Sara Kanu on 4/24/26.
//
import Foundation
import Combine

final class ApplicationStore: ObservableObject {
    @Published private(set) var applications: [String: ApplicationStatus] = [:]

    private let key = "college_applications"

    init() {
        reload()
    }

    func status(for collegeId: String) -> ApplicationStatus? {
        applications[collegeId]
    }

    func addCollege(_ college: College, status: ApplicationStatus = .started) {
        guard let id = college.objectId else { return }
        applications[id] = status
        save()
    }

    func updateStatus(for college: College, status: ApplicationStatus) {
        guard let id = college.objectId else { return }
        applications[id] = status
        save()
    }

    func removeCollege(_ college: College) {
        guard let id = college.objectId else { return }
        applications.removeValue(forKey: id)
        save()
    }

    func reload() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let saved = try? JSONDecoder().decode([String: ApplicationStatus].self, from: data) else {
            applications = [:]
            return
        }

        applications = saved
    }

    private func save() {
        if let data = try? JSONEncoder().encode(applications) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
