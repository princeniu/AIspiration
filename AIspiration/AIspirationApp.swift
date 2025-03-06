//
//  AIspirationApp.swift
//  AIspiration
//
//  Created by 牛拙 on 3/5/25.
//

import SwiftUI
import SwiftData

@main
struct AIspirationApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Quote.self,
            Category.self,
            UserSettings.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("无法创建ModelContainer: \(error)")
        }
    }()
    
    @State private var dataInitialized = false

    var body: some Scene {
        WindowGroup {
            SplashView()
                .onAppear {
                    if !dataInitialized {
                        initializeData()
                        dataInitialized = true
                    }
                }
        }
        .modelContainer(sharedModelContainer)
    }
    
    // 初始化应用数据
    private func initializeData() {
        let context = sharedModelContainer.mainContext
        let dataService = DataService.shared
        
        // 初始化默认数据
        dataService.initializeDefaultData(modelContext: context)
        
        // 请求通知权限
        Task {
            _ = await NotificationService.shared.requestAuthorization()
        }
    }
}
