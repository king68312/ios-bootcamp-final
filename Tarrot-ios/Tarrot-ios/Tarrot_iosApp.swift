import SwiftUI

@main
struct Tarrot_iosApp: App {
    @State private var historyManager = FortuneHistoryManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(historyManager)
        }
    }
}
