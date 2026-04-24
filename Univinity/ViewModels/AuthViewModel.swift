//
//  AuthViewModel.swift
//  Univinity
//
//  Created by Sara Kanu on 4/21/26.
//
import Foundation
import Combine
import ParseSwift

final class AuthViewModel: ObservableObject {
    @Published var isLoggedIn = User.current != nil
    @Published var errorMessage = ""

    func login(username: String, password: String) {
        User.login(username: username, password: password) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.isLoggedIn = true
                    self.errorMessage = ""

                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func signUp(username: String, email: String, password: String) {
        var user = User()
        user.username = username
        user.email = email
        user.password = password

        user.signup { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    if let userId = User.current?.objectId {
                        UserDefaults.standard.set(false, forKey: "hasSeenOnboarding_\(userId)")
                    }

                    self.isLoggedIn = true
                    self.errorMessage = ""

                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func logout() {
        User.logout { _ in
            DispatchQueue.main.async {
                self.isLoggedIn = false
                self.errorMessage = ""
            }
        }
    }
}
