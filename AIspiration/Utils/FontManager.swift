//
//  FontManager.swift
//  AIspiration
//
//  Created for AIspiration project
//

import SwiftUI
import UIKit

// 字体管理器
class FontManager {
    static let shared = FontManager()
    
    // 可用的字体
    let availableFonts: [String: String] = [
        "system": "系统",
        "serif": "衬线",
        "rounded": "圆角",
        "monospaced": "等宽",
        "pingfang": "苹方",
        "songti": "宋体",
        "heiti": "黑体",
        "kaiti": "楷体",
        "yuanti": "圆体"
    ]
    
    // 获取系统所有字体名称
    func getAllSystemFonts() -> [String] {
        return UIFont.familyNames.sorted()
    }
    
    // 获取指定字体家族的所有字体
    func getFontsForFamily(_ family: String) -> [String] {
        return UIFont.fontNames(forFamilyName: family).sorted()
    }
    
    // 根据名称获取字体
    func getFont(name: String, size: CGFloat) -> Font {
        switch name {
        case "system":
            return .system(size: size)
        case "serif":
            return .system(size: size, design: .serif)
        case "rounded":
            return .system(size: size, design: .rounded)
        case "monospaced":
            return .system(size: size, design: .monospaced)
        case "pingfang":
            return .custom("PingFang SC", size: size)
        case "songti":
            return .custom("Songti SC", size: size)
        case "heiti":
            return .custom("Heiti SC", size: size)
        case "kaiti":
            return .custom("Kaiti SC", size: size)
        case "yuanti":
            return .custom("Yuanti SC", size: size)
        default:
            // 尝试直接使用字体名称
            return .custom(name, size: size)
        }
    }
    
    // 检查字体是否可用
    func isFontAvailable(_ fontName: String) -> Bool {
        if ["system", "serif", "rounded", "monospaced"].contains(fontName) {
            return true
        }
        
        // 检查中文字体
        switch fontName {
        case "pingfang":
            return UIFont(name: "PingFang SC", size: 12) != nil
        case "songti":
            return UIFont(name: "Songti SC", size: 12) != nil
        case "heiti":
            return UIFont(name: "Heiti SC", size: 12) != nil
        case "kaiti":
            return UIFont(name: "Kaiti SC", size: 12) != nil
        case "yuanti":
            return UIFont(name: "Yuanti SC", size: 12) != nil
        default:
            return UIFont(name: fontName, size: 12) != nil
        }
    }
    
    // 获取字体显示名称
    func getDisplayName(for fontName: String) -> String {
        return availableFonts[fontName] ?? fontName
    }
}

// 字体扩展
extension Font {
    static func custom(_ name: String, size: CGFloat, relativeTo textStyle: TextStyle? = nil) -> Font {
        if let style = textStyle {
            return .custom(name, size: size, relativeTo: style)
        } else {
            return .custom(name, size: size)
        }
    }
} 