//
//  FontBrowserView.swift
//  AIspiration
//
//  Created for AIspiration project
//

import SwiftUI
import UIKit

struct FontBrowserView: View {
    @Binding var selectedFont: String
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var systemFonts: [String] = []
    @State private var selectedFamily: String?
    @State private var familyFonts: [String] = []
    
    var body: some View {
        NavigationStack {
            VStack {
                // 搜索栏
                SearchBar(text: $searchText)
                    .padding(.horizontal)
                
                // 常用中文字体
                Section(header: Text("常用中文字体").font(.headline).padding(.horizontal)) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(Array(FontManager.shared.availableFonts.keys), id: \.self) { key in
                                FontPreviewButton(
                                    fontName: key,
                                    displayName: FontManager.shared.getDisplayName(for: key),
                                    isSelected: selectedFont == key,
                                    action: {
                                        selectedFont = key
                                        dismiss()
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                    }
                }
                
                Divider()
                
                // 所有系统字体
                List {
                    Section(header: Text("所有系统字体")) {
                        ForEach(filteredFonts, id: \.self) { family in
                            DisclosureGroup(family) {
                                let fonts = UIFont.fontNames(forFamilyName: family)
                                ForEach(fonts, id: \.self) { font in
                                    HStack {
                                        Text("示例文本")
                                            .font(.custom(font, size: 17))
                                        Spacer()
                                        Text(font)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        selectedFont = font
                                        dismiss()
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("选择字体")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                systemFonts = UIFont.familyNames.sorted()
            }
        }
    }
    
    // 过滤后的字体
    var filteredFonts: [String] {
        if searchText.isEmpty {
            return systemFonts
        } else {
            return systemFonts.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
}

// 搜索栏
struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("搜索字体", text: $text)
                .foregroundColor(.primary)
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

// 字体预览按钮
struct FontPreviewButton: View {
    let fontName: String
    let displayName: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        VStack {
            Text("永恒")
                .font(FontManager.shared.getFont(name: fontName, size: 20))
                .frame(width: 70, height: 70)
                .background(Color(.systemGray6))
                .foregroundColor(.primary)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.blue, lineWidth: isSelected ? 3 : 0)
                )
            
            Text(displayName)
                .font(.caption)
                .foregroundColor(.primary)
        }
        .onTapGesture(perform: action)
    }
}

#Preview {
    FontBrowserView(selectedFont: .constant("system"))
} 