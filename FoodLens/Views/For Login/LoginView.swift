//
//  LoginView.swift
//  FoodLens
//
//  Created by Emre Uğur on 9.12.2025.
//

import SwiftUI
import AuthenticationServices
import GoogleSignIn
import FirebaseAuth

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var viewModel: AuthViewModel
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                
                Spacer()
                
                VStack(spacing: 10) {
                    Image(systemName: "camera.macro.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.green)
                    
                    Text("Welcome Back")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Sign in to continue")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                VStack(spacing: 16) {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                    
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                    
                    // Giriş Butonu
                    Button {
                        Task {
                            try? await viewModel.login(email: email, password: password)
                        }
                    } label: {
                        Text("Log In")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.green)
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                
                HStack {
                    Rectangle().frame(height: 1).foregroundColor(.gray.opacity(0.3))
                    Text("OR").font(.caption).foregroundColor(.gray)
                    Rectangle().frame(height: 1).foregroundColor(.gray.opacity(0.3))
                }
                .padding(.horizontal)
                
                VStack(spacing: 12) {
                    
                    // APPLE SIGN IN
                    SignInWithAppleButton(
                        .signIn,
                        onRequest: { request in
                            // Apple giriş isteği oluşturma
                            viewModel.handleAppleLoginRequest(request: request)
                        },
                        onCompletion: { result in
                            // Sonucu işleme
                            viewModel.handleAppleLoginCompletion(result: result)
                        }
                    )
                    .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
                    .frame(height: 50)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // GOOGLE SIGN IN
                    Button {
                        viewModel.signInWithGoogle()
                    } label: {
                        HStack {
                            Image(systemName: "g.circle.fill")
                                .resizable()
                                .frame(width: 20, height: 20)
                            
                            Text("Sign in with Google")
                                .font(.headline)
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
                
                // Register
                NavigationLink {
                    Text("Register View")
                } label: {
                    HStack {
                        Text("Don't have an account?")
                            .foregroundColor(.gray)
                        Text("Sign Up")
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                    .font(.footnote)
                }
                .padding(.bottom, 20)
            }
        }
    }
}
