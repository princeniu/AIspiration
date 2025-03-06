//
//  ModelContextExtension.swift
//  AIspiration
//
//  Created for AIspiration project
//

import Foundation
import SwiftData

// 不再直接扩展 ModelContext 使其符合 Sendable 协议
// 而是创建一个线程安全的包装器

/// 一个线程安全的 ModelContext 包装器，用于在异步上下文中安全地使用 ModelContext
@MainActor
class SafeModelContext {
    private let modelContext: ModelContext
    
    init(_ modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func insert(_ model: any PersistentModel) {
        modelContext.insert(model)
    }
    
    func delete(_ model: any PersistentModel) {
        modelContext.delete(model)
    }
    
    func save() throws {
        try modelContext.save()
    }
    
    // 添加其他需要的 ModelContext 方法...
}

// 为 QuoteViewModel 和 SettingsViewModel 提供扩展方法
extension QuoteViewModel {
    // 安全地从任何上下文调用 ModelContext 操作
    nonisolated func performModelContextOperation(_ operation: @escaping @MainActor (ModelContext) -> Void, with modelContext: ModelContext) {
        Task { @MainActor in
            operation(modelContext)
        }
    }
}

extension SettingsViewModel {
    // 安全地从任何上下文调用 ModelContext 操作
    nonisolated func performModelContextOperation(_ operation: @escaping @MainActor (ModelContext) -> Void, with modelContext: ModelContext) {
        Task { @MainActor in
            operation(modelContext)
        }
    }
} 