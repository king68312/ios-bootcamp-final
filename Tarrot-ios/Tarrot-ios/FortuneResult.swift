import Foundation
import SwiftUI

struct FortuneResult: Codable, Identifiable {
    let id: UUID
    let card: TarotCard
    let category: String
    let aiReading: String
    let date: Date

    init(card: TarotCard, category: String, aiReading: String) {
        self.id = UUID()
        self.card = card
        self.category = category
        self.aiReading = aiReading
        self.date = Date()
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter.string(from: date)
    }
}

@Observable
class FortuneHistoryManager {
    var history: [FortuneResult] = []

    private let userDefaultsKey = "fortuneHistory"

    init() {
        loadHistory()
    }

    func saveResult(_ result: FortuneResult) {
        history.insert(result, at: 0)
        saveHistory()
    }

    func deleteResult(at offsets: IndexSet) {
        history.remove(atOffsets: offsets)
        saveHistory()
    }

    func clearHistory() {
        history.removeAll()
        saveHistory()
    }

    private func loadHistory() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else { return }

        do {
            let decoder = JSONDecoder()
            history = try decoder.decode([FortuneResult].self, from: data)
        } catch {
            print("履歴の読み込みに失敗しました: \(error)")
        }
    }

    private func saveHistory() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(history)
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        } catch {
            print("履歴の保存に失敗しました: \(error)")
        }
    }
}
