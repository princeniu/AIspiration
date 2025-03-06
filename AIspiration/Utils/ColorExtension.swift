//
//  ColorExtension.swift
//  AIspiration
//
//  Created for AIspiration project
//

import SwiftUI

extension Color {
    // 从字符串创建颜色
    static func fromString(_ colorString: String) -> Color {
        switch colorString.lowercased() {
        case "red":
            return .red
        case "orange":
            return .orange
        case "yellow":
            return .yellow
        case "green":
            return .green
        case "mint":
            return .mint
        case "teal":
            return .teal
        case "cyan":
            return .cyan
        case "blue":
            return .blue
        case "indigo":
            return .indigo
        case "purple":
            return .purple
        case "pink":
            return .pink
        case "brown":
            return .brown
        case "gray":
            return .gray
        case "black":
            return .black
        case "white":
            return .white
        case "system.background":
            return Color(.systemBackground)
        case "system.label":
            return Color(.label)
        default:
            // 尝试从十六进制字符串创建颜色
            if colorString.hasPrefix("#") {
                return hexStringToColor(hex: colorString)
            }
            return .blue // 默认颜色
        }
    }
    
    // 从十六进制字符串创建颜色
    static func hexStringToColor(hex: String) -> Color {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red = Double((rgb & 0xFF0000) >> 16) / 255.0
        let green = Double((rgb & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgb & 0x0000FF) / 255.0
        
        return Color(red: red, green: green, blue: blue)
    }
    
    // 将颜色转换为字符串
    func toString() -> String {
        // 这里简化处理，实际应用中可能需要更复杂的逻辑
        if self == .red { return "red" }
        if self == .orange { return "orange" }
        if self == .yellow { return "yellow" }
        if self == .green { return "green" }
        if self == .mint { return "mint" }
        if self == .teal { return "teal" }
        if self == .cyan { return "cyan" }
        if self == .blue { return "blue" }
        if self == .indigo { return "indigo" }
        if self == .purple { return "purple" }
        if self == .pink { return "pink" }
        if self == .brown { return "brown" }
        if self == .gray { return "gray" }
        if self == .black { return "black" }
        if self == .white { return "white" }
        
        // 默认返回蓝色
        return "blue"
    }
}

// 预定义的主题颜色
struct ThemeColors {
    static let themeColors: [String: Color] = [
        "red": .red,
        "orange": .orange,
        "yellow": .yellow,
        "green": .green,
        "mint": .mint,
        "teal": .teal,
        "cyan": .cyan,
        "blue": .blue,
        "indigo": .indigo,
        "purple": .purple,
        "pink": .pink
    ]
    
    static let themeColorNames: [String] = [
        "red", "orange", "yellow", "green", "mint", 
        "teal", "cyan", "blue", "indigo", "purple", "pink"
    ]
}

// 渐变主题
struct GradientTheme {
    let colors: [Color]
    let name: String
    
    static let themes: [GradientTheme] = [
        GradientTheme(colors: [.blue, .purple], name: "蓝紫渐变"),
        GradientTheme(colors: [.orange, .red], name: "橙红渐变"),
        GradientTheme(colors: [.green, .blue], name: "绿蓝渐变"),
        GradientTheme(colors: [.purple, .pink], name: "紫粉渐变"),
        GradientTheme(colors: [.yellow, .orange], name: "黄橙渐变"),
        GradientTheme(colors: [.mint, .teal], name: "薄荷渐变")
    ]
} 