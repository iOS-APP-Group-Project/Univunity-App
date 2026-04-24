//
//  DiscoverViewModel.swift
//  Univinity
//
//  Created by Sara Kanu on 4/21/26.
//
import Foundation
import Combine
import ParseSwift

final class DiscoverViewModel: ObservableObject {
    @Published var allColleges: [College] = []
    @Published var colleges: [College] = []
    @Published var errorMessage = ""
    @Published var sessionExpired = false
    @Published var searchText = ""

    @Published var selectedType = "Any"
    @Published var selectedSize = "Any"
    @Published var maxTuition: Double = 80000
    @Published var userGPA: Double = 3.5
    @Published var showActionButtons = true

    private var removedStack: [College] = []

    func fetchColleges() {
        ParseManager.shared.fetchColleges { result in
            switch result {
            case .success(let colleges):
                DispatchQueue.main.async {
                    print("✅ fetched colleges:", colleges.count)
                    self.allColleges = colleges.shuffled()
                    self.applyFilters()
                }

            case .failure(let error):
                DispatchQueue.main.async {
                    print("❌ fetch error:", error.localizedDescription)
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func applyFilters() {
        let profileVM = ProfileViewModel()
        let preferredState = profileVM.preferences.preferredState.trimmingCharacters(in: .whitespacesAndNewlines)

        let filtered = allColleges.filter { college in
            let searchPool = [
                college.name ?? "",
                college.location ?? "",
                college.state ?? "",
                (college.majors ?? []).joined(separator: ", ")
            ].joined(separator: " ")

            let matchesSearch =
                searchText.isEmpty ||
                searchPool.localizedCaseInsensitiveContains(searchText)

            let matchesType =
                selectedType == "Any" || college.schoolType == selectedType

            let matchesSize =
                selectedSize == "Any" || college.size == selectedSize

            let tuitionValue = Self.numericValue(from: college.tuition)
            let matchesTuition =
                tuitionValue == nil || tuitionValue! <= maxTuition

            return matchesSearch && matchesType && matchesSize && matchesTuition
        }

        if preferredState.isEmpty {
            colleges = filtered
        } else {
            colleges = filtered.sorted { first, second in
                let firstMatches =
                    (first.state?.localizedCaseInsensitiveContains(preferredState) ?? false) ||
                    (first.location?.localizedCaseInsensitiveContains(preferredState) ?? false)

                let secondMatches =
                    (second.state?.localizedCaseInsensitiveContains(preferredState) ?? false) ||
                    (second.location?.localizedCaseInsensitiveContains(preferredState) ?? false)

                if firstMatches != secondMatches {
                    return firstMatches
                }

                return (first.name ?? "") < (second.name ?? "")
            }
        }
    }
    func removeTopCollege() {
        guard let first = colleges.first else { return }
        removedStack.append(first)
        colleges.removeFirst()
    }

    func undoLast() {
        guard let last = removedStack.popLast() else { return }
        colleges.insert(last, at: 0)
    }

    func saveTopCollege() {
        guard let college = colleges.first else { return }

        ParseManager.shared.saveCollegeIfNeeded(college) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.removeTopCollege()
                case .failure(let error):
                    if let parseError = error as? ParseError,
                       parseError.code == .invalidSessionToken {
                        self.sessionExpired = true
                        self.errorMessage = "Your session expired. Please log in again."
                    } else {
                        self.errorMessage = error.localizedDescription
                    }
                }
            }
        }
    }

    func matchScore(for college: College, preferredSize: String = "Any") -> Int {
        var score = 0

        if let minGPA = Self.numericValue(from: college.minimumGPA),
           userGPA >= minGPA {
            score += 40
        }

        if let tuition = Self.numericValue(from: college.tuition),
           tuition <= maxTuition {
            score += 30
        }

        if preferredSize == "Any" || college.size == preferredSize {
            score += 15
        }

        if selectedType == "Any" || college.schoolType == selectedType {
            score += 15
        }

        return min(score, 100)
    }

    static func numericValue(from string: String?) -> Double? {
        guard let string else { return nil }

        let cleaned = string.replacingOccurrences(
            of: "[^0-9.]",
            with: "",
            options: .regularExpression
        )

        return Double(cleaned)
    }
}
