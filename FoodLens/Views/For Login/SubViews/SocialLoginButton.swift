//
//  SocialLoginButton.swift
//  FoodLens
//
//  Created by Emre Uğur on 9.12.2025.
//
import SwiftUI

struct SocialLoginButton: View {
    let iconName: String
    let color: Color
    let iconColor: Color
    var hasBorder: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: 56, height: 56)
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                
                if hasBorder {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        .frame(width: 56, height: 56)
                }
                
                Image(systemName: iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundColor(iconColor)
            }
        }
    }
}
