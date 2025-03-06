//
//  NotificationService.swift
//  AIspiration
//
//  Created for AIspiration project
//

import Foundation
import UserNotifications
import SwiftUI

// 使NotificationService符合Sendable协议
class NotificationService: @unchecked Sendable {
    static let shared = NotificationService()
    
    private init() {}
    
    // 请求通知权限
    func requestAuthorization() async -> Bool {
        do {
            let options: UNAuthorizationOptions = [.alert, .sound, .badge]
            return try await UNUserNotificationCenter.current().requestAuthorization(options: options)
        } catch {
            print("通知授权请求失败: \(error.localizedDescription)")
            return false
        }
    }
    
    // 检查通知授权状态
    func checkAuthorizationStatus() async -> UNAuthorizationStatus {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus
    }
    
    // 设置每日通知
    func scheduleDailyNotification(at time: Date, enabled: Bool) {
        // 如果通知被禁用，则移除所有待处理的通知
        if !enabled {
            cancelAllPendingNotifications()
            return
        }
        
        // 获取时间组件
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)
        
        // 创建通知内容
        let content = UNMutableNotificationContent()
        content.title = "今日励志语录"
        content.body = "点击查看今天的励志语录，开启充满动力的一天！"
        content.sound = .default
        
        // 创建触发器（每天在指定时间触发）
        var trigger: UNNotificationTrigger
        if let hour = components.hour, let minute = components.minute {
            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = minute
            trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        } else {
            // 如果无法获取时间组件，则默认为每天早上8点
            var dateComponents = DateComponents()
            dateComponents.hour = 8
            dateComponents.minute = 0
            trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        }
        
        // 创建通知请求
        let request = UNNotificationRequest(
            identifier: "daily-quote",
            content: content,
            trigger: trigger
        )
        
        // 添加通知请求
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("添加通知请求失败: \(error.localizedDescription)")
            }
        }
    }
    
    // 发送即时通知
    func sendImmediateNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("发送即时通知失败: \(error.localizedDescription)")
            }
        }
    }
    
    // 取消所有待处理的通知
    func cancelAllPendingNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    // 更新通知设置
    func updateNotificationSettings(enabled: Bool, time: Date) {
        scheduleDailyNotification(at: time, enabled: enabled)
    }
}