//
//  RegisterView.swift
//  FoodLens
//
//  Created by Emre Uğur on 9.12.2025.
//

import SwiftUI
import AuthenticationServices
import GoogleSignIn

struct RegisterView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: AuthViewModel
    
    
    @State private var showEmailForm = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                
                HStack {
                    Button {
                        dismiss() 
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title3)
                            .foregroundColor(.black)
                            .padding(10)
                            .background(Color.gray.opacity(0.1))
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding(.horizontal)
                
                Spacer()
                
                
                Image(systemName: "person.3.sequence.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 180)
                    .foregroundColor(.orange.opacity(0.8))
                    .padding(.bottom, 20)
                
                
                Text("Create Your Account")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                
                HStack(spacing: 20) {
                    // Apple Button
                    SocialLoginButton(iconName: "apple.logo", color: .black, iconColor: .white) {
                        let request = ASAuthorizationAppleIDProvider().createRequest()
                        viewModel.handleAppleLoginRequest(request: request)
                    }
                    
                    // Google Button
                    SocialLoginButton(iconName: "g.circle.fill", color: .white, iconColor: .blue, hasBorder: true) {
                        viewModel.signInWithGoogle()
                    }
                }
                .padding(.vertical, 10)
                
                
                HStack {
                    Rectangle().frame(height: 1).foregroundColor(.gray.opacity(0.3))
                    Text("OR").font(.caption).foregroundColor(.gray)
                    Rectangle().frame(height: 1).foregroundColor(.gray.opacity(0.3))
                }
                .padding(.horizontal, 40)
                
            
                Button {
                    showEmailForm = true
                } label: {
                    Text("Sign Up With Email")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color(uiColor: .secondarySystemBackground))
                        .cornerRadius(30)
                }
                .padding(.horizontal, 24)
                
                
                Spacer()
                
                // --- YASAL METİN ---
                Text("By signing up with email, or continuing with Google or Apple, you agree with the Terms Of Service & Privacy Policy.")
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .padding(.bottom, 10)
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $showEmailForm) {
                EmailRegisterFormView()
            }
        }
    }
}
