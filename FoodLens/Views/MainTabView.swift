//
//  MainTabView.swift
//  FoodLens
//
//  Created by Emre Uğur on 9.12.2025.
//

import SwiftUI
import UIKit

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

            HistoryView()
                .tabItem {
                    Image(systemName: "clock.arrow.circlepath")
                    Text("History")
                }
                .tag(2)
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("Profile")
                }
                .tag(3)
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

struct HistoryView: View {
    @EnvironmentObject private var activityStore: HealthActivityStore
    @State private var reportURL: URL?
    @State private var isShowingShareSheet = false
    @State private var exportError: String?

    private var weekEntries: [FoodEntry] {
        let start = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return activityStore.entries.filter { $0.createdAt >= start }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    historyHeader
                    summaryCard

                    ForEach(activityStore.entries) { entry in
                        HistoryRow(entry: entry)
                    }

                    if activityStore.entries.isEmpty {
                        ContentUnavailableView(
                            "Henüz kayıt yok",
                            systemImage: "fork.knife.circle",
                            description: Text("Tarama yaptığında öğünlerin burada listelenecek.")
                        )
                        .padding(.top, 36)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 18)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("History")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        exportReport()
                    } label: {
                        Label("Rapor İndir", systemImage: "square.and.arrow.down")
                    }
                    .disabled(activityStore.entries.isEmpty)
                }
            }
            .sheet(isPresented: $isShowingShareSheet) {
                if let reportURL {
                    ShareSheet(items: [reportURL])
                }
            }
            .alert("Rapor oluşturulamadı", isPresented: Binding(
                get: { exportError != nil },
                set: { if !$0 { exportError = nil } }
            )) {
                Button("Tamam", role: .cancel) { exportError = nil }
            } message: {
                Text(exportError ?? "Bilinmeyen hata")
            }
        }
    }

    private var historyHeader: some View {
        VStack(spacing: 10) {
            Image(systemName: "doc.richtext.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 70, height: 70)
                .foregroundColor(.green)

            Text("Nutrition History")
                .font(.title2.weight(.bold))

            Text("Taramalarını, haftalık kalori toplamını ve karbon etkisini buradan takip et.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 6)
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Haftalık Rapor", systemImage: "doc.richtext")
                    .font(.headline)
                Spacer()
                Button {
                    exportReport()
                } label: {
                    Label("PDF", systemImage: "arrow.down.doc")
                        .labelStyle(.titleAndIcon)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .disabled(activityStore.entries.isEmpty)
            }

            HStack(spacing: 12) {
                metric("Kayıt", "\(weekEntries.count)", "camera.viewfinder")
                metric("Kalori", "\(weekEntries.reduce(0) { $0 + $1.calories })", "flame")
                metric("CO2e", String(format: "%.1f kg", weekEntries.reduce(0) { $0 + $1.carbonKg }), "leaf")
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

    private func metric(_ title: String, _ value: String, _ icon: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: icon)
                .foregroundStyle(.white)
            Text(value)
                .font(.headline)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Text(title)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.82))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func exportReport() {
        do {
            reportURL = try PDFReportRenderer.makeReport(entries: weekEntries)
            isShowingShareSheet = true
        } catch {
            exportError = error.localizedDescription
        }
    }
}

private struct HistoryRow: View {
    let entry: FoodEntry

    var body: some View {
        HStack(spacing: 12) {
            thumbnail

            VStack(alignment: .leading, spacing: 5) {
                Text(entry.name)
                    .font(.headline)
                Text(entry.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("Porsiyon: \(entry.portionTitle)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 5) {
                Text("\(entry.calories) kcal")
                    .font(.subheadline.weight(.semibold))
                Text(String(format: "%.2f kg CO2e", entry.carbonKg))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .background(Color.white)
        .foregroundStyle(.primary)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 7)
    }

    private var thumbnail: some View {
        Group {
            if let imageData = entry.imageData, let image = UIImage(data: imageData) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "fork.knife")
                    .font(.title2)
                    .foregroundStyle(.green)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.green.opacity(0.12))
            }
        }
        .frame(width: 58, height: 58)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

private struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

private enum PDFReportRenderer {
    static func makeReport(entries: [FoodEntry], title: String = "FoodLens Raporu") throws -> URL {
        let fileName = "FoodLens-Rapor-\(Int(Date().timeIntervalSince1970)).pdf"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        let pageRect = CGRect(x: 0, y: 0, width: 595, height: 842)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        let sortedEntries = entries.sorted { $0.createdAt > $1.createdAt }

        try renderer.writePDF(to: url) { context in
            var pageNumber = 1
            var y: CGFloat = 54
            startPage(context: context, pageRect: pageRect, title: title, pageNumber: pageNumber, y: &y)

            let totals = sortedEntries.reduce((calories: 0, carbon: 0.0)) { result, entry in
                (result.calories + entry.calories, result.carbon + entry.carbonKg)
            }

            drawText(
                "Toplam: \(totals.calories) kcal | \(String(format: "%.2f", totals.carbon)) kg CO2e",
                in: CGRect(x: 40, y: y, width: 515, height: 28),
                font: .boldSystemFont(ofSize: 15),
                color: .darkGray
            )
            y += 40

            if sortedEntries.isEmpty {
                drawText(
                    "Bu dönem için kayıt bulunamadı.",
                    in: CGRect(x: 40, y: y, width: 515, height: 40),
                    font: .systemFont(ofSize: 15),
                    color: .gray
                )
                return
            }

            for entry in sortedEntries {
                if y > pageRect.height - 135 {
                    pageNumber += 1
                    startPage(context: context, pageRect: pageRect, title: title, pageNumber: pageNumber, y: &y)
                }

                drawEntry(entry, y: y)
                y += 102
            }
        }

        return url
    }

    private static func startPage(context: UIGraphicsPDFRendererContext, pageRect: CGRect, title: String, pageNumber: Int, y: inout CGFloat) {
        context.beginPage()
        UIColor.systemGreen.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: pageRect.width, height: 18))

        drawText(title, in: CGRect(x: 40, y: 42, width: 360, height: 36), font: .boldSystemFont(ofSize: 24), color: .black)
        drawText(Date().formatted(date: .abbreviated, time: .shortened), in: CGRect(x: 390, y: 48, width: 165, height: 24), font: .systemFont(ofSize: 11), color: .gray, alignment: .right)
        drawText("Sayfa \(pageNumber)", in: CGRect(x: 40, y: pageRect.height - 36, width: 515, height: 18), font: .systemFont(ofSize: 10), color: .gray, alignment: .center)

        y = 98
    }

    private static func drawEntry(_ entry: FoodEntry, y: CGFloat) {
        let cardRect = CGRect(x: 40, y: y, width: 515, height: 82)
        UIColor(white: 0.96, alpha: 1).setFill()
        UIBezierPath(roundedRect: cardRect, cornerRadius: 8).fill()

        if let imageData = entry.imageData, let image = UIImage(data: imageData) {
            image.draw(in: CGRect(x: 52, y: y + 12, width: 58, height: 58))
        } else {
            UIColor.systemGray5.setFill()
            UIBezierPath(roundedRect: CGRect(x: 52, y: y + 12, width: 58, height: 58), cornerRadius: 8).fill()
        }

        drawText(entry.name, in: CGRect(x: 126, y: y + 13, width: 250, height: 22), font: .boldSystemFont(ofSize: 16), color: .black)
        drawText(entry.createdAt.formatted(date: .abbreviated, time: .shortened), in: CGRect(x: 126, y: y + 38, width: 220, height: 18), font: .systemFont(ofSize: 11), color: .gray)
        drawText("Porsiyon: \(entry.portionTitle)", in: CGRect(x: 126, y: y + 56, width: 220, height: 14), font: .systemFont(ofSize: 9), color: .gray)
        drawText("\(entry.calories) kcal\n\(String(format: "%.2f", entry.carbonKg)) kg CO2e", in: CGRect(x: 390, y: y + 19, width: 135, height: 42), font: .boldSystemFont(ofSize: 13), color: .darkGray, alignment: .right)
    }

    private static func drawText(_ text: String, in rect: CGRect, font: UIFont, color: UIColor, alignment: NSTextAlignment = .left) {
        let style = NSMutableParagraphStyle()
        style.alignment = alignment
        style.lineBreakMode = .byWordWrapping

        text.draw(
            in: rect,
            withAttributes: [
                .font: font,
                .foregroundColor: color,
                .paragraphStyle: style
            ]
        )
    }
}
