//
//  Quote.swift
//  AIspiration
//
//  Created for AIspiration project
//

import Foundation
import SwiftData

// 使Quote模型符合Sendable协议
@Model
final class Quote: @unchecked Sendable {
    @Attribute(.unique) var id: UUID
    var content: String
    var author: String?
    var categoryName: String
    var createdAt: Date
    var isFavorite: Bool
    var backgroundColor: String
    var textColor: String
    var fontName: String
    
    // 让SwiftData自动推断关系
    var category: Category?
    
    init(
        id: UUID = UUID(),
        content: String,
        author: String? = nil,
        categoryName: String = "未分类",
        createdAt: Date = Date(),
        isFavorite: Bool = false,
        backgroundColor: String = "system.background",
        textColor: String = "system.label",
        fontName: String = "system",
        category: Category? = nil
    ) {
        self.id = id
        self.content = content
        self.author = author
        self.categoryName = categoryName
        self.createdAt = createdAt
        self.isFavorite = isFavorite
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.fontName = fontName
        self.category = category
    }
}

// MARK: - 示例数据
extension Quote {
    static var sampleQuotes: [Quote] {
        [
            Quote(content: "成功不是偶然的，而是来自于正确的决定、努力工作和坚持不懈。", author: "未知", categoryName: "成功"),
            Quote(content: "每一个不曾起舞的日子，都是对生命的辜负。", author: "尼采", categoryName: "生活"),
            Quote(content: "不要等待机会，而要创造机会。", author: "未知", categoryName: "行动"),
            Quote(content: "生活中最重要的不是我们身处何处，而是我们朝什么方向前进。", author: "霍姆斯", categoryName: "方向"),
            Quote(content: "成功的秘诀在于坚持自己的目标并不断努力。", author: "未知", categoryName: "成功")
        ]
    }
} 