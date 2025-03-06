//
//  HomeView.swift
//  AIspiration
//
//  Created for AIspiration project
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var quoteViewModel = QuoteViewModel()
    @State private var showingCategoryPicker = false
    @State private var showingMoodPicker = false
    @State private var showingShareSheet = false
    @State private var showingSettings = false
    @State private var showingFavorites = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 背景
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                VStack {
                    // 顶部控制栏
                    HStack {
                        Button(action: {
                            showingSettings = true
                        }) {
                            Image(systemName: "gear")
                                .font(.title2)
                                .foregroundColor(.primary)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            showingFavorites = true
                        }) {
                            Image(systemName: "heart.fill")
                                .font(.title2)
                                .foregroundColor(.red)
                        }
                    }
                    .padding()
                    
                    Spacer()
                    
                    // 语录显示区域
                    if let quote = quoteViewModel.currentQuote {
                        QuoteCardView(quote: quote)
                            .padding()
                    } else {
                        VStack(spacing: 20) {
                            Image(systemName: "quote.bubble")
                                .font(.system(size: 60))
                                .foregroundColor(.secondary)
                            
                            Text("点击下方按钮生成励志语录")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                    }
                    
                    Spacer()
                    
                    // 底部控制栏
                    VStack(spacing: 16) {
                        // 分类和心情选择
                        HStack(spacing: 20) {
                            // 分类选择
                            Button(action: {
                                showingCategoryPicker = true
                            }) {
                                HStack {
                                    Image(systemName: "folder")
                                    Text(quoteViewModel.selectedCategory)
                                    Image(systemName: "chevron.down")
                                        .font(.caption)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color(.systemGray6))
                                .cornerRadius(20)
                            }
                            
                            // 心情选择
                            Button(action: {
                                showingMoodPicker = true
                            }) {
                                HStack {
                                    Image(systemName: "face.smiling")
                                    Text(quoteViewModel.selectedMood ?? "选择心情")
                                    Image(systemName: "chevron.down")
                                        .font(.caption)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color(.systemGray6))
                                .cornerRadius(20)
                            }
                        }
                        
                        // 生成按钮
                        Button(action: {
                            quoteViewModel.generateNewQuoteFromTask(modelContext: modelContext)
                        }) {
                            HStack {
                                if quoteViewModel.isGenerating {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle())
                                        .tint(.white)
                                } else {
                                    Image(systemName: "sparkles")
                                }
                                
                                Text(quoteViewModel.isGenerating ? "生成中..." : "生成励志语录")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                            .shadow(radius: 2)
                        }
                        .disabled(quoteViewModel.isGenerating)
                        
                        // 分享和收藏按钮
                        if let quote = quoteViewModel.currentQuote {
                            HStack(spacing: 30) {
                                // 收藏按钮
                                Button(action: {
                                    if quote.isFavorite {
                                        quoteViewModel.removeFromFavoritesFromTask(quote: quote, modelContext: modelContext)
                                    } else {
                                        quoteViewModel.saveToFavoritesFromTask(quote: quote, modelContext: modelContext)
                                    }
                                }) {
                                    VStack(spacing: 5) {
                                        Image(systemName: quote.isFavorite ? "heart.fill" : "heart")
                                            .font(.title2)
                                            .foregroundColor(quote.isFavorite ? .red : .primary)
                                        
                                        Text(quote.isFavorite ? "已收藏" : "收藏")
                                            .font(.caption)
                                            .foregroundColor(.primary)
                                    }
                                    .frame(width: 60, height: 60)
                                }
                                
                                // 复制按钮
                                Button(action: {
                                    let textToCopy = quote.author != nil ? "\"\(quote.content)\" —— \(quote.author!)" : "\"\(quote.content)\""
                                    ShareManager.shared.copyToClipboard(textToCopy)
                                }) {
                                    VStack(spacing: 5) {
                                        Image(systemName: "doc.on.doc")
                                            .font(.title2)
                                            .foregroundColor(.primary)
                                        
                                        Text("复制")
                                            .font(.caption)
                                            .foregroundColor(.primary)
                                    }
                                    .frame(width: 60, height: 60)
                                }
                                
                                // 分享按钮
                                Button(action: {
                                    showingShareSheet = true
                                }) {
                                    VStack(spacing: 5) {
                                        Image(systemName: "square.and.arrow.up")
                                            .font(.title2)
                                            .foregroundColor(.primary)
                                        
                                        Text("分享")
                                            .font(.caption)
                                            .foregroundColor(.primary)
                                    }
                                    .frame(width: 60, height: 60)
                                }
                            }
                            .padding(.top, 8)
                        }
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingCategoryPicker) {
                CategoryPickerView(
                    selectedCategory: $quoteViewModel.selectedCategory,
                    categories: quoteViewModel.availableCategories
                )
                .presentationDetents([.medium])
            }
            .sheet(isPresented: $showingMoodPicker) {
                MoodPickerView(
                    selectedMood: $quoteViewModel.selectedMood,
                    moods: quoteViewModel.availableMoods
                )
                .presentationDetents([.medium])
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingFavorites) {
                FavoritesView()
            }
            .alert("错误", isPresented: $quoteViewModel.showError) {
                Button("确定", role: .cancel) {}
            } message: {
                Text(quoteViewModel.errorMessage ?? "发生未知错误")
            }
            .onAppear {
                // 加载API密钥
                let dataService = DataService.shared
                if let settings = dataService.getUserSettings(modelContext: modelContext),
                   let apiKey = settings.apiKey, !apiKey.isEmpty {
                    quoteViewModel.setAPIKey(apiKey)
                }
            }
        }
    }
}

// 分类选择器视图
struct CategoryPickerView: View {
    @Binding var selectedCategory: String
    let categories: [String]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(categories, id: \.self) { category in
                    Button(action: {
                        selectedCategory = category
                        dismiss()
                    }) {
                        HStack {
                            Text(category)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            if selectedCategory == category {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("选择分类")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// 心情选择器视图
struct MoodPickerView: View {
    @Binding var selectedMood: String?
    let moods: [String]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Button(action: {
                    selectedMood = nil
                    dismiss()
                }) {
                    HStack {
                        Text("不指定")
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        if selectedMood == nil {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                ForEach(moods, id: \.self) { mood in
                    Button(action: {
                        selectedMood = mood
                        dismiss()
                    }) {
                        HStack {
                            Text(mood)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            if selectedMood == mood {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("选择心情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [Quote.self, Category.self, UserSettings.self], inMemory: true)
} 