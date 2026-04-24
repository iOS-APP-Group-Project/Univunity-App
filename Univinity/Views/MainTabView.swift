//
//  MainTabView.swift
//  Univinity
//
//  Created by Sara Kanu on 4/21/26.
//
import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        TabView {
            NavigationStack {
                DiscoverView()
            }
            .tabItem {
                Label("Discover", systemImage: "rectangle.stack.fill")
            }

            NavigationStack {
                SavedView()
            }
            .tabItem {
                Label("Saved", systemImage: "heart.fill")
            }

            NavigationStack {
                FavoritesView()
            }
            .tabItem {
                Label("Favorites", systemImage: "star.fill")
            }

            NavigationStack {
                ApplicationsView()
            }
            .tabItem {
                Label("Apply", systemImage: "doc.text.fill")
            }

            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Label("Profile", systemImage: "person.fill")
            }
        }
        .tint(.indigo)
    }
}
