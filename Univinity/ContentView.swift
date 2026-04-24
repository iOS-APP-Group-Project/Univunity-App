//
//  ContentView.swift
//  Univinity
//
//  Created by Sara Kanu on 4/21/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()

    var body: some View {
        RootView()
            .environmentObject(authViewModel)
    }
}

#Preview {
    ContentView()
}
