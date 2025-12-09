//
//  ProfileView.swift
//  FoodLens
//
//  Created by Emre Uğur on 9.12.2025.
//
import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.gray)
                
                Text(viewModel.userSession?.email ?? "Kullanıcı")
                    .font(.headline)
                
                Button {
                    viewModel.signOut()
                } label: {
                    Text("Log Out")
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(Color.red)
                        .cornerRadius(10)
                }
            }
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
}
