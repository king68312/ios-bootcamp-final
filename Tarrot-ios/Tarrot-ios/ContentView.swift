//下に表示されるタブ 
import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house")
                    Text("ホーム")
                }

            HistoryView()
                .tabItem {
                    Image(systemName: "clock")
                    Text("履歴")
                }
        }
    }
}

#Preview {
    ContentView()
        .environment(FortuneHistoryManager())
}

