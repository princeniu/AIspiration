//
//  QuoteCardView.swift
//  AIspiration
//
//  Created for AIspiration project
//

import SwiftUI
import SwiftData

struct QuoteCardView: View {
    let quote: Quote
    @State private var showingCustomizeSheet = false
    @State private var backgroundColor: Color
    @State private var textColor: Color
    @State private var fontName: String
    
    init(quote: Quote) {
        self.quote = quote
        self._backgroundColor = State(initialValue: Color.fromString(quote.backgroundColor))
        self._textColor = State(initialValue: Color.fromString(quote.textColor))
        self._fontName = State(initialValue: quote.fontName)
    }
    
    var body: some View {
        ZStack {
            // 背景
            RoundedRectangle(cornerRadius: 20)
                .fill(backgroundColor)
                .shadow(radius: 5)
            
            // 内容
            VStack(spacing: 20) {
                // 语录内容
                Text("\"\(quote.content)\"")
                    .font(FontManager.shared.getFont(name: fontName, size: 24))
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .foregroundColor(textColor)
                    .padding(.horizontal)
                
                // 作者
                if let author = quote.author, !author.isEmpty {
                    Text("—— \(author)")
                        .font(FontManager.shared.getFont(name: fontName, size: 18))
                        .fontWeight(.regular)
                        .foregroundColor(textColor.opacity(0.8))
                        .padding(.top, 5)
                }
                
                // 分类标签
                Text(quote.categoryName)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(textColor.opacity(0.1))
                    .foregroundColor(textColor)
                    .cornerRadius(15)
                    .padding(.top, 5)
            }
            .padding(.vertical, 30)
            .padding(.horizontal, 20)
            
            // 自定义按钮
            VStack {
                HStack {
                    Spacer()
                    
                    Button(action: {
                        showingCustomizeSheet = true
                    }) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 18))
                            .foregroundColor(textColor.opacity(0.7))
                            .padding(10)
                            .background(backgroundColor.opacity(0.8))
                            .clipShape(Circle())
                            .shadow(radius: 2)
                    }
                    .padding(12)
                }
                
                Spacer()
            }
        }
        .frame(height: 350)
        .sheet(isPresented: $showingCustomizeSheet) {
            QuoteCustomizeView(
                backgroundColor: $backgroundColor,
                textColor: $textColor,
                fontName: $fontName,
                quote: quote
            )
            .presentationDetents([.medium, .large])
        }
    }
    
    // 获取字体
    private func getFont(size: CGFloat) -> Font {
        FontManager.shared.getFont(name: fontName, size: size)
    }
}

// 语录自定义视图
struct QuoteCustomizeView: View {
    @Binding var backgroundColor: Color
    @Binding var textColor: Color
    @Binding var fontName: String
    let quote: Quote
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var showingFontBrowser = false
    
    // 可用的颜色
    let availableColors: [Color] = [
        .white, .black, .blue, .red, .green, .orange, .yellow, .purple, .pink, .mint, .teal, .indigo
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                // 背景颜色选择
                Section(header: Text("背景颜色")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(availableColors, id: \.self) { color in
                                Circle()
                                    .fill(color)
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.primary, lineWidth: backgroundColor == color ? 3 : 0)
                                    )
                                    .onTapGesture {
                                        backgroundColor = color
                                    }
                            }
                        }
                        .padding(.vertical, 10)
                    }
                }
                
                // 文字颜色选择
                Section(header: Text("文字颜色")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(availableColors, id: \.self) { color in
                                Circle()
                                    .fill(color)
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.primary, lineWidth: textColor == color ? 3 : 0)
                                    )
                                    .onTapGesture {
                                        textColor = color
                                    }
                            }
                        }
                        .padding(.vertical, 10)
                    }
                }
                
                // 字体选择
                Section(header: HStack {
                    Text("字体")
                    Spacer()
                    Button("更多字体") {
                        showingFontBrowser = true
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(Array(FontManager.shared.availableFonts.keys), id: \.self) { key in
                                VStack {
                                    Text("永恒")
                                        .font(FontManager.shared.getFont(name: key, size: 20))
                                        .frame(width: 60, height: 60)
                                        .background(backgroundColor.opacity(0.3))
                                        .foregroundColor(textColor)
                                        .cornerRadius(10)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color.blue, lineWidth: fontName == key ? 3 : 0)
                                        )
                                    
                                    Text(FontManager.shared.getDisplayName(for: key))
                                        .font(.caption)
                                        .foregroundColor(.primary)
                                }
                                .onTapGesture {
                                    fontName = key
                                }
                            }
                        }
                        .padding(.vertical, 10)
                    }
                }
                
                // 预览
                Section(header: Text("预览")) {
                    VStack(spacing: 15) {
                        Text("\"\(quote.content)\"")
                            .font(FontManager.shared.getFont(name: fontName, size: 18))
                            .multilineTextAlignment(.center)
                            .foregroundColor(textColor)
                        
                        if let author = quote.author, !author.isEmpty {
                            Text("—— \(author)")
                                .font(FontManager.shared.getFont(name: fontName, size: 14))
                                .foregroundColor(textColor.opacity(0.8))
                        }
                        
                        // 显示当前字体名称
                        Text("当前字体: \(FontManager.shared.getDisplayName(for: fontName))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 5)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(backgroundColor)
                    .cornerRadius(15)
                }
            }
            .navigationTitle("自定义样式")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        // 恢复原始值
                        backgroundColor = Color.fromString(quote.backgroundColor)
                        textColor = Color.fromString(quote.textColor)
                        fontName = quote.fontName
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        // 保存更改
                        saveChanges()
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingFontBrowser) {
                FontBrowserView(selectedFont: $fontName)
            }
        }
    }
    
    // 获取字体
    private func getFont(size: CGFloat) -> Font {
        FontManager.shared.getFont(name: fontName, size: size)
    }
    
    // 保存更改
    private func saveChanges() {
        quote.backgroundColor = backgroundColor.toString()
        quote.textColor = textColor.toString()
        quote.fontName = fontName
        
        do {
            try modelContext.save()
        } catch {
            print("保存样式更改失败: \(error.localizedDescription)")
        }
    }
}

#Preview {
    QuoteCardView(quote: Quote.sampleQuotes[0])
        .padding()
        .modelContainer(for: [Quote.self, Category.self], inMemory: true)
} 