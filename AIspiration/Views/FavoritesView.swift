//
//  FavoritesView.swift
//  AIspiration
//
//  Created for AIspiration project
//

import SwiftUI
import SwiftData
import UIKit

struct FavoritesView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(filter: #Predicate<Quote> { quote in
        quote.isFavorite == true
    }, sort: \Quote.createdAt, order: .reverse) private var favoriteQuotes: [Quote]
    
    @State private var selectedFilter: String = "全部"
    @State private var showingQuoteDetail = false
    @State private var selectedQuote: Quote?
    
    var body: some View {
        NavigationStack {
            VStack {
                // 分类筛选器
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        FilterButton(title: "全部", isSelected: selectedFilter == "全部") {
                            selectedFilter = "全部"
                        }
                        
                        // 获取所有不重复的分类
                        ForEach(Array(Set(favoriteQuotes.map { $0.categoryName })).sorted(), id: \.self) { category in
                            FilterButton(title: category, isSelected: selectedFilter == category) {
                                selectedFilter = category
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 5)
                }
                
                // 收藏列表
                if filteredQuotes.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "heart.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        
                        Text(selectedFilter == "全部" ? "暂无收藏的语录" : "该分类下暂无收藏的语录")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemGroupedBackground))
                } else {
                    List {
                        ForEach(filteredQuotes) { quote in
                            FavoriteQuoteRow(quote: quote)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedQuote = quote
                                    showingQuoteDetail = true
                                }
                        }
                        .onDelete(perform: deleteQuotes)
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("我的收藏")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingQuoteDetail) {
                if let quote = selectedQuote {
                    QuoteDetailView(quote: quote)
                }
            }
        }
    }
    
    // 根据筛选条件过滤语录
    private var filteredQuotes: [Quote] {
        if selectedFilter == "全部" {
            return favoriteQuotes
        } else {
            return favoriteQuotes.filter { $0.categoryName == selectedFilter }
        }
    }
    
    // 删除语录
    private func deleteQuotes(at offsets: IndexSet) {
        for index in offsets {
            let quote = filteredQuotes[index]
            modelContext.delete(quote)
        }
        
        do {
            try modelContext.save()
        } catch {
            print("删除语录失败: \(error.localizedDescription)")
        }
    }
}

// 筛选按钮
struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(.systemGray6))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

// 收藏语录行
struct FavoriteQuoteRow: View {
    let quote: Quote
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 语录内容
            Text("\"\(quote.content)\"")
                .font(.body)
                .fontWeight(.medium)
                .lineLimit(2)
            
            HStack {
                // 作者
                if let author = quote.author, !author.isEmpty {
                    Text("—— \(author)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // 分类标签
                Text(quote.categoryName)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
            }
            
            // 创建时间
            Text(quote.createdAt, style: .date)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 5)
    }
}

// 语录详情视图
struct QuoteDetailView: View {
    let quote: Quote
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var showingShareSheet = false
    @State private var shareImage: UIImage? = nil
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 30) {
                    // 语录卡片
                    QuoteCardView(quote: quote)
                        .padding(.horizontal)
                    
                    // 操作按钮
                    HStack(spacing: 40) {
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
                            // 渲染QuoteCardView为图片
                            let quoteView = QuoteCardView(quote: quote)
                                .frame(width: UIScreen.main.bounds.width - 40)
                            shareImage = ShareManager.shared.renderViewToImage(quoteView)
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
                        
                        // 从收藏中移除
                        Button(action: {
                            quote.isFavorite = false
                            
                            do {
                                try modelContext.save()
                                dismiss()
                            } catch {
                                print("从收藏中移除失败: \(error.localizedDescription)")
                            }
                        }) {
                            VStack(spacing: 5) {
                                Image(systemName: "heart.slash")
                                    .font(.title2)
                                    .foregroundColor(.primary)
                                
                                Text("取消收藏")
                                    .font(.caption)
                                    .foregroundColor(.primary)
                            }
                            .frame(width: 60, height: 60)
                        }
                    }
                    .padding()
                    
                    // 详细信息
                    VStack(alignment: .leading, spacing: 15) {
                        DetailRow(title: "创建时间", value: quote.createdAt.formatted(date: .long, time: .shortened))
                        DetailRow(title: "分类", value: quote.categoryName)
                        if let author = quote.author, !author.isEmpty {
                            DetailRow(title: "作者", value: author)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(15)
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("语录详情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
            .background(Color(.systemBackground))
            .onChange(of: showingShareSheet) { newValue in
                if !newValue {
                    // 重置分享图片
                    shareImage = nil
                }
            }
        }
        // 添加分享表单
        .background {
            ShareSheetView(isPresented: $showingShareSheet, items: [
                shareImage,
                quote.author != nil ? "\"\(quote.content)\" —— \(quote.author!)" : "\"\(quote.content)\""
            ].compactMap { $0 })
        }
    }
}


// 详情行
struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(width: 80, alignment: .leading)
            
            Text(value)
                .font(.subheadline)
            
            Spacer()
        }
    }
}

#Preview {
    FavoritesView()
        .modelContainer(for: [Quote.self, Category.self, UserSettings.self], inMemory: true)
} 