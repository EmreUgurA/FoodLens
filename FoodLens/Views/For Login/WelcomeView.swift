//
//  WelcomeView.swift
//  FoodLens
//
//  Created by Emre Uğur on 9.12.2025.
//

import SwiftUI

struct WelcomeView: View {
    @State private var showLogin = false
    @State private var showRegister = false
    
    // Hangi kartta olduğumuzu takip eden değişken (Başlangıçta 0. kart)
    @State private var currentScrollID: Int? = 0
    
    let cards = [
        (icon: "camera.viewfinder", title: "Calorie Tracker", desc: "Snap a photo, track instantly.", color: Color.green),
        (icon: "chart.bar.fill", title: "Smart Insights", desc: "Visualize your nutrition data.", color: Color.blue),
        (icon: "heart.fill", title: "Stay Healthy", desc: "Syncs with Apple Health.", color: Color.orange)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()
                
                VStack {
                    Spacer()
        
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 0) {
                            ForEach(0..<cards.count, id: \.self) { index in
                                GeometryReader { geometry in
                                    OnboardingCardView(
                                        icon: cards[index].icon,
                                        title: cards[index].title,
                                        description: cards[index].desc,
                                        color: cards[index].color
                                    )
                                    // 3D Dönme Efekti 
                                    .rotation3DEffect(
                                        Angle(degrees: Double(geometry.frame(in: .global).minX - 30) / -15),
                                        axis: (x: 0, y: 1, z: 0)
                                    )
                                }
                                .frame(width: 280, height: 400)
                                .padding(.horizontal, 20) // Kartlar arası boşluk
                                .id(index) // Scroll pozisyonu için kimlik
                            }
                        }
                        .scrollTargetLayout() // Mıknatıs etkisi
                    }
                    .scrollTargetBehavior(.viewAligned) // Kartın tam ortada durması icin
                    .scrollPosition(id: $currentScrollID)
                    .contentMargins(.horizontal, 40, for: .scrollContent)
                    .frame(height: 450)
                    
                    // Nokta ile sayfa gosterimi
                    HStack(spacing: 8) {
                        ForEach(0..<cards.count, id: \.self) { index in
                            Circle()
                                .fill(
                                    (currentScrollID ?? 0) == index
                                    ? Color.green
                                    : Color.gray.opacity(0.3)
                                )
                                .frame(width: 8, height: 8)
                                .animation(.spring(), value: currentScrollID)
                        }
                    }
                    .padding(.top, 10)
                    
                    Spacer()
                    
                    VStack(spacing: 16) {
                        Button {
                            showRegister = true
                        } label: {
                            Text("Get Started")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color.green)
                                .cornerRadius(30)
                        }
                        
                        Button {
                            showLogin = true
                        } label: {
                            Text("Already have an account")
                                .font(.headline)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color(uiColor: .secondarySystemBackground))
                                .cornerRadius(30)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                    
                    Text("By continuing, you agree to our Terms and Privacy Policy")
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .padding(.bottom, 10)
                }
            }
            .navigationDestination(isPresented: $showLogin) {
                LoginView()
            }
            .navigationDestination(isPresented: $showRegister) {
                RegisterView()
            }
        }
    }
}
