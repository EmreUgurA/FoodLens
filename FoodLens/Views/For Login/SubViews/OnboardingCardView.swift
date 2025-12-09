//
//  OnboardingCardView.swift
//  FoodLens
//
//  Created by Emre Uğur on 9.12.2025.
//

import SwiftUI

struct OnboardingCardView: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // İkon Alanı
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 80, height: 80)
                
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.white)
            }
            .padding(.bottom, 20)
            .frame(maxWidth: .infinity) // İkonu ortala
            
            Spacer()
            
            Text("FoodLens ile")
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
            
            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.white)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.white)
            }
            .padding(.top, 5)
        }
        .padding(30)
        .frame(width: 280, height: 380)
        .background(
            LinearGradient(colors: [color, color.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .cornerRadius(30)
        .shadow(color: color.opacity(0.3), radius: 10, x: 0, y: 10)
    }
}
