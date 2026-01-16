import SwiftUI

struct HistoryView: View {
    @Environment(FortuneHistoryManager.self) var historyManager

    var body: some View {
        NavigationStack {
            Group {
                if historyManager.history.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "clock")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.5))
                        Text("まだ占い履歴がありません")
                            .foregroundColor(.secondary)
                        Text("ホーム画面から占いを始めてみましょう")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } else {
                    List {
                        ForEach(historyManager.history) { result in
                            NavigationLink(destination: HistoryDetailView(result: result)) {
                                HistoryRowView(result: result)
                            }
                        }
                        .onDelete(perform: historyManager.deleteResult)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("履歴")
            #if os(iOS)
            .toolbar {
                if !historyManager.history.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            historyManager.clearHistory()
                        }) {
                            Text("全削除")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            #endif
        }
    }
}

struct HistoryRowView: View {
    let result: FortuneResult

    var body: some View {
        HStack(spacing: 12) {
            Text(result.card.emoji)
                .font(.system(size: 40))

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(result.card.name)
                        .font(.headline)

                    Text(result.category)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.purple.opacity(0.2))
                        .cornerRadius(4)
                }

                Text(result.formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    HistoryView()
        .environment(FortuneHistoryManager())
}
