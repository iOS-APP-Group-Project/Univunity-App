//
//  LoginView.swift
//  Univinity
//
//  Created by Sara Kanu on 4/21/26.
//
import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    @State private var username = ""
    @State private var password = ""
    @State private var showSignUp = false

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [.indigo, .purple, .teal],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 20) {
                    Spacer()

                    Text("Univinity")
                        .font(.system(size: 40, weight: .heavy))
                        .foregroundStyle(.white)

                    Text("Find colleges that match your future.")
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.9))

                    VStack(spacing: 16) {
                        TextField("Username", text: $username)
                            .textInputAutocapitalization(.never)
                            .padding()
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))

                        SecureField("Password", text: $password)
                            .padding()
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))

                        Button("Log In") {
                            authViewModel.login(username: username, password: password)
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .foregroundStyle(.indigo)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.horizontal, 24)

                    if !authViewModel.errorMessage.isEmpty {
                        Text(authViewModel.errorMessage)
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    Button("Create Account") {
                        showSignUp = true
                    }
                    .foregroundStyle(.white)
                    .padding(.top, 8)

                    Spacer()
                }
            }
            .navigationDestination(isPresented: $showSignUp) {
                SignUpView()
                    .environmentObject(authViewModel)
            }
        }
    }
}
