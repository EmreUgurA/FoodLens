//
//  mainView.swift
//  FoodLens
//
//  Created by Emre Uğur on 31.10.2025.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            ZStack{
                Color.black.opacity(0.4).ignoresSafeArea()
                VStack{
                    Text("Hello, World!")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                    Text("Welcome to FoodLens")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
        }
        .navigationTitle("Hello, Emre!")
        .navigationBarTitleDisplayMode(.inline)
        
    }
}

#Preview {
    HomeView()
}
