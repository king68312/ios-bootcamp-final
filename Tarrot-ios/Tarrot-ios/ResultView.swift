//占いの結果を表示
import SwiftUI

struct ResultView: View {
    let card: TarotCard
    let category: String
    var onGoHome: (() -> Void)?

    @Environment(\.dismiss) private var dismiss
    @Environment(FortuneHistoryManager.self) var historyManager: FortuneHistoryManager?

    @State private var aiReading: String = ""
    @State private var isLoading: Bool = true
    @State private var hasSaved: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text(card.emoji)
                    .font(.system(size: 70))

                Text(card.name)
                    .font(.title)
                    .fontWeight(.bold)

                Text(card.meaning)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Divider()
                    .padding(.vertical, 4)

                // AI解説セクション
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "sparkles")
                            .foregroundColor(.purple)
                        Text("AIからのメッセージ")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }

                    if isLoading {
                        HStack {
                            Spacer()
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                            Text("占い結果を生成中...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        .padding(.vertical, 8)
                    } else {
                        Text(aiReading)
                            .font(.subheadline)
                            .lineSpacing(3)
                    }
                }
                .padding(12)
                .background(Color.purple.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)

                // ボタン
                VStack(spacing: 10) {
                    Button(action: { dismiss() }) {
                        Text("もう一度占う")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity)
                            .background(Color.purple)
                            .cornerRadius(10)
                    }

                    Button(action: {
                        onGoHome?()
                    }) {
                        Text("ホームに戻る")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.purple)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity)
                            .background(Color.purple.opacity(0.1))
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
            .padding()
        }
        .navigationTitle("\(category)の結果")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await fetchAIReading()
        }
    }

    private func fetchAIReading() async {
        let reading = await OpenAIClient.shared.generateReading(card: card, category: category)
        aiReading = reading
        isLoading = false
        saveToHistory()
    }

    private func saveToHistory() {
        guard !hasSaved else { return }
        hasSaved = true

        let result = FortuneResult(
            card: card,
            category: category,
            aiReading: aiReading
        )
        historyManager?.saveResult(result)
    }
}

// 履歴詳細表示用のビュー
struct HistoryDetailView: View {
    let result: FortuneResult

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text(result.card.emoji)
                    .font(.system(size: 70))

                Text(result.card.name)
                    .font(.title)
                    .fontWeight(.bold)

                Text(result.formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(result.card.meaning)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Divider()
                    .padding(.vertical, 4)

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "sparkles")
                            .foregroundColor(.purple)
                        Text("AIからのメッセージ")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }

                    Text(result.aiReading)
                        .font(.subheadline)
                        .lineSpacing(3)
                }
                .padding(12)
                .background(Color.purple.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
            }
            .padding()
        }
        .navigationTitle("\(result.category)の結果")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ResultView(card: .theSun, category: "恋愛")
            .environment(FortuneHistoryManager())
    }
}
