//
//  ApplicationStatus.swift
//  Univinity
//
//  Created by Sara Kanu on 4/24/26.
//
import Foundation

enum ApplicationStatus: String, Codable, CaseIterable, Identifiable {
    case notStarted = "Not Started"
    case started = "Started"
    case applied = "Applied"
    case reviewed = "Reviewed"

    var id: String { rawValue }
}
