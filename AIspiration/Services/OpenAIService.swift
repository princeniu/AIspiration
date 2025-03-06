//
//  OpenAIService.swift
//  AIspiration
//
//  Created for AIspiration project
//

import Foundation

// 使OpenAIService符合Sendable协议
class OpenAIService: @unchecked Sendable {
    private let apiURL = URL(string: "https://api.openai.com/v1/chat/completions")!
    private var apiKey: String
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    func generateQuote(category: String, mood: String? = nil) async throws -> (content: String, author: String?) {
        var prompt = "生成一句简短有力的励志语录"
        
        if !category.isEmpty {
            prompt += "，主题关于\(category)"
        }
        
        if let mood = mood, !mood.isEmpty {
            prompt += "，语调是\(mood)"
        }
        
        prompt += "。不要使用引号，不要添加额外的解释，直接给出语录内容和作者（如果有）。如果是名人名言，请标注作者；如果是原创，可以不标注作者。"
        
        let messages: [[String: Any]] = [
            ["role": "system", "content": "你是一个专业的励志语录生成器，擅长创作简短有力、富有哲理的励志语录。"],
            ["role": "user", "content": prompt]
        ]
        
        let requestBody: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": messages,
            "temperature": 0.7,
            "max_tokens": 100
        ]
        
        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.requestFailed
        }
        
        guard let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = jsonResponse["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw APIError.invalidResponse
        }
        
        // 解析返回的内容，分离语录和作者
        return parseQuoteAndAuthor(from: content)
    }
    
    private func parseQuoteAndAuthor(from content: String) -> (content: String, author: String?) {
        // 尝试查找常见的作者标记模式
        let patterns = [
            "——(.*?)$", // 中文破折号
            "-(.*?)$",  // 英文破折号
            "—(.*?)$",  // 另一种破折号
            "by (.*?)$", // 英文by
            "\\((.*?)\\)$" // 括号中的作者
        ]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: []),
               let match = regex.firstMatch(in: content, options: [], range: NSRange(location: 0, length: content.utf16.count)) {
                let authorRange = match.range(at: 1)
                if let authorRange = Range(authorRange, in: content) {
                    let author = String(content[authorRange]).trimmingCharacters(in: .whitespacesAndNewlines)
                    let quoteEndIndex = content.index(content.startIndex, offsetBy: match.range.location)
                    let quote = String(content[..<quoteEndIndex]).trimmingCharacters(in: .whitespacesAndNewlines)
                    return (quote, author.isEmpty ? nil : author)
                }
            }
        }
        
        // 如果没有找到作者标记，返回整个内容作为语录，没有作者
        return (content.trimmingCharacters(in: .whitespacesAndNewlines), nil)
    }
}

// 确保APIError符合Sendable协议
enum APIError: Error, Sendable {
    case requestFailed
    case invalidResponse
    case invalidAPIKey
}

// MARK: - 模拟响应（用于开发和测试）
extension OpenAIService {
    func generateMockQuote(category: String, mood: String? = nil) -> (content: String, author: String?) {
        let mockQuotes: [(content: String, author: String?)] = [
            ("人生就像骑自行车，要保持平衡就得不断前进。", "爱因斯坦"),
            ("成功不是最终的，失败也不是致命的，重要的是继续前进的勇气。", "丘吉尔"),
            ("不要等待机会，而要创造机会。", "林肯"),
            ("生活中最重要的不是我们身处何处，而是我们朝什么方向前进。", "霍姆斯"),
            ("成功的秘诀在于坚持自己的目标并不断努力。", nil),
            ("每一个不曾起舞的日子，都是对生命的辜负。", "尼采"),
            ("当你感到悲伤时，最好是去学些什么东西。学习会使你永远立于不败之地。", "居里夫人"),
            ("世上没有绝望的处境，只有对处境绝望的人。", nil),
            ("只有经历过地狱般的磨砺，才能炼出创造天堂的力量。", nil),
            ("没有口水与汗水，就没有成功的泪水。", nil)
        ]
        
        return mockQuotes.randomElement()!
    }
} 