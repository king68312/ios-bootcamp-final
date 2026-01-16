import SwiftUI

struct ResultView: View {
    let card: TarotCard
    let category: String
    @Environment(\.dismiss) private var dismiss
    @Environment(FortuneHistoryManager.self) var historyManager

    @State private var aiReading: String = ""
    @State private var isLoading: Bool = true
    @State private var hasSaved: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text(card.emoji)
                    .font(.system(size: 100))

                Text(card.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text(card.meaning)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Divider()
                    .padding(.vertical, 8)

                // AI解説セクション
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "sparkles")
                            .foregroundColor(.purple)
                        Text("AIからのメッセージ")
                            .font(.headline)
                    }

                    if isLoading {
                        HStack {
                            Spacer()
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                            Text("占い結果を生成中...")
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        .padding()
                    } else {
                        Text(aiReading)
                            .font(.body)
                            .lineSpacing(4)
                    }
                }
                .padding()
                .background(Color.purple.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)

                Spacer().frame(height: 20)

                // ボタン
                VStack(spacing: 12) {
                    Button(action: { dismiss() }) {
                        Text("もう一度占う")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.purple)
                            .cornerRadius(12)
                    }

                    Button(action: goToHome) {
                        Text("ホームに戻る")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(.purple)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.purple.opacity(0.1))
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
            }
            .padding()
        }
        .navigationTitle("\(category)の結果")
        .task {
            await fetchAIReading()
        }
    }

    private func fetchAIReading() async {
        do {
            let reading = try await OpenAIClient.shared.generateReading(card: card, category: category)
            await MainActor.run {
                aiReading = reading
                isLoading = false
                saveToHistory()
            }
        } catch {
            await MainActor.run {
                aiReading = "占い結果の生成中にエラーが発生しました。\n\n\(card.meaning)"
                isLoading = false
                saveToHistory()
            }
        }
    }

    private func saveToHistory() {
        guard !hasSaved else { return }
        hasSaved = true

        let result = FortuneResult(
            card: card,
            category: category,
            aiReading: aiReading
        )
        historyManager.saveResult(result)
    }

    private func goToHome() {
        // NavigationStackのルートに戻る
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootViewController = window.rootViewController {
            rootViewController.dismiss(animated: true)
        }
        // 複数回dismissを呼んでルートに戻る
        dismiss()
    }
}

// 履歴詳細表示用のビュー
struct HistoryDetailView: View {
    let result: FortuneResult

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text(result.card.emoji)
                    .font(.system(size: 100))

                Text(result.card.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text(result.formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(result.card.meaning)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Divider()
                    .padding(.vertical, 8)

                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "sparkles")
                            .foregroundColor(.purple)
                        Text("AIからのメッセージ")
                            .font(.headline)
                    }

                    Text(result.aiReading)
                        .font(.body)
                        .lineSpacing(4)
                }
                .padding()
                .background(Color.purple.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
            }
            .padding()
        }
        .navigationTitle("\(result.category)の結果")
    }
}

#Preview {
    NavigationStack {
        ResultView(card: .theSun, category: "恋愛")
            .environment(FortuneHistoryManager())
    }
}
