//かーどをひくがめん(結果はまだ)

import SwiftUI

struct FortuneView: View {
    let category: String
    var onGoHome: (() -> Void)?

    @State private var drawnCard: TarotCard?
    @State private var isAnimating: Bool = false
    @State private var showResult: Bool = false

    var body: some View {
        VStack(spacing: 30) {
            Text("\(category)を占います")
                .font(.title2)
                .foregroundColor(.secondary)

            // カードの裏面
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.purple.opacity(0.5), Color.purple.opacity(0.3)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 200, height: 300)
                    .shadow(radius: 10)

                if let card = drawnCard {
                    VStack {
                        Text(card.emoji)
                            .font(.system(size: 60))
                        Text(card.name)
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                } else {
                    VStack(spacing: 8) {
                            
                        Text("タップしてカードを引く")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
            }
            .scaleEffect(isAnimating ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 0.3), value: isAnimating)

            if drawnCard != nil {
                Button(action: { showResult = true }) {
                    Text("結果を見る")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.purple)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
            } else {
                Button(action: drawCard) {
                    Text("カードを引く")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.purple)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
            }

            Spacer()
        }
        .padding()
        .navigationTitle(category)
        .navigationDestination(isPresented: $showResult) {
            if let card = drawnCard {
                ResultView(card: card, category: category, onGoHome: onGoHome)
            }
        }
        .onChange(of: showResult) { oldValue, newValue in
            // ResultViewから戻ってきた時にカードをリセット
            if oldValue == true && newValue == false {
                drawnCard = nil
            }
        }
    }

    private func drawCard() {
        isAnimating = true

        // シャッフルアニメーション効果
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isAnimating = false
            drawnCard = TarotCard.allCases.randomElement()
        }
    }
}

#Preview {
    NavigationStack {
        FortuneView(category: "恋愛")
    }
}
