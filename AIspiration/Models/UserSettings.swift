//
//  UserSettings.swift
//  AIspiration
//
//  Created for AIspiration project
//

import Foundation
import SwiftData
import SwiftUI

// 使UserSettings模型符合Sendable协议
@Model
final class UserSettings: @unchecked Sendable {
    // 通知设置
    var notificationsEnabled: Bool
    var notificationTime: Date
    
    // 主题设置
    var themeColor: String
    var useDarkMode: Bool
    var useSystemTheme: Bool
    
    // 背景设置
    var backgroundType: BackgroundType
    var customBackgroundColor: String
    var customBackgroundImageName: String?
    
    // API设置
    var apiKey: String?
    
    init(
        notificationsEnabled: Bool = false,
        notificationTime: Date = Calendar.current.date(from: DateComponents(hour: 8, minute: 0)) ?? Date(),
        themeColor: String = "blue",
        useDarkMode: Bool = false,
        useSystemTheme: Bool = true,
        backgroundType: BackgroundType = .color,
        customBackgroundColor: String = "system.background",
        customBackgroundImageName: String? = nil,
        apiKey: String? = nil
    ) {
        self.notificationsEnabled = notificationsEnabled
        self.notificationTime = notificationTime
        self.themeColor = themeColor
        self.useDarkMode = useDarkMode
        self.useSystemTheme = useSystemTheme
        self.backgroundType = backgroundType
        self.customBackgroundColor = customBackgroundColor
        self.customBackgroundImageName = customBackgroundImageName
        self.apiKey = apiKey
    }
}

// 确保BackgroundType符合Sendable协议
enum BackgroundType: String, Codable, Sendable {
    case color
    case image
    case gradient
}

// MARK: - 默认设置
extension UserSettings {
    static var defaultSettings: UserSettings {
        UserSettings()
    }
} 