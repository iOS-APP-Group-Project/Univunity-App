//
//  College.swift
//  Univinity
//
//  Created by Sara Kanu on 4/21/26.
//
import Foundation
import ParseSwift

struct College: ParseObject, Identifiable, Hashable {

    // ✅ REQUIRED Parse fields (must exist exactly like this)
    var originalData: Data?
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseACL?

    // ✅ Your fields
    var name: String?
    var location: String?
    var acceptanceRate: String?
    var minimumGPA: String?
    var tuition: String?
    var schoolType: String?
    var size: String?
    var highlights: [String]?
    var majors: [String]?
    var website: String?
    var state: String?
    var latitude: Double?
    var longitude: Double?
    var logoUrl: ParseFile?

    // ✅ REQUIRED init
    init() {}

    // ✅ Identifiable
    var id: String {
        objectId ?? UUID().uuidString
    }
}
