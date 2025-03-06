//
//  ShareSheetView.swift
//  AIspiration
//
//  Created for AIspiration project
//

import SwiftUI
import UIKit

// ShareSheetView用于显示系统分享表单
struct ShareSheetView: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    var items: [Any]
    
    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if isPresented && uiViewController.presentedViewController == nil {
            let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
            activityVC.completionWithItemsHandler = { _, _, _, _ in
                isPresented = false
            }
            
            if let popover = activityVC.popoverPresentationController {
                popover.sourceView = uiViewController.view
                popover.sourceRect = CGRect(x: uiViewController.view.bounds.midX, y: uiViewController.view.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
            
            uiViewController.present(activityVC, animated: true)
        }
    }
} 