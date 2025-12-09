//
//  AddingItemView.swift
//  FoodLens
//
//  Created by Emre Uğur on 9.12.2025.
//

import SwiftUI

struct AddingItemView: View {
    var body: some View {
        VStack {
            Image(systemName: "camera.fill")
                .resizable()
                .frame(width: 100, height: 80)
                .foregroundColor(.green)
            Text("Kamera ve Yapay Zeka Buraya Gelecek")
                .padding()
        }
    }
}

#Preview {
    AddingItemView()
}