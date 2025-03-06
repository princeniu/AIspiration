//
//  ShareManager.swift
//  AIspiration
//
//  Created for AIspiration project
//

import Foundation
import SwiftUI
import UIKit

class ShareManager {
    static let shared = ShareManager()
    
    private init() {}
    
    // 分享文本
    func shareText(_ text: String, from view: UIView) {
        let activityViewController = UIActivityViewController(
            activityItems: [text],
            applicationActivities: nil
        )
        
        // 在iPad上需要设置弹出位置
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceView = view
            popoverController.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        // 获取当前的UIWindow场景
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityViewController, animated: true)
        }
    }
    
    // 分享图片
    func shareImage(_ image: UIImage, from view: UIView) {
        let activityViewController = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        
        // 在iPad上需要设置弹出位置
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceView = view
            popoverController.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        // 获取当前的UIWindow场景
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityViewController, animated: true)
        }
    }
    
    // 分享文本和图片
    func shareTextAndImage(_ text: String, image: UIImage, from view: UIView) {
        let activityViewController = UIActivityViewController(
            activityItems: [text, image],
            applicationActivities: nil
        )
        
        // 在iPad上需要设置弹出位置
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceView = view
            popoverController.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        // 获取当前的UIWindow场景
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityViewController, animated: true)
        }
    }
    
    // 复制文本到剪贴板
    func copyToClipboard(_ text: String) {
        UIPasteboard.general.string = text
    }
    
    // 将视图转换为图片
    func renderViewToImage<T: View>(_ view: T) -> UIImage {
        let controller = UIHostingController(rootView: view)
        let view = controller.view
        
        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear
        
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
} 