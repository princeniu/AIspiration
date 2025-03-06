//
//  DataService.swift
//  AIspiration
//
//  Created for AIspiration project
//

import Foundation
import SwiftData
import SwiftUI

// 使DataService符合Sendable协议
class DataService: @unchecked Sendable {
    static let shared = DataService()
    
    private init() {}
    
    // 添加新的语录
    func addQuote(modelContext: ModelContext, content: String, author: String?, categoryName: String, isFavorite: Bool = false) {
        let quote = Quote(
            content: content,
            author: author,
            categoryName: categoryName,
            isFavorite: isFavorite
        )
        
        modelContext.insert(quote)
        
        do {
            try modelContext.save()
        } catch {
            print("保存语录失败: \(error.localizedDescription)")
        }
    }
    
    // 更新语录
    func updateQuote(modelContext: ModelContext, quote: Quote) {
        do {
            try modelContext.save()
        } catch {
            print("更新语录失败: \(error.localizedDescription)")
        }
    }
    
    // 删除语录
    func deleteQuote(modelContext: ModelContext, quote: Quote) {
        modelContext.delete(quote)
        
        do {
            try modelContext.save()
        } catch {
            print("删除语录失败: \(error.localizedDescription)")
        }
    }
    
    // 添加新的分类
    func addCategory(modelContext: ModelContext, name: String, iconName: String, color: String) {
        let category = Category(name: name, iconName: iconName, color: color)
        modelContext.insert(category)
        
        do {
            try modelContext.save()
        } catch {
            print("保存分类失败: \(error.localizedDescription)")
        }
    }
    
    // 更新分类
    func updateCategory(modelContext: ModelContext, category: Category) {
        do {
            try modelContext.save()
        } catch {
            print("更新分类失败: \(error.localizedDescription)")
        }
    }
    
    // 删除分类
    func deleteCategory(modelContext: ModelContext, category: Category) {
        modelContext.delete(category)
        
        do {
            try modelContext.save()
        } catch {
            print("删除分类失败: \(error.localizedDescription)")
        }
    }
    
    // 初始化默认数据
    func initializeDefaultData(modelContext: ModelContext) {
        // 检查是否已经有数据
        let quotesDescriptor = FetchDescriptor<Quote>()
        let categoriesDescriptor = FetchDescriptor<Category>()
        let settingsDescriptor = FetchDescriptor<UserSettings>()
        
        do {
            let quotesCount = try modelContext.fetchCount(quotesDescriptor)
            let categoriesCount = try modelContext.fetchCount(categoriesDescriptor)
            let settingsCount = try modelContext.fetchCount(settingsDescriptor)
            
            // 如果没有数据，则添加默认数据
            if categoriesCount == 0 {
                for category in Category.defaultCategories {
                    modelContext.insert(category)
                }
            }
            
            if quotesCount == 0 {
                for quote in Quote.sampleQuotes {
                    modelContext.insert(quote)
                }
            }
            
            if settingsCount == 0 {
                modelContext.insert(UserSettings.defaultSettings)
            }
            
            try modelContext.save()
        } catch {
            print("初始化默认数据失败: \(error.localizedDescription)")
        }
    }
    
    // 获取用户设置
    func getUserSettings(modelContext: ModelContext) -> UserSettings? {
        let descriptor = FetchDescriptor<UserSettings>()
        
        do {
            let settings = try modelContext.fetch(descriptor)
            return settings.first
        } catch {
            print("获取用户设置失败: \(error.localizedDescription)")
            return nil
        }
    }
    
    // 更新用户设置
    func updateUserSettings(modelContext: ModelContext, settings: UserSettings) {
        do {
            try modelContext.save()
        } catch {
            print("更新用户设置失败: \(error.localizedDescription)")
        }
    }
} 