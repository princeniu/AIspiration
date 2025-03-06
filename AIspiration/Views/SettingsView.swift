//
//  SettingsView.swift
//  AIspiration
//
//  Created for AIspiration project
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = SettingsViewModel()
    
    @State private var showingAPIKeyInput = false
    @State private var showingResetConfirmation = false
    @State private var showingAbout = false
    
    var body: some View {
        NavigationStack {
            Form {
                // 通知设置
                Section(header: Text("通知设置")) {
                    Toggle("每日语录通知", isOn: $viewModel.userSettings.notificationsEnabled)
                        .onChange(of: viewModel.userSettings.notificationsEnabled) { _, newValue in
                            viewModel.updateNotificationSettingsFromTask(
                                enabled: newValue,
                                time: viewModel.userSettings.notificationTime,
                                modelContext: modelContext
                            )
                        }
                    
                    if viewModel.userSettings.notificationsEnabled {
                        DatePicker("通知时间", selection: $viewModel.userSettings.notificationTime, displayedComponents: .hourAndMinute)
                            .onChange(of: viewModel.userSettings.notificationTime) { _, newValue in
                                viewModel.updateNotificationSettingsFromTask(
                                    enabled: viewModel.userSettings.notificationsEnabled,
                                    time: newValue,
                                    modelContext: modelContext
                                )
                            }
                    }
                }
                
                // 主题设置
                Section(header: Text("主题设置")) {
                    Toggle("使用系统主题", isOn: $viewModel.userSettings.useSystemTheme)
                        .onChange(of: viewModel.userSettings.useSystemTheme) { _, newValue in
                            viewModel.updateThemeSettings(
                                themeColor: viewModel.userSettings.themeColor,
                                useDarkMode: viewModel.userSettings.useDarkMode,
                                useSystemTheme: newValue,
                                modelContext: modelContext
                            )
                        }
                    
                    if !viewModel.userSettings.useSystemTheme {
                        Toggle("深色模式", isOn: $viewModel.userSettings.useDarkMode)
                            .onChange(of: viewModel.userSettings.useDarkMode) { _, newValue in
                                viewModel.updateThemeSettings(
                                    themeColor: viewModel.userSettings.themeColor,
                                    useDarkMode: newValue,
                                    useSystemTheme: viewModel.userSettings.useSystemTheme,
                                    modelContext: modelContext
                                )
                            }
                    }
                    
                    // 主题颜色选择
                    VStack(alignment: .leading) {
                        Text("主题颜色")
                            .padding(.bottom, 5)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(ThemeColors.themeColorNames, id: \.self) { colorName in
                                    if let color = ThemeColors.themeColors[colorName] {
                                        Circle()
                                            .fill(color)
                                            .frame(width: 40, height: 40)
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.primary, lineWidth: viewModel.userSettings.themeColor == colorName ? 3 : 0)
                                            )
                                            .onTapGesture {
                                                viewModel.userSettings.themeColor = colorName
                                                viewModel.updateThemeSettings(
                                                    themeColor: colorName,
                                                    useDarkMode: viewModel.userSettings.useDarkMode,
                                                    useSystemTheme: viewModel.userSettings.useSystemTheme,
                                                    modelContext: modelContext
                                                )
                                            }
                                    }
                                }
                            }
                            .padding(.vertical, 5)
                        }
                    }
                }
                
                // API设置
                Section(header: Text("API设置")) {
                    Button(action: {
                        showingAPIKeyInput = true
                    }) {
                        HStack {
                            Text("OpenAI API密钥")
                            Spacer()
                            Text(viewModel.userSettings.apiKey != nil && !viewModel.userSettings.apiKey!.isEmpty ? "已设置" : "未设置")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // 关于和帮助
                Section(header: Text("关于和帮助")) {
                    Button(action: {
                        showingAbout = true
                    }) {
                        Text("关于AIspiration")
                    }
                    
                    Link("访问官方网站", destination: URL(string: "https://example.com")!)
                    
                    Link("联系我们", destination: URL(string: "mailto:support@example.com")!)
                }
                
                // 重置设置
                Section {
                    Button(action: {
                        showingResetConfirmation = true
                    }) {
                        Text("重置所有设置")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
            .alert("重置设置", isPresented: $showingResetConfirmation) {
                Button("取消", role: .cancel) {}
                Button("重置", role: .destructive) {
                    viewModel.resetAllSettings(modelContext: modelContext)
                }
            } message: {
                Text("确定要重置所有设置吗？这将恢复所有设置为默认值，但不会删除您的收藏语录。")
            }
            .sheet(isPresented: $showingAPIKeyInput) {
                APIKeyInputView(
                    apiKey: viewModel.userSettings.apiKey ?? "",
                    onSave: { newKey in
                        viewModel.updateAPIKey(apiKey: newKey, modelContext: modelContext)
                    }
                )
            }
            .sheet(isPresented: $showingAbout) {
                AboutView()
            }
            .onAppear {
                viewModel.loadSettings(modelContext: modelContext)
            }
        }
    }
}

// API密钥输入视图
struct APIKeyInputView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var apiKey: String
    let onSave: (String) -> Void
    
    init(apiKey: String, onSave: @escaping (String) -> Void) {
        self._apiKey = State(initialValue: apiKey)
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("OpenAI API密钥")) {
                    TextField("输入API密钥", text: $apiKey)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                    
                    Text("您的API密钥将安全地存储在设备上，不会发送到其他地方。")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section(header: Text("如何获取API密钥")) {
                    Text("1. 访问OpenAI官网 (openai.com)")
                    Text("2. 登录您的账户")
                    Text("3. 进入API部分")
                    Text("4. 创建新的API密钥")
                    Text("5. 复制并粘贴到上方输入框")
                }
            }
            .navigationTitle("API密钥设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        onSave(apiKey)
                        dismiss()
                    }
                }
            }
        }
    }
}

// 关于视图
struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 应用图标
                    Image(systemName: "quote.bubble.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                        .padding()
                    
                    // 应用名称和版本
                    Text("AIspiration")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("版本 1.0.0")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    // 应用描述
                    Text("AIspiration是一款利用人工智能生成励志语录的应用，帮助您获取日常所需的灵感和动力。")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.top)
                    
                    // 功能列表
                    VStack(alignment: .leading, spacing: 10) {
                        FeatureRow(icon: "sparkles", title: "AI生成语录", description: "使用OpenAI GPT-4o Mini API生成个性化的励志语录")
                        FeatureRow(icon: "heart.fill", title: "收藏与分类", description: "保存喜欢的语录并进行分类管理")
                        FeatureRow(icon: "square.and.arrow.up", title: "分享功能", description: "轻松分享语录到社交媒体或复制到剪贴板")
                        FeatureRow(icon: "paintpalette", title: "主题定制", description: "自定义背景和主题颜色或图片")
                        FeatureRow(icon: "bell.fill", title: "每日通知", description: "在设定的时间发送每日励志语录推送通知")
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(15)
                    .padding(.horizontal)
                    
                    // 版权信息
                    Text("© 2025 AIspiration Team. 保留所有权利。")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 30)
                }
                .padding()
            }
            .navigationTitle("关于")
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

// 功能行
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [Quote.self, Category.self, UserSettings.self], inMemory: true)
} 