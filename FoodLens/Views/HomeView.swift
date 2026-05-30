import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var activityStore: HealthActivityStore

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    heroHeader
                    dailySummary
                    waterTracker
                    recommendationCard
                    todayMeals
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 18)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("FoodLens")
        }
    }

    private var heroHeader: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.14))
                    .frame(width: 64, height: 64)

                Image(systemName: "camera.macro.circle.fill")
                    .font(.system(size: 42))
                    .foregroundStyle(.green)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Sağlıklı Yaşam Asistanı")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.green)
                Text("Bugünkü durumun")
                    .font(.title2.weight(.bold))
                Text("Kalori, su ve karbon etkisini tek bakışta takip et.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.top, 4)
    }

    private var dailySummary: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Bugünkü Özet")
                        .font(.title2.weight(.bold))
                    Text("Kalori ve karbon dengen")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.82))
                }

                Spacer()

                Image(systemName: "leaf.circle.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(.white)
            }

            HStack(spacing: 14) {
                progressRing(
                    value: activityStore.calorieProgress,
                    title: "Kalori",
                    valueText: "\(activityStore.todayCalories)",
                    footer: "\(activityStore.dailyCalorieGoal) kcal"
                )

                Divider()
                    .overlay(Color.white.opacity(0.22))

                VStack(alignment: .leading, spacing: 10) {
                    metricRow(
                        icon: "leaf",
                        title: "Karbon ayak izi",
                        value: String(format: "%.2f kg CO2e", activityStore.todayCarbonKg)
                    )
                    metricRow(
                        icon: "fork.knife",
                        title: "Öğün kaydı",
                        value: "\(activityStore.todayEntries.count)"
                    )
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(20)
        .background(
            LinearGradient(colors: [Color.green, Color.green.opacity(0.82)], startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .foregroundColor(.white)
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .shadow(color: Color.green.opacity(0.24), radius: 16, x: 0, y: 10)
    }

    private var waterTracker: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Su Takibi", systemImage: "drop.fill")
                    .font(.headline)
                    .foregroundStyle(.blue)

                Spacer()

                Text("\(activityStore.waterMilliliters) / \(activityStore.dailyWaterGoal) ml")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            ProgressView(value: activityStore.waterProgress)
                .tint(.blue)

            HStack {
                Button {
                    activityStore.addWater()
                } label: {
                    Label("+250 ml", systemImage: "plus.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)

                Button {
                    activityStore.resetWater()
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .frame(width: 42, height: 34)
                }
                .buttonStyle(.bordered)
                .accessibilityLabel("Su takibini sıfırla")
            }
        }
        .padding(20)
        .background(Color.white)
        .foregroundStyle(.primary)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: Color.blue.opacity(0.12), radius: 14, x: 0, y: 8)
    }

    private var recommendationCard: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.14))
                    .frame(width: 46, height: 46)

                Image(systemName: "lightbulb.max.fill")
                    .font(.title3)
                    .foregroundStyle(.orange)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Akıllı Öneri")
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(activityStore.recommendation)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(20)
        .background(Color.white)
        .foregroundStyle(.primary)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: Color.orange.opacity(0.12), radius: 14, x: 0, y: 8)
    }

    private var todayMeals: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Bugünkü Öğünler")
                .font(.headline)

            if activityStore.todayEntries.isEmpty {
                Text("Bugün henüz öğün eklenmedi. Scan sekmesinden fotoğraf seçerek başlayabilirsin.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 8)
            } else {
                ForEach(activityStore.todayEntries.prefix(3)) { entry in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(entry.name)
                                .font(.subheadline.weight(.semibold))
                            Text(entry.portionTitle)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text("\(entry.calories) kcal")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 6)
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .foregroundStyle(.primary)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: Color.black.opacity(0.08), radius: 14, x: 0, y: 8)
    }

    private func progressRing(value: Double, title: String, valueText: String, footer: String) -> some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.22), lineWidth: 12)
            Circle()
                .trim(from: 0, to: value)
                .stroke(Color.white, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                .rotationEffect(.degrees(-90))

            VStack(spacing: 3) {
                Text(valueText)
                    .font(.title3.weight(.bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.82))
                Text(footer)
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.82))
            }
            .padding(8)
        }
        .frame(width: 128, height: 128)
        .accessibilityElement(children: .combine)
    }

    private func metricRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundStyle(.white)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.headline)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.82))
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(HealthActivityStore())
}
