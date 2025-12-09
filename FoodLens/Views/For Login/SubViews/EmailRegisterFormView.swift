//
//  EmailRegisterFormView.swift
//  FoodLens
//
//  Created by Emre Uğur on 9.12.2025.
//
import SwiftUI

struct EmailRegisterFormView: View {
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Create Account")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            TextField("Email", text: $email)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
            
            SecureField("Password", text: $password)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
            
            Button {
                Task {
                    try? await viewModel.register(email: email, password: password)
                }
            } label: {
                Text("Sign Up")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.green)
                    .cornerRadius(12)
            }
            .padding(.top)
            
            Spacer()
        }
        .padding(24)
    }
}
