//
//  AuthenticationView.swift
//

import SwiftUI

struct AuthenticationView: View {
    @Environment(AppState.self) private var appState
    @State private var isSignUp = true
    @State private var email = ""
    @State private var name = ""
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [.purple, .blue],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // Logo and Title
                VStack(spacing: 16) {
                    Image(systemName: "graduationcap.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.white)
                    
                    Text("Univunity")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    
                    Text("Swipe Your Way to College")
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.9))
                }
                
                Spacer()
                
                // Auth Form
                VStack(spacing: 20) {
                    if isSignUp {
                        TextField("Name", text: $name)
                            .textFieldStyle(RoundedTextFieldStyle())
                    }
                    
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedTextFieldStyle())
                        .textContentType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                    
                    Button {
                        handleAuth()
                    } label: {
                        Text(isSignUp ? "Sign Up" : "Log In")
                            .font(.headline)
                            .foregroundStyle(.purple)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    
                    Button {
                        withAnimation {
                            isSignUp.toggle()
                            email = ""
                            name = ""
                        }
                    } label: {
                        Text(isSignUp ? "Already have an account? Log in" : "Don't have an account? Sign up")
                            .font(.subheadline)
                            .foregroundStyle(.white)
                    }
                }
                .padding(.horizontal, 32)
                
                Spacer()
            }
        }
    }
    
    private func handleAuth() {
        guard !email.isEmpty else { return }
        
        if isSignUp {
            guard !name.isEmpty else { return }
            appState.signUp(email: email, name: name)
        } else {
            appState.login(email: email)
        }
    }
}

// MARK: - Custom Text Field Style
struct RoundedTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .font(.body)
    }
}