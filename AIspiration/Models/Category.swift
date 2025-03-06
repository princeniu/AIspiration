//
//  Category.swift
//  AIspiration
//
//  Created for AIspiration project
//

import Foundation
import SwiftData

// 使Category模型符合Sendable协议
@Model
final class Category: @unchecked Sendable {
    @Attribute(.unique) var id: UUID
    var name: String
    var iconName: String
    var color: String
    var createdAt: Date
    
    // 让SwiftData自动推断关系
    var quotes: [Quote]?
    
    init(
        id: UUID = UUID(),
        name: String,
        iconName: String = "quote.bubble",
        color: String = "blue",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.iconName = iconName
        self.color = color
        self.createdAt = createdAt
    }
}

// MARK: - 默认分类
extension Category {
    static var defaultCategories: [Category] {
        [
            Category(name: "激励", iconName: "flame", color: "orange"),
            Category(name: "成功", iconName: "trophy", color: "yellow"),
            Category(name: "生活", iconName: "heart", color: "pink"),
            Category(name: "智慧", iconName: "lightbulb", color: "purple"),
            Category(name: "行动", iconName: "figure.run", color: "green")
        ]
    }
} 