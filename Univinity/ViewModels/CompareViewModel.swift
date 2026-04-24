//
//  CompareViewModel.swift
//  Univinity
//
//  Created by Sara Kanu on 4/22/26.
//
import Foundation
import Combine

final class CompareViewModel: ObservableObject {
    @Published var selected: [College] = []

    func toggle(_ college: College) {
        if selected.contains(where: { $0.id == college.id }) {
            selected.removeAll { $0.id == college.id }
        } else if selected.count < 3 {
            selected.append(college)
        }
    }

    func isSelected(_ college: College) -> Bool {
        selected.contains(where: { $0.id == college.id })
    }
}
