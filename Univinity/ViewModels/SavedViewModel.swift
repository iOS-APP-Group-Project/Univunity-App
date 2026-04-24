//
//  SavedViewModel.swift
//  Univinity
//
//  Created by Sara Kanu on 4/21/26.
//
import Foundation
import Combine

final class SavedViewModel: ObservableObject {
    @Published var savedColleges: [College] = []
    @Published var errorMessage = ""
    @Published var sortOption: String = "Name"

    func fetchSavedColleges() {
        ParseManager.shared.fetchSavedColleges { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let colleges):
                    self.savedColleges = colleges
                    self.sortSavedColleges()
                    self.errorMessage = ""

                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func sortSavedColleges() {
        switch sortOption {
        case "Tuition":
            savedColleges.sort {
                DiscoverViewModel.numericValue(from: $0.tuition) ?? 0 <
                DiscoverViewModel.numericValue(from: $1.tuition) ?? 0
            }
        case "GPA":
            savedColleges.sort {
                DiscoverViewModel.numericValue(from: $0.minimumGPA) ?? 0 >
                DiscoverViewModel.numericValue(from: $1.minimumGPA) ?? 0
            }
        default:
            savedColleges.sort { ($0.name ?? "") < ($1.name ?? "") }
        }
    }
}
