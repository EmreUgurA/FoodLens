//
//  MainTabView.swift
//  FoodLens
//
//  Created by Emre Uğur on 9.12.2025.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            HomeView()
                .tabItem {
                    Image(systemName: "chart.bar.doc.horizontal")
                    Text("Summary")
                }
                .tag(0)
            
            AddingItemView()
                .tabItem {
                    Image(systemName: "camera.viewfinder")
                    Text("Scan")
                }
                .tag(1)
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("Profile")
                }
                .tag(2)
        }
        .accentColor(.green)
        .onAppear {
            let appearance = UITabBarAppearance()
            appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
            appearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.9)
            
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}
