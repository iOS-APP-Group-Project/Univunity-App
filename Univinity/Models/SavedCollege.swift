//
//  SavedCollege.swift
//  Univinity
//
//  Created by Sara Kanu on 4/21/26.
//
import Foundation
import ParseSwift

struct SavedCollege: ParseObject {
    static var className = "SavedColleges"

    var originalData: Data?
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseACL?

    var user: Pointer<User>?
    var college: Pointer<College>?

    init() {}
}
