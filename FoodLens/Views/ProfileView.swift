import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @EnvironmentObject private var activityStore: HealthActivityStore

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    profileHeader
                    todayGoalCard
                    weeklyStatsCard
                    accountDetailsCard
                    dataInfoCard
                    signOutButton
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 18)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Profile")
        }
    }

    private var profileHeader: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.14))
                    .frame(width: 112, height: 112)

                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 88, height: 88)
                    .foregroundColor(.green)
            }

            VStack(spacing: 5) {
                Text("FoodLens Profile")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.primary)

                Text(viewModel.userSession?.email ?? "Kullanıcı")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 10)
    }

    private var todayGoalCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label("Günlük Hedefler", systemImage: "target")
                    .font(.headline)
                Spacer()
                Text("\(Int(activityStore.calorieProgress * 100))%")
                    .font(.headline)
            }

            VStack(spacing: 12) {
                goalRow(
                    icon: "flame.fill",
                    title: "Kalori",
                    value: "\(activityStore.todayCalories) / \(activityStore.dailyCalorieGoal) kcal",
                    progress: activityStore.calorieProgress,
                    color: .green
                )

                goalRow(
                    icon: "drop.fill",
                    title: "Su",
                    value: "\(activityStore.waterMilliliters) / \(activityStore.dailyWaterGoal) ml",
                    progress: activityStore.waterProgress,
                    color: .blue
                )
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

    private var weeklyStatsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Haftalık İstatistikler", systemImage: "chart.bar.fill")
                .font(.headline)
                .foregroundStyle(.primary)

            HStack(spacing: 12) {
                statTile("Kayıt", "\(activityStore.weeklyEntries.count)", "camera.viewfinder", .green)
                statTile("Kalori", "\(activityStore.weeklyCalories)", "flame", .orange)
                statTile("CO2e", String(format: "%.1f kg", activityStore.weeklyCarbonKg), "leaf", .green)
            }
        }
        .padding(20)
        .background(Color.white)
        .foregroundStyle(.primary)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: Color.black.opacity(0.08), radius: 14, x: 0, y: 8)
    }

    private var accountDetailsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Hesap Bilgileri", systemImage: "person.text.rectangle")
                .font(.headline)
                .foregroundStyle(.primary)

            detailRow("Oturum", viewModel.userSession == nil ? "Kapalı" : "Açık", "checkmark.seal.fill")
            detailRow("Toplam kayıt", "\(activityStore.entries.count)", "tray.full.fill")
            detailRow("Ortalama güven", "%\(activityStore.averageConfidence)", "scope")
        }
        .padding(20)
        .background(Color.white)
        .foregroundStyle(.primary)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: Color.black.opacity(0.08), radius: 14, x: 0, y: 8)
    }

    private var dataInfoCard: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.14))
                    .frame(width: 46, height: 46)

                Image(systemName: "lock.shield.fill")
                    .font(.title3)
                    .foregroundStyle(.blue)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Veri Notu")
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text("Su takibi ve öğün geçmişi şimdilik bu cihazda saklanır. Simülatör ve telefonun farklı görünmesi bu yüzden normal olabilir.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(20)
        .background(Color.white)
        .foregroundStyle(.primary)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: Color.blue.opacity(0.10), radius: 14, x: 0, y: 8)
    }

    private var signOutButton: some View {
        Button {
            viewModel.signOut()
        } label: {
            Label("Log Out", systemImage: "rectangle.portrait.and.arrow.right")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.red)
                .cornerRadius(30)
        }
        .padding(.top, 2)
    }

    private func goalRow(icon: String, title: String, value: String, progress: Double, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label(title, systemImage: icon)
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text(value)
                    .font(.caption.weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }

            ProgressView(value: progress)
                .tint(.white)
                .background(Color.white.opacity(0.18))
                .clipShape(Capsule())
        }
    }

    private func statTile(_ title: String, _ value: String, _ icon: String, _ color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(color)
            Text(value)
                .font(.headline)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private func detailRow(_ title: String, _ value: String, _ icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.green)
                .frame(width: 26)

            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
        .environmentObject(HealthActivityStore())
}
