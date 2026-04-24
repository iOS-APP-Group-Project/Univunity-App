//
//  User.swift
//  Univinity
//
//  Created by Sara Kanu on 4/21/26.
//
import Foundation
import ParseSwift

struct User: ParseUser {
    // Required ParseUser / ParseObject fields
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseACL?
    var originalData: Data?
    var sessionToken: String?

    // Standard _User fields
    var username: String?
    var email: String?
    var emailVerified: Bool?
    var password: String?
    var authData: [String: [String: String]?]?

    // Optional custom fields for your app
    var customUserData: [String: String]?

    init() {}
}
