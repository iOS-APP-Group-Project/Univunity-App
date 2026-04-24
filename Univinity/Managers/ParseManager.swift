//
//  ParseManager.swift
//  Univinity
//
//  Created by Sara Kanu on 4/21/26.
//
import Foundation
import ParseSwift

final class ParseManager {
    static let shared = ParseManager()
    private init() {}

    func fetchColleges(completion: @escaping (Result<[College], Error>) -> Void) {
        College.query().find { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let colleges):
                    print("✅ fetched colleges:", colleges.count)
                    completion(.success(colleges))
                case .failure(let error):
                    print("❌ fetch colleges error:", error.localizedDescription)
                    completion(.failure(error))
                }
            }
        }
    }

    func saveCollegeIfNeeded(_ college: College,
                             completion: @escaping (Result<Void, Error>) -> Void) {
        guard let currentUser = User.current else {
            DispatchQueue.main.async {
                completion(.failure(NSError(
                    domain: "ParseManager",
                    code: 401,
                    userInfo: [NSLocalizedDescriptionKey: "No logged in user."]
                )))
            }
            return
        }

        do {
            let userPointer = try currentUser.toPointer()
            let collegePointer = try college.toPointer()

            SavedCollege.query().find { result in
                switch result {
                case .success(let savedItems):
                    let alreadySaved = savedItems.contains {
                        $0.user?.objectId == userPointer.objectId &&
                        $0.college?.objectId == collegePointer.objectId
                    }

                    if alreadySaved {
                        DispatchQueue.main.async {
                            completion(.success(()))
                        }
                        return
                    }

                    var savedCollege = SavedCollege()
                    savedCollege.user = userPointer
                    savedCollege.college = collegePointer

                    savedCollege.save { saveResult in
                        DispatchQueue.main.async {
                            switch saveResult {
                            case .success:
                                completion(.success(()))
                            case .failure(let error):
                                completion(.failure(error))
                            }
                        }
                    }

                case .failure(let error):
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            }
        } catch {
            DispatchQueue.main.async {
                completion(.failure(error))
            }
        }
    }

    func fetchSavedColleges(completion: @escaping (Result<[College], Error>) -> Void) {
        guard let currentUser = User.current else {
            DispatchQueue.main.async {
                completion(.success([]))
            }
            return
        }

        SavedCollege.query().find { result in
            switch result {
            case .success(let savedItems):
                let currentUserSavedItems = savedItems
                    .filter { $0.user?.objectId == currentUser.objectId }
                    .sorted {
                        ($0.createdAt ?? Date.distantPast) < ($1.createdAt ?? Date.distantPast)
                    }

                if currentUserSavedItems.isEmpty {
                    DispatchQueue.main.async {
                        completion(.success([]))
                    }
                    return
                }

                let group = DispatchGroup()
                let lockQueue = DispatchQueue(label: "saved.colleges.lock")

                var fetchedCollegesById: [String: College] = [:]
                var firstError: Error?

                for savedItem in currentUserSavedItems {
                    guard let collegePointer = savedItem.college else {
                        continue
                    }

                    let collegeId = collegePointer.objectId

                    group.enter()

                    collegePointer.fetch { fetchResult in
                        lockQueue.async {
                            switch fetchResult {
                            case .success(let college):
                                fetchedCollegesById[collegeId] = college

                            case .failure(let error):
                                if firstError == nil {
                                    firstError = error
                                }
                            }

                            group.leave()
                        }
                    }
                }

                group.notify(queue: .main) {
                    if let error = firstError, fetchedCollegesById.isEmpty {
                        completion(.failure(error))
                    } else {
                        let orderedColleges = currentUserSavedItems.compactMap { savedItem -> College? in
                            guard let collegePointer = savedItem.college else { return nil }
                            return fetchedCollegesById[collegePointer.objectId]
                        }

                        completion(.success(orderedColleges))
                    }
                }

            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func deleteSavedCollege(_ college: College,
                            completion: @escaping (Result<Void, Error>) -> Void) {
        guard let currentUser = User.current,
              let collegeId = college.objectId else {
            DispatchQueue.main.async {
                completion(.success(()))
            }
            return
        }

        SavedCollege.query().find { result in
            switch result {
            case .success(let savedItems):
                guard let match = savedItems.first(where: {
                    $0.user?.objectId == currentUser.objectId &&
                    $0.college?.objectId == collegeId
                }) else {
                    DispatchQueue.main.async {
                        completion(.success(()))
                    }
                    return
                }

                match.delete { deleteResult in
                    DispatchQueue.main.async {
                        switch deleteResult {
                        case .success:
                            completion(.success(()))
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                }

            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
}
