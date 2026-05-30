//
//  AddingItemView.swift
//  FoodLens
//
//  Created by Emre Uğur on 9.12.2025.
//

import SwiftUI
import PhotosUI
import UIKit

private enum PortionOption: String, CaseIterable, Identifiable {
    case small = "Küçük"
    case normal = "Normal"
    case large = "Büyük"

    var id: String { rawValue }

    var multiplier: Double {
        switch self {
        case .small:
            return 0.7
        case .normal:
            return 1
        case .large:
            return 1.35
        }
    }

    var description: String {
        switch self {
        case .small:
            return "Daha küçük porsiyon"
        case .normal:
            return "Standart tabak"
        case .large:
            return "Büyük porsiyon"
        }
    }
}

struct AddingItemView: View {
    @EnvironmentObject private var activityStore: HealthActivityStore
    @StateObject private var classifier = FoodClassifier()
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var selectedPortion: PortionOption = .normal
    @State private var didSaveCurrentPrediction = false
    @State private var isShowingCamera = false
    @State private var showCameraUnavailableAlert = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    header
                    imagePreview

                    sourceButtons
                    resultCard

                }
                .padding(.horizontal, 24)
                .padding(.vertical, 18)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Scan")
            .sheet(isPresented: $isShowingCamera) {
                CameraPicker { image in
                    handlePickedImage(image)
                }
                .ignoresSafeArea()
            }
            .alert("Kamera kullanılamıyor", isPresented: $showCameraUnavailableAlert) {
                Button("Tamam", role: .cancel) {}
            } message: {
                Text("Bu cihazda kamera bulunamadı veya simülatörde kamera desteklenmiyor. Galeriden fotoğraf seçebilirsin.")
            }
        }
    }

    private var header: some View {
        VStack(spacing: 10) {
            Image(systemName: "camera.macro.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 72, height: 72)
                .foregroundColor(.green)

            Text("Food Scan")
                .font(.title2.weight(.bold))

            Text("Galeriden seç veya kamerayla çek; porsiyonuna göre kalori ve karbon etkisini gör.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }

    private var imagePreview: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30)
                .fill(Color(.secondarySystemBackground))

            if let selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .padding(10)
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 46))
                        .foregroundColor(.green)
                    Text("Henüz fotoğraf seçilmedi")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 260, maxHeight: 380)
        .aspectRatio(4 / 3, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .overlay {
            RoundedRectangle(cornerRadius: 30)
                .stroke(Color.green.opacity(0.12), lineWidth: 1)
        }
        .shadow(color: Color.green.opacity(0.10), radius: 14, x: 0, y: 10)
    }

    private var sourceButtons: some View {
        HStack(spacing: 12) {
            PhotosPicker(selection: $selectedItem, matching: .images) {
                Label("Galeri", systemImage: "photo.on.rectangle")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
            .controlSize(.large)
            .onChange(of: selectedItem) { _, _ in
                Task {
                    if let data = try? await selectedItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        await MainActor.run {
                            handlePickedImage(uiImage)
                        }
                    }
                }
            }

            Button {
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    isShowingCamera = true
                } else {
                    showCameraUnavailableAlert = true
                }
            } label: {
                Label("Kamera", systemImage: "camera.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
            .controlSize(.large)
        }
    }

    private var resultCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label("Analiz Sonucu", systemImage: "sparkles")
                    .font(.headline)
                Spacer()
                if classifier.isClassifying {
                    ProgressView()
                }
            }

            Text(classifier.predictionResult)
                .font(.title3.weight(.bold))

            if let prediction = classifier.latestPrediction {
                portionPicker

                HStack(spacing: 12) {
                    insight("Kalori", "\(adjustedCalories(for: prediction)) kcal", "flame")
                    insight("Karbon", String(format: "%.2f kg", adjustedCarbon(for: prediction)), "leaf")
                    insight("Güven", "%\(Int(prediction.confidence * 100))", "checkmark.seal")
                }

                Button {
                    activityStore.addEntry(
                        from: prediction,
                        image: selectedImage,
                        portionTitle: selectedPortion.rawValue,
                        portionMultiplier: selectedPortion.multiplier
                    )
                    didSaveCurrentPrediction = true
                } label: {
                    Label(didSaveCurrentPrediction ? "Günlüğe Eklendi" : "Günlüğe Ekle", systemImage: didSaveCurrentPrediction ? "checkmark.circle.fill" : "plus.circle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(didSaveCurrentPrediction)
            } else {
                Text("Fotoğraf seçtiğinde tahmini kalori ve karbon ayak izi burada görünecek.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(20)
        .background(Color.white)
        .foregroundStyle(.primary)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: Color.black.opacity(0.08), radius: 14, x: 0, y: 8)
    }

    private var portionPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Porsiyon Boyutu", systemImage: "slider.horizontal.3")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text(selectedPortion.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Picker("Porsiyon Boyutu", selection: $selectedPortion) {
                ForEach(PortionOption.allCases) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: selectedPortion) { _, _ in
                if classifier.latestPrediction != nil {
                    didSaveCurrentPrediction = false
                }
            }
        }
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private func insight(_ title: String, _ value: String, _ icon: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: icon)
                .foregroundStyle(.green)
            Text(value)
                .font(.subheadline.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.78)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private func handlePickedImage(_ image: UIImage) {
        selectedImage = image
        selectedPortion = .normal
        didSaveCurrentPrediction = false
        classifier.classifyImage(image: image)
    }

    private func adjustedCalories(for prediction: FoodPrediction) -> Int {
        Int(Double(prediction.calories) * selectedPortion.multiplier)
    }

    private func adjustedCarbon(for prediction: FoodPrediction) -> Double {
        prediction.carbonKg * selectedPortion.multiplier
    }
}

private struct CameraPicker: UIViewControllerRepresentable {
    let onImagePicked: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.cameraCaptureMode = .photo
        picker.allowsEditing = false
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onImagePicked: onImagePicked, dismiss: dismiss)
    }

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let onImagePicked: (UIImage) -> Void
        let dismiss: DismissAction

        init(onImagePicked: @escaping (UIImage) -> Void, dismiss: DismissAction) {
            self.onImagePicked = onImagePicked
            self.dismiss = dismiss
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                onImagePicked(image)
            }
            dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            dismiss()
        }
    }
}

#Preview {
    AddingItemView()
        .environmentObject(HealthActivityStore())
}
