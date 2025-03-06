//
//  QuoteViewModel.swift
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
class QuoteViewModel: ObservableObject, @unchecked Sendable {
    // 当前显示的语录
    @Published var currentQuote: Quote?
    
    // 生成语录的状态
    @Published var isGenerating = false
    @Published var errorMessage: String?
    @Published var showError = false
    
    // 选择的分类
    @Published var selectedCategory: String = "激励"
    
    // 选择的心情
    @Published var selectedMood: String?
    
    // 可用的分类
    @Published var availableCategories: [String] = ["激励", "成功", "生活", "智慧", "行动"]
    
    // 可用的心情
    @Published var availableMoods: [String] = ["积极", "平静", "反思", "坚定", "感恩"]
    
    // OpenAI服务
    private var openAIService: OpenAIService?
    
    // 数据服务
    private let dataService = DataService.shared
    
    // 初始化
    init(apiKey: String? = nil) {
        if let apiKey = apiKey, !apiKey.isEmpty {
            self.openAIService = OpenAIService(apiKey: apiKey)
        }
    }
    
    // 设置API密钥
    func setAPIKey(_ apiKey: String) {
        self.openAIService = OpenAIService(apiKey: apiKey)
    }
    
    // 提供一个安全的入口点，可以从@Sendable闭包中调用
    nonisolated func generateNewQuoteFromTask(modelContext: ModelContext) {
        performModelContextOperation({ context in
            Task {
                await self.generateNewQuote(modelContext: context)
            }
        }, with: modelContext)
    }
    
    // 生成新的语录
    func generateNewQuote(modelContext: ModelContext) async {
        guard !isGenerating else { return }
        
        isGenerating = true
        errorMessage = nil
        showError = false
        
        do {
            var quoteContent: String
            var quoteAuthor: String?
            
            if let openAIService = openAIService {
                // 使用OpenAI API生成语录
                let result = try await openAIService.generateQuote(
                    category: selectedCategory,
                    mood: selectedMood
                )
                quoteContent = result.content
                quoteAuthor = result.author
            } else {
                // 使用模拟数据
                let mockService = OpenAIService(apiKey: "mock")
                let result = mockService.generateMockQuote(
                    category: selectedCategory,
                    mood: selectedMood
                )
                quoteContent = result.content
                quoteAuthor = result.author
            }
            
            // 创建新的语录
            let newQuote = Quote(
                content: quoteContent,
                author: quoteAuthor,
                categoryName: selectedCategory
            )
            
            // 保存到数据库
            modelContext.insert(newQuote)
            try modelContext.save()
            
            // 由于使用了@MainActor，这里不需要DispatchQueue.main.async
            self.currentQuote = newQuote
            self.isGenerating = false
        } catch {
            // 由于使用了@MainActor，这里不需要DispatchQueue.main.async
            self.errorMessage = "生成语录失败: \(error.localizedDescription)"
            self.showError = true
            self.isGenerating = false
        }
    }
    
    // 提供一个安全的入口点，可以从@Sendable闭包中调用
    nonisolated func saveToFavoritesFromTask(quote: Quote, modelContext: ModelContext) {
        performModelContextOperation({ context in
            self.saveToFavorites(quote: quote, modelContext: context)
        }, with: modelContext)
    }
    
    // 保存语录到收藏
    func saveToFavorites(quote: Quote, modelContext: ModelContext) {
        quote.isFavorite = true
        dataService.updateQuote(modelContext: modelContext, quote: quote)
    }
    
    // 提供一个安全的入口点，可以从@Sendable闭包中调用
    nonisolated func removeFromFavoritesFromTask(quote: Quote, modelContext: ModelContext) {
        performModelContextOperation({ context in
            self.removeFromFavorites(quote: quote, modelContext: context)
        }, with: modelContext)
    }
    
    // 从收藏中移除
    func removeFromFavorites(quote: Quote, modelContext: ModelContext) {
        quote.isFavorite = false
        dataService.updateQuote(modelContext: modelContext, quote: quote)
    }
    
    // 删除语录
    func deleteQuote(quote: Quote, modelContext: ModelContext) {
        dataService.deleteQuote(modelContext: modelContext, quote: quote)
        
        // 如果删除的是当前显示的语录，则清空当前语录
        if currentQuote?.id == quote.id {
            currentQuote = nil
        }
    }
    
    // 更新语录分类
    func updateQuoteCategory(quote: Quote, categoryName: String, modelContext: ModelContext) {
        quote.categoryName = categoryName
        dataService.updateQuote(modelContext: modelContext, quote: quote)
    }
    
    // 更新语录样式
    func updateQuoteStyle(quote: Quote, backgroundColor: String, textColor: String, fontName: String, modelContext: ModelContext) {
        quote.backgroundColor = backgroundColor
        quote.textColor = textColor
        quote.fontName = fontName
        dataService.updateQuote(modelContext: modelContext, quote: quote)
    }
} 