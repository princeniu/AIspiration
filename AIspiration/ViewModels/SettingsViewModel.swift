//
//  SettingsViewModel.swift
//  AIspiration
//
//  Created for AIspiration project
//

import Foundation
import SwiftUI
import SwiftData
import Combine

// 使用@MainActor标记整个类，确保所有UI更新都在主线程上执行
@MainActor
class SettingsViewModel: ObservableObject, @unchecked Sendable {
    // 用户设置
    @Published var userSettings: UserSettings
    
    // 通知服务
    private let notificationService = NotificationService.shared
    
    // 数据服务
    private let dataService = DataService.shared
    
    // 初始化
    init(userSettings: UserSettings = UserSettings.defaultSettings) {
        self.userSettings = userSettings
    }
    
    // 加载用户设置
    func loadSettings(modelContext: ModelContext) {
        if let settings = dataService.getUserSettings(modelContext: modelContext) {
            self.userSettings = settings
        } else {
            // 如果没有设置，则创建默认设置
            let defaultSettings = UserSettings.defaultSettings
            modelContext.insert(defaultSettings)
            self.userSettings = defaultSettings
            
            do {
                try modelContext.save()
            } catch {
                print("保存默认设置失败: \(error.localizedDescription)")
            }
        }
    }
    
    // 更新通知设置 - 提供一个安全的入口点，可以从@Sendable闭包中调用
    nonisolated func updateNotificationSettingsFromTask(enabled: Bool, time: Date, modelContext: ModelContext) {
        performModelContextOperation({ context in
            Task {
                await self.updateNotificationSettings(enabled: enabled, time: time, modelContext: context)
            }
        }, with: modelContext)
    }
    
    // 更新通知设置 - 实际实现
    func updateNotificationSettings(enabled: Bool, time: Date, modelContext: ModelContext) async {
        // 如果启用通知，则请求授权
        if enabled {
            let authorized = await notificationService.requestAuthorization()
            if !authorized {
                // 如果用户拒绝授权，则禁用通知
                self.userSettings.notificationsEnabled = false
                return
            }
        }
        
        // 更新设置
        self.userSettings.notificationsEnabled = enabled
        self.userSettings.notificationTime = time
        
        // 更新通知
        self.notificationService.updateNotificationSettings(enabled: enabled, time: time)
        
        // 保存设置
        self.dataService.updateUserSettings(modelContext: modelContext, settings: self.userSettings)
    }
    
    // 更新主题设置
    func updateThemeSettings(themeColor: String, useDarkMode: Bool, useSystemTheme: Bool, modelContext: ModelContext) {
        userSettings.themeColor = themeColor
        userSettings.useDarkMode = useDarkMode
        userSettings.useSystemTheme = useSystemTheme
        
        dataService.updateUserSettings(modelContext: modelContext, settings: userSettings)
    }
    
    // 更新背景设置
    func updateBackgroundSettings(backgroundType: BackgroundType, backgroundColor: String, backgroundImageName: String?, modelContext: ModelContext) {
        userSettings.backgroundType = backgroundType
        userSettings.customBackgroundColor = backgroundColor
        userSettings.customBackgroundImageName = backgroundImageName
        
        dataService.updateUserSettings(modelContext: modelContext, settings: userSettings)
    }
    
    // 更新API密钥
    func updateAPIKey(apiKey: String, modelContext: ModelContext) {
        userSettings.apiKey = apiKey
        dataService.updateUserSettings(modelContext: modelContext, settings: userSettings)
    }
    
    // 重置所有设置
    func resetAllSettings(modelContext: ModelContext) {
        // 创建新的默认设置
        let defaultSettings = UserSettings.defaultSettings
        
        // 保留API密钥
        defaultSettings.apiKey = userSettings.apiKey
        
        // 更新设置
        userSettings = defaultSettings
        
        // 更新通知
        notificationService.updateNotificationSettings(
            enabled: defaultSettings.notificationsEnabled,
            time: defaultSettings.notificationTime
        )
        
        // 保存设置
        dataService.updateUserSettings(modelContext: modelContext, settings: userSettings)
    }
    
    // 检查通知授权状态
    func checkNotificationAuthorizationStatus() async -> Bool {
        let status = await notificationService.checkAuthorizationStatus()
        return status == .authorized
    }
} 