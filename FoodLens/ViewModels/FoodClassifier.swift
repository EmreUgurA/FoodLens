import Foundation
import CoreML
import Vision
import UIKit

struct FoodEntry: Identifiable, Codable {
    let id: UUID
    let name: String
    let confidence: Double
    let calories: Int
    let carbonKg: Double
    let portionTitle: String
    let portionMultiplier: Double
    let imageData: Data?
    let createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        confidence: Double,
        calories: Int,
        carbonKg: Double,
        portionTitle: String = "Normal",
        portionMultiplier: Double = 1,
        imageData: Data?,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.confidence = confidence
        self.calories = calories
        self.carbonKg = carbonKg
        self.portionTitle = portionTitle
        self.portionMultiplier = portionMultiplier
        self.imageData = imageData
        self.createdAt = createdAt
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case confidence
        case calories
        case carbonKg
        case portionTitle
        case portionMultiplier
        case imageData
        case createdAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        confidence = try container.decode(Double.self, forKey: .confidence)
        calories = try container.decode(Int.self, forKey: .calories)
        carbonKg = try container.decode(Double.self, forKey: .carbonKg)
        portionTitle = try container.decodeIfPresent(String.self, forKey: .portionTitle) ?? "Normal"
        portionMultiplier = try container.decodeIfPresent(Double.self, forKey: .portionMultiplier) ?? 1
        imageData = try container.decodeIfPresent(Data.self, forKey: .imageData)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
    }
}

struct FoodPrediction {
    let name: String
    let confidence: Double
    let calories: Int
    let carbonKg: Double
}

enum NutritionEstimator {
    private static let foods: [String: (calories: Int, carbonKg: Double)] = [
        "apple": (95, 0.04),
        "banana": (105, 0.08),
        "bread": (180, 0.28),
        "burger": (540, 2.50),
        "cake": (360, 0.80),
        "chicken": (335, 1.30),
        "coffee": (5, 0.05),
        "egg": (78, 0.25),
        "fish": (280, 1.60),
        "fries": (365, 0.70),
        "meat": (520, 4.80),
        "pasta": (420, 0.55),
        "pizza": (285, 1.20),
        "rice": (205, 0.35),
        "salad": (150, 0.20),
        "sandwich": (320, 0.65),
        "soup": (180, 0.25),
        "steak": (650, 6.00),
        "sushi": (300, 0.90),
        "yogurt": (120, 0.18)
    ]

    static func estimate(for rawName: String) -> (calories: Int, carbonKg: Double) {
        let normalized = rawName.lowercased()

        if let exact = foods[normalized] {
            return exact
        }

        if let match = foods.first(where: { normalized.contains($0.key) || $0.key.contains(normalized) }) {
            return match.value
        }

        return (calories: 300, carbonKg: 0.70)
    }
}

@MainActor
final class HealthActivityStore: ObservableObject {
    @Published private(set) var entries: [FoodEntry] = []
    @Published var waterMilliliters: Int = 0 {
        didSet { save() }
    }

    let dailyCalorieGoal = 2000
    let dailyWaterGoal = 2500

    private let storageKey = "foodlens.healthActivityStore.v1"

    init() {
        load()
    }

    var todayEntries: [FoodEntry] {
        entries.filter { Calendar.current.isDateInToday($0.createdAt) }
    }

    var todayCalories: Int {
        todayEntries.reduce(0) { $0 + $1.calories }
    }

    var todayCarbonKg: Double {
        todayEntries.reduce(0) { $0 + $1.carbonKg }
    }

    var weeklyEntries: [FoodEntry] {
        let start = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return entries.filter { $0.createdAt >= start }
    }

    var weeklyCalories: Int {
        weeklyEntries.reduce(0) { $0 + $1.calories }
    }

    var weeklyCarbonKg: Double {
        weeklyEntries.reduce(0) { $0 + $1.carbonKg }
    }

    var averageConfidence: Int {
        guard !entries.isEmpty else { return 0 }
        let average = entries.reduce(0.0) { $0 + $1.confidence } / Double(entries.count)
        return Int(average * 100)
    }

    var calorieProgress: Double {
        min(Double(todayCalories) / Double(dailyCalorieGoal), 1)
    }

    var waterProgress: Double {
        min(Double(waterMilliliters) / Double(dailyWaterGoal), 1)
    }

    var recommendation: String {
        if todayCalories >= Int(Double(dailyCalorieGoal) * 0.9) {
            return "Günlük limitine yaklaştın. Akşam için çorba, salata veya yoğurt gibi daha hafif bir seçim iyi gider."
        }

        if todayCarbonKg > 4 {
            return "Bugünkü karbon ayak izin yükseliyor. Bir sonraki öğünde sebze ağırlıklı bir tabak denemek denge sağlar."
        }

        if waterMilliliters < 1000 {
            return "Su hedefinin gerisindesin. Bir bardak su ekleyip günü daha dengeli götürebilirsin."
        }

        return "Denge iyi görünüyor. Protein ve lif içeren sakin bir ara öğün enerjini korur."
    }

    func addWater(amount: Int = 250) {
        waterMilliliters = min(waterMilliliters + amount, dailyWaterGoal)
    }

