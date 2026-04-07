//
//  AppState.swift
// 

import Foundation
import SwiftUI

@Observable
class AppState {
    // MARK: - Authentication State
    var isAuthenticated: Bool = false
    var hasCompletedOnboarding: Bool = false
    var currentUser: User?
    
    // MARK: - College Data
    var allColleges: [College] = []
    var swipedRightColleges: Set<UUID> = []
    var swipedLeftColleges: Set<UUID> = []
    var favoriteColleges: [College] = []
    
    // MARK: - Applications
    var applications: [Application] = []
    
    // MARK: - Notifications
    var notifications: [AppNotification] = []
    
    // MARK: - Swipe Feed State
    var currentCollegeIndex: Int = 0
    
    init() {
        loadData()
    }
    
    // MARK: - Authentication Methods
    func signUp(email: String, name: String) {
        let user = User(email: email, name: name)
        self.currentUser = user
        self.isAuthenticated = true
        saveData()
    }
    
    func login(email: String) {
        // In MVP, we'll do simple login without password validation
        if let savedUser = loadUser(), savedUser.email == email {
            self.currentUser = savedUser
            self.hasCompletedOnboarding = true
        } else {
            let user = User(email: email, name: "User")
            self.currentUser = user
        }
        self.isAuthenticated = true
        loadData()
    }
    
    func logout() {
        self.isAuthenticated = false
        self.currentUser = nil
        self.hasCompletedOnboarding = false
    }
    
    func completeOnboarding(preferences: UserPreferences) {
        currentUser?.preferences = preferences
        hasCompletedOnboarding = true
        loadColleges()
        saveData()
    }
    
    // MARK: - College Methods
    func loadColleges() {
        // Load sample colleges and shuffle for personalized feel
        allColleges = SampleData.randomColleges(count: 10)
    }
    
    func swipeRight(on college: College) {
        swipedRightColleges.insert(college.id)
        if !favoriteColleges.contains(where: { $0.id == college.id }) {
            favoriteColleges.append(college)
        }
        moveToNextCollege()
        saveData()
    }
    
    func swipeLeft(on college: College) {
        swipedLeftColleges.insert(college.id)
        moveToNextCollege()
        saveData()
    }
    
    func moveToNextCollege() {
        currentCollegeIndex += 1
    }
    
    func removeFavorite(_ college: College) {
        favoriteColleges.removeAll { $0.id == college.id }
        swipedRightColleges.remove(college.id)
        saveData()
    }
    
    var availableColleges: [College] {
        allColleges.filter { college in
            !swipedRightColleges.contains(college.id) &&
            !swipedLeftColleges.contains(college.id)
        }
    }
    
    // MARK: - Application Methods
    func createApplication(for college: College) {
        // Parse deadline string to Date (simplified for MVP)
        let deadline = Calendar.current.date(byAdding: .month, value: 3, to: Date()) ?? Date()
        
        let application = Application(
            college: college,
            deadline: deadline
        )
        applications.append(application)
        
        // Add notification
        addNotification(
            title: "Application Started",
            message: "You've started an application to \(college.name)",
            type: .statusUpdate,
            relatedCollegeID: college.id
        )
        
        saveData()
    }
    
    func updateApplicationStatus(_ applicationID: UUID, status: ApplicationStatus) {
        if let index = applications.firstIndex(where: { $0.id == applicationID }) {
            applications[index].status = status
            
            if status == .submitted {
                applications[index].submittedDate = Date()
            }
            
            saveData()
        }
    }
    
    func updateApplicationNotes(_ applicationID: UUID, notes: String) {
        if let index = applications.firstIndex(where: { $0.id == applicationID }) {
            applications[index].notes = notes
            saveData()
        }
    }
    
    func deleteApplication(_ applicationID: UUID) {
        applications.removeAll { $0.id == applicationID }
        saveData()
    }
    
    // MARK: - Notification Methods
    func addNotification(title: String, message: String, type: NotificationType, relatedCollegeID: UUID? = nil) {
        let notification = AppNotification(
            title: title,
            message: message,
            type: type,
            relatedCollegeID: relatedCollegeID
        )
        notifications.insert(notification, at: 0)
        saveData()
    }
    
    func markNotificationAsRead(_ notificationID: UUID) {
        if let index = notifications.firstIndex(where: { $0.id == notificationID }) {
            notifications[index].isRead = true
            saveData()
        }
    }
    
    func deleteNotification(_ notificationID: UUID) {
        notifications.removeAll { $0.id == notificationID }
        saveData()
    }
    
    var unreadNotificationCount: Int {
        notifications.filter { !$0.isRead }.count
    }
    
    // MARK: - Persistence
    private func saveData() {
        // Save to UserDefaults for MVP
        if let user = currentUser {
            if let encoded = try? JSONEncoder().encode(user) {
                UserDefaults.standard.set(encoded, forKey: "currentUser")
            }
        }
        
        if let encoded = try? JSONEncoder().encode(favoriteColleges) {
            UserDefaults.standard.set(encoded, forKey: "favoriteColleges")
        }
        
        if let encoded = try? JSONEncoder().encode(applications) {
            UserDefaults.standard.set(encoded, forKey: "applications")
        }
        
        if let encoded = try? JSONEncoder().encode(notifications) {
            UserDefaults.standard.set(encoded, forKey: "notifications")
        }
        
        if let encoded = try? JSONEncoder().encode(Array(swipedRightColleges)) {
            UserDefaults.standard.set(encoded, forKey: "swipedRightColleges")
        }
        
        if let encoded = try? JSONEncoder().encode(Array(swipedLeftColleges)) {
            UserDefaults.standard.set(encoded, forKey: "swipedLeftColleges")
        }
        
        UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
    }
    
    private func loadData() {
        // Load from UserDefaults
        if let userData = UserDefaults.standard.data(forKey: "currentUser"),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            currentUser = user
        }
        
        if let favoritesData = UserDefaults.standard.data(forKey: "favoriteColleges"),
           let favorites = try? JSONDecoder().decode([College].self, from: favoritesData) {
            favoriteColleges = favorites
        }
        
        if let applicationsData = UserDefaults.standard.data(forKey: "applications"),
           let apps = try? JSONDecoder().decode([Application].self, from: applicationsData) {
            applications = apps
        }
        
        if let notificationsData = UserDefaults.standard.data(forKey: "notifications"),
           let notifs = try? JSONDecoder().decode([AppNotification].self, from: notificationsData) {
            notifications = notifs
        }
        
        if let swipedRightData = UserDefaults.standard.data(forKey: "swipedRightColleges"),
           let swiped = try? JSONDecoder().decode([UUID].self, from: swipedRightData) {
            swipedRightColleges = Set(swiped)
        }
        
        if let swipedLeftData = UserDefaults.standard.data(forKey: "swipedLeftColleges"),
           let swiped = try? JSONDecoder().decode([UUID].self, from: swipedLeftData) {
            swipedLeftColleges = Set(swiped)
        }
        
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        
        // Load colleges if user has completed onboarding
        if hasCompletedOnboarding && allColleges.isEmpty {
            loadColleges()
        }
    }
    
    private func loadUser() -> User? {
        if let userData = UserDefaults.standard.data(forKey: "currentUser"),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            return user
        }
        return nil
    }
}
