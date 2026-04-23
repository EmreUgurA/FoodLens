import Foundation
import CoreML
import Vision
import UIKit

class FoodClassifier: ObservableObject {
    // UI tarafında anında güncellenecek sonuç değişkeni
    @Published var predictionResult: String = "Yemek bekleniyor..."
    
    func classifyImage(image: UIImage) {
        // 1. Kendi modelimizi Vision formatında yüklüyoruz
        guard let mlModel = try? FoodScanner(configuration: MLModelConfiguration()).model,
              let visionModel = try? VNCoreMLModel(for: mlModel) else {
            print("Model yüklenemedi!")
            return
        }
        
        // 2. Tahmin isteğini (Request) hazırlıyoruz
        let request = VNCoreMLRequest(model: visionModel) { request, error in
            guard let results = request.results as? [VNClassificationObservation],
                  let topResult = results.first else {
                DispatchQueue.main.async {
                    self.predictionResult = "Sonuç bulunamadı"
                }
                return
            }
            
            // 3. Sonucu ekrana yansıt (Ana thread üzerinde olmalı)
            DispatchQueue.main.async {
                // topResult.identifier -> Modelin bulduğu sınıf adı (ör: pizza)
                // topResult.confidence -> Emin olma oranı (0.0 ile 1.0 arası)
                let confidence = Int(topResult.confidence * 100)
                self.predictionResult = "\(topResult.identifier) (% \(confidence))"
            }
        }
        
        // 4. Gelen UIImage'ı Vision'ın anladığı CIImage formatına çevir ve modeli çalıştır
        guard let ciImage = CIImage(image: image) else { return }
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        
        do {
            try handler.perform([request])
        } catch {
            print("Sınıflandırma hatası: \(error)")
        }
    }
}
