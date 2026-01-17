import SwiftUI

struct HomeView: View {
    @State private var greetingMessage: String = ""
    @State private var navigationPath = NavigationPath()

    private let greetingMessages = [
        "今日は何を占いますか？",
        "カードがあなたを待っています",
        "運命の扉を開きましょう",
        "今日の運勢を見てみましょう",
        "心を落ち着けて、カードを選んで",
        "タロットがあなたに語りかけます",
        "直感を信じて選んでください"
    ]

    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 20) {
                Text("🔮 タロット占い")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text(greetingMessage)
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                VStack(spacing: 12) {
                    NavigationLink(value: "恋愛") {
                        CategoryButton(emoji: "💕", title: "恋愛")
                    }

                    NavigationLink(value: "仕事") {
                        CategoryButton(emoji: "💼", title: "仕事")
                    }

                    NavigationLink(value: "金運") {
                        CategoryButton(emoji: "💰", title: "金運")
                    }

                    NavigationLink(value: "健康") {
                        CategoryButton(emoji: "💪", title: "健康")
                    }

                    NavigationLink(value: "総合運") {
                        CategoryButton(emoji: "🌟", title: "総合運")
                    }
                }
                .padding(.top, 20)

                Spacer()
            }
            .padding()
            .onAppear {
                greetingMessage = greetingMessages.randomElement() ?? greetingMessages[0]
            }
            .navigationDestination(for: String.self) { category in
                FortuneView(category: category, onGoHome: {
                    navigationPath = NavigationPath()
                })
            }
        }
    }
}

struct CategoryButton: View {
    let emoji: String
    let title: String

    var body: some View {
        HStack {
            Text(emoji)
                .font(.title)
            Text(title)
                .font(.title2)
                .fontWeight(.medium)
            Spacer()
            Image(systemName: "chevron.right")
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.gray.opacity(0.1))
        .foregroundColor(.primary)
        .cornerRadius(12)
    }
}


#Preview {
    HomeView()
}
