//
//  UserPreferences.swift
//  Univinity
//
//  Created by Sara Kanu on 4/22/26.
//
import Foundation

struct UserPreferences: Codable {
    var gpa: Double = 3.5
    var maxTuition: Double = 50000
    var preferredType: String = "Any"
    var preferredSize: String = "Any"
    var preferredState: String = ""
    var preferredMajor: String = ""
}
