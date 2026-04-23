//
//  AddingItemView.swift
//  FoodLens
//
//  Created by Emre Uğur on 9.12.2025.
//

import SwiftUI
import PhotosUI

struct AddingItemView: View {
    @StateObject private var classifier = FoodClassifier()
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    
    var body: some View {
        VStack(spacing: 30) {
            // Seçilen Fotoğrafı Gösterme Alanı
            if let selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 300, height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            } else {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 300, height: 300)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                    )
            }
            
            // Tahmin Sonucu
            Text(classifier.predictionResult)
                .font(.title2)
                .bold()
            
            // Galeri Butonu
            PhotosPicker(selection: $selectedItem, matching: .images) {
                Label("Fotoğraf Seç ve Analiz Et", systemImage: "photo.on.rectangle")
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .onChange(of: selectedItem) { _ in
                Task {
                    if let data = try? await selectedItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        self.selectedImage = uiImage
                        // Fotoğraf seçilince modeli çalıştır!
                        classifier.classifyImage(image: uiImage)
                    }
                }
            }
        }
        .padding()
    }
}
