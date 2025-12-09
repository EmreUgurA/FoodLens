//
//  ContentView.swift
//  FoodLens
//
//  Created by Emre Uğur on 21.10.2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        Group {
            if viewModel.userSession != nil {
                MainTabView()
            } else {
                WelcomeView()
            }
        }
    }
}