    func resetWater() {
        waterMilliliters = 0
    }

    func addEntry(from prediction: FoodPrediction, image: UIImage?, portionTitle: String = "Normal", portionMultiplier: Double = 1) {
        let thumbnail = image?.resizedForStorage(maxDimension: 480).jpegData(compressionQuality: 0.72)
        let entry = FoodEntry(
            name: prediction.name.capitalized,
            confidence: prediction.confidence,
            calories: Int(Double(prediction.calories) * portionMultiplier),
            carbonKg: prediction.carbonKg * portionMultiplier,
            portionTitle: portionTitle,
            portionMultiplier: portionMultiplier,
            imageData: thumbnail
        )
        entries.insert(entry, at: 0)
        save()
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let snapshot = try? JSONDecoder().decode(StoreSnapshot.self, from: data) else {
            return
        }

        entries = snapshot.entries.sorted { $0.createdAt > $1.createdAt }

        if Calendar.current.isDateInToday(snapshot.waterDate) {
            waterMilliliters = snapshot.waterMilliliters
        } else {
            waterMilliliters = 0
        }
    }

    private func save() {
        let snapshot = StoreSnapshot(
            entries: entries,
            waterMilliliters: waterMilliliters,
            waterDate: Date()
        )

        if let data = try? JSONEncoder().encode(snapshot) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
}

private struct StoreSnapshot: Codable {
    let entries: [FoodEntry]
    let waterMilliliters: Int
    let waterDate: Date
}

class FoodClassifier: ObservableObject {
    // UI tarafında anında güncellenecek sonuç değişkeni
    @Published var predictionResult: String = "Yemek bekleniyor..."
    @Published var latestPrediction: FoodPrediction?
    @Published var isClassifying = false
    
    func classifyImage(image: UIImage) {
        isClassifying = true
        latestPrediction = nil

        // 1. Kendi modelimizi Vision formatında yüklüyoruz
        guard let mlModel = try? FoodScanner(configuration: MLModelConfiguration()).model,
              let visionModel = try? VNCoreMLModel(for: mlModel) else {
            DispatchQueue.main.async {
                self.predictionResult = "Model yüklenemedi"
                self.isClassifying = false
            }
            return
        }
        
        // 2. Tahmin isteğini (Request) hazırlıyoruz
        let request = VNCoreMLRequest(model: visionModel) { request, error in
            guard let results = request.results as? [VNClassificationObservation],
                  let topResult = results.first else {
                DispatchQueue.main.async {
                    self.predictionResult = "Sonuç bulunamadı"
                    self.isClassifying = false
                }
                return
            }
            
            // 3. Sonucu ekrana yansıt (Ana thread üzerinde olmalı)
            DispatchQueue.main.async {
                // topResult.identifier -> Modelin bulduğu sınıf adı (ör: pizza)
                // topResult.confidence -> Emin olma oranı (0.0 ile 1.0 arası)
                let confidence = Int(topResult.confidence * 100)
                let estimate = NutritionEstimator.estimate(for: topResult.identifier)
                let prediction = FoodPrediction(
                    name: topResult.identifier,
                    confidence: Double(topResult.confidence),
                    calories: estimate.calories,
                    carbonKg: estimate.carbonKg
                )

                self.latestPrediction = prediction
                self.predictionResult = "\(topResult.identifier.capitalized) (% \(confidence))"
                self.isClassifying = false
            }
        }
        
        // 4. Cihaz fotoğraflarında EXIF yönü farklı gelebilir; Vision'a açıkça yön veriyoruz.
        let normalizedImage = image.normalizedForVision()
        guard let cgImage = normalizedImage.cgImage else {
            DispatchQueue.main.async {
                self.predictionResult = "Görsel okunamadı"
                self.isClassifying = false
            }
            return
        }

        let handler = VNImageRequestHandler(
            cgImage: cgImage,
            orientation: normalizedImage.cgImagePropertyOrientation,
            options: [:]
        )
        
        do {
            try handler.perform([request])
        } catch {
            print("Sınıflandırma hatası: \(error)")
            DispatchQueue.main.async {
                self.predictionResult = "Sınıflandırma hatası"
                self.isClassifying = false
            }
        }
    }
}

private extension UIImage {
    var cgImagePropertyOrientation: CGImagePropertyOrientation {
        switch imageOrientation {
        case .up:
            return .up
        case .upMirrored:
            return .upMirrored
        case .down:
            return .down
        case .downMirrored:
            return .downMirrored
        case .left:
            return .left
        case .leftMirrored:
            return .leftMirrored
        case .right:
            return .right
        case .rightMirrored:
            return .rightMirrored
        @unknown default:
            return .up
        }
    }

    func normalizedForVision() -> UIImage {
        guard imageOrientation != .up else { return self }

        let format = UIGraphicsImageRendererFormat.default()
        format.scale = scale

        return UIGraphicsImageRenderer(size: size, format: format).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }

    func resizedForStorage(maxDimension: CGFloat) -> UIImage {
        let largestSide = max(size.width, size.height)
        guard largestSide > maxDimension else { return self }

        let scale = maxDimension / largestSide
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)

        return UIGraphicsImageRenderer(size: newSize).image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
