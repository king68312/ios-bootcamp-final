import Foundation

class OpenAIClient {
    static let shared = OpenAIClient()

    private let apiURL = "https://api.openai.com/v1/chat/completions"

    // ここにAPIキーを入力してください
    private let apiKey = "YOUR_API_KEY_HERE"

    private init() {}

    func generateReading(card: TarotCard, category: String) async -> String {
        // APIキーが未設定の場合はデフォルト結果を返す
        if apiKey.isEmpty || apiKey == "YOUR_API_KEY_HERE" {
            return generateDefaultReading(card: card, category: category)
        }

        let prompt = """
        あなたはタロット占い師です。
        カード「\(card.name)」が出ました。
        カテゴリは「\(category)」です。
        このカードの意味を元に、優しく前向きな占い結果を
        3〜4文で生成してください。
        """

        let requestBody: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "user", "content": prompt]
            ],
            "max_tokens": 300,
            "temperature": 0.7
        ]

        do {
            guard let url = URL(string: apiURL) else {
                return generateDefaultReading(card: card, category: category)
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                return generateDefaultReading(card: card, category: category)
            }

            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            if let choices = json?["choices"] as? [[String: Any]],
               let firstChoice = choices.first,
               let message = firstChoice["message"] as? [String: Any],
               let content = message["content"] as? String {
                return content.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        } catch {
            // エラー時はデフォルト結果を返す
        }

        return generateDefaultReading(card: card, category: category)
    }

    private func generateDefaultReading(card: TarotCard, category: String) -> String {
        let readings: [String: [String]] = [
            "恋愛": [
                "あなたの恋愛運に素晴らしい波が訪れています。心を開いて、新しい出会いを受け入れる準備をしましょう。大切な人との絆がより深まる時期です。"
            ],
            "仕事": [
                "仕事面で新しいチャンスが巡ってきそうです。あなたの努力が認められる時期が近づいています。自信を持って前に進んでください。"
            ],
            "金運": [
                "金運が上昇傾向にあります。計画的な行動が実を結ぶ時期です。思わぬ臨時収入の可能性も。"
            ],
            "健康": [
                "心身のバランスを整えることが大切です。規則正しい生活を心がけましょう。リフレッシュする時間を作ってください。"
            ],
            "総合運": [
                "全体的に良い運気が流れています。直感を信じて行動すると良い結果につながります。周りの人との調和を大切にしましょう。"
            ]
        ]

        let categoryReading = readings[category]?.first ?? readings["総合運"]!.first!

        return """
        \(card.name)のカードが示すのは「\(card.meaning)」です。

        \(categoryReading)

        このカードはあなたに前向きなメッセージを伝えています。自分を信じて進んでいきましょう。
        """
    }
}
