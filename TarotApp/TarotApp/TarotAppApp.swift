import SwiftUI

@main
struct TarotAppApp: App {
    @StateObject private var historyManager = FortuneHistoryManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(historyManager)
        }
    }
}
