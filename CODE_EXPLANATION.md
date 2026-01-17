# TarotApp コード解説

## ファイル構成

```
Tarrot-ios/
├── Tarrot_iosApp.swift    # エントリーポイント
├── ContentView.swift      # TabView（メイン画面）
├── HomeView.swift         # ホーム画面
├── FortuneView.swift      # 占い画面（カードを引く）
├── ResultView.swift       # 結果画面
├── HistoryView.swift      # 履歴画面
├── TarotCard.swift        # カードデータ定義
├── FortuneResult.swift    # 占い結果 + 履歴管理
└── OpenAIClient.swift     # OpenAI API通信
```

---

## 1. Tarrot_iosApp.swift（エントリーポイント）

### 役割
アプリの起動点。履歴管理オブジェクトを作成し、全画面で共有する。

### 工夫した点
- `@State`で`FortuneHistoryManager`を保持し、`.environment()`で子ビューに渡すことで、アプリ全体で履歴データを共有
- Swift 6の`@Observable`マクロに対応した状態管理

```swift
@State private var historyManager = FortuneHistoryManager()
// → アプリ起動時に履歴管理オブジェクトを1つだけ作成

.environment(historyManager)
// → 全ての子ビューで履歴データにアクセス可能に
```

---

## 2. ContentView.swift（TabView）

### 役割
画面下部のタブバーを表示し、ホーム画面と履歴画面を切り替える。

### 工夫した点
- `TabView`を使用してシンプルな2タブ構成を実現
- SF Symbolsのアイコン（`house`、`clock`）を使用

```swift
TabView {
    HomeView().tabItem { ... }      // 左タブ：ホーム
    HistoryView().tabItem { ... }   // 右タブ：履歴
}
```

---

## 3. HomeView.swift（ホーム画面）

### 役割
タイトルとカテゴリ選択ボタンを表示し、占い画面へ遷移する。

### 主要なプロパティ・関数

| 名前 | 種類 | 説明 |
|------|------|------|
| `greetingMessage` | @State | 表示するメッセージ（ランダム） |
| `navigationPath` | @State | ナビゲーション状態を管理 |
| `greetingMessages` | 配列 | メッセージのパターン一覧 |

### 工夫した点

1. **ランダムメッセージ機能**
   - `onAppear`で画面表示時にランダムなメッセージを選択
   - 7パターンのメッセージを用意して、毎回違う印象に

2. **NavigationPath による画面遷移管理**
   - `NavigationPath`を使用して、どこからでもホームに戻れる仕組み
   - `navigationPath = NavigationPath()`で履歴をリセット

3. **CategoryButton コンポーネント**
   - 再利用可能なボタンコンポーネントとして分離
   - 絵文字、タイトル、矢印アイコンを含むデザイン

```swift
.onAppear {
    greetingMessage = greetingMessages.randomElement() ?? greetingMessages[0]
}
// → 画面表示のたびにランダムなメッセージを選択

.navigationDestination(for: String.self) { category in
    FortuneView(category: category, onGoHome: {
        navigationPath = NavigationPath()  // ホームに戻る
    })
}
```

---

## 4. FortuneView.swift（占い画面）

### 役割
選択したカテゴリでカードを引き、結果画面へ遷移する。

### 主要なプロパティ・関数

| 名前 | 種類 | 説明 |
|------|------|------|
| `category` | let | 選択されたカテゴリ |
| `onGoHome` | クロージャ | ホームに戻る処理 |
| `drawnCard` | @State | 引いたカード（nil = まだ引いていない） |
| `isAnimating` | @State | アニメーション中かどうか |
| `showResult` | @State | 結果画面を表示するか |
| `drawCard()` | 関数 | カードを引く処理 |

### 工夫した点

1. **カード引きアニメーション**
   - `scaleEffect`と`animation`で、カードを引く時に拡大アニメーション
   - `DispatchQueue.main.asyncAfter`で0.3秒後にカードを表示

2. **グラデーション背景のカード**
   - `LinearGradient`で紫のグラデーションを適用
   - `shadow`で立体感を演出

3. **「もう一度占う」機能の実装**
   - `onChange(of: showResult)`で結果画面から戻った時を検知
   - `drawnCard = nil`でカードをリセットし、新規で占える状態に

```swift
private func drawCard() {
    isAnimating = true
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
        isAnimating = false
        drawnCard = TarotCard.allCases.randomElement()  // ランダムに1枚選択
    }
}

.onChange(of: showResult) { oldValue, newValue in
    if oldValue == true && newValue == false {
        drawnCard = nil  // 戻ってきたらリセット
    }
}
```

---

## 5. ResultView.swift（結果画面）

### 役割
引いたカードとAI解説を表示し、履歴に保存する。

### 主要なプロパティ・関数

| 名前 | 種類 | 説明 |
|------|------|------|
| `card` | let | 引いたカード |
| `category` | let | カテゴリ |
| `onGoHome` | クロージャ | ホームに戻る処理 |
| `aiReading` | @State | AI生成の占い結果 |
| `isLoading` | @State | 読み込み中かどうか |
| `hasSaved` | @State | 保存済みかどうか |
| `fetchAIReading()` | 関数 | AI結果を取得 |
| `saveToHistory()` | 関数 | 履歴に保存 |

### 工夫した点

1. **非同期でのAI結果取得**
   - `.task`修飾子で画面表示と同時にAPI呼び出し
   - `ProgressView`でローディング表示

2. **重複保存の防止**
   - `hasSaved`フラグで1回だけ保存するように制御

3. **コンパクトなレイアウト**
   - `.navigationBarTitleDisplayMode(.inline)`でタイトルを小さく
   - `ScrollView`で長いコンテンツもスクロール可能に

```swift
.task {
    await fetchAIReading()  // 画面表示時にAI結果を取得
}

private func saveToHistory() {
    guard !hasSaved else { return }  // 重複保存防止
    hasSaved = true
    historyManager?.saveResult(result)
}
```

### HistoryDetailView（履歴詳細）
- 履歴から選択した結果を表示するサブビュー
- ResultViewと同様のレイアウトで統一感

---

## 6. HistoryView.swift（履歴画面）

### 役割
過去の占い結果を一覧表示し、詳細表示・削除ができる。

### 主要なプロパティ・関数

| 名前 | 種類 | 説明 |
|------|------|------|
| `historyManager` | @Environment | 履歴管理オブジェクト |

### 工夫した点

1. **空の状態の表示**
   - 履歴がない時は説明メッセージを表示
   - アイコンとテキストで視覚的にわかりやすく

2. **スワイプ削除**
   - `.onDelete`で個別の履歴をスワイプ削除可能

3. **全削除ボタン**
   - ツールバーに「全削除」ボタンを配置
   - `#if os(iOS)`でiOS専用の配置を指定

4. **HistoryRowView コンポーネント**
   - リストの各行を再利用可能なコンポーネントとして分離
   - カード絵文字、名前、カテゴリ、日時を表示

```swift
if historyManager?.history.isEmpty ?? true {
    // 空の状態を表示
} else {
    List {
        ForEach(historyManager?.history ?? []) { result in
            NavigationLink(destination: HistoryDetailView(result: result)) { ... }
        }
        .onDelete { offsets in
            historyManager?.deleteResult(at: offsets)
        }
    }
}
```

---

## 7. TarotCard.swift（カードデータ）

### 役割
大アルカナ22枚のカードデータを定義する。

### 構造

```swift
enum TarotCard: String, CaseIterable, Codable {
    case theFool, theMagician, ... // 22枚のケース

    var name: String { ... }    // 日本語名
    var emoji: String { ... }   // 絵文字
    var meaning: String { ... } // カードの意味
}
```

### 工夫した点

1. **CaseIterable プロトコル**
   - `TarotCard.allCases`で全カードを取得可能
   - `allCases.randomElement()`でランダム選択

2. **Codable プロトコル**
   - JSONエンコード/デコードに対応
   - UserDefaultsへの保存が簡単に

3. **計算プロパティで情報を提供**
   - `name`: 日本語のカード名
   - `emoji`: カードを表す絵文字
   - `meaning`: カードの意味（占い結果で使用）

---

## 8. FortuneResult.swift（占い結果 + 履歴管理）

### 役割
占い結果のデータモデルと、UserDefaultsを使った履歴の永続化。

### FortuneResult 構造体

| プロパティ | 型 | 説明 |
|------------|-----|------|
| `id` | UUID | 一意の識別子 |
| `card` | TarotCard | 引いたカード |
| `category` | String | 占いカテゴリ |
| `aiReading` | String | AI生成の結果 |
| `date` | Date | 占った日時 |
| `formattedDate` | String | 日時の表示用文字列 |

### FortuneHistoryManager クラス

| 関数 | 説明 |
|------|------|
| `saveResult(_:)` | 結果を履歴の先頭に追加 |
| `deleteResult(at:)` | 指定位置の結果を削除 |
| `clearHistory()` | 全履歴を削除 |
| `loadHistory()` | UserDefaultsから読み込み |
| `saveHistory()` | UserDefaultsに保存 |

### 工夫した点

1. **@Observable マクロ**
   - Swift 6対応の状態管理
   - `@Published`不要でシンプルに

2. **Codable による永続化**
   - `JSONEncoder`/`JSONDecoder`でUserDefaultsに保存
   - アプリ再起動後も履歴が残る

3. **新しい結果を先頭に追加**
   - `history.insert(result, at: 0)`で最新を上に表示

```swift
func saveResult(_ result: FortuneResult) {
    history.insert(result, at: 0)  // 先頭に追加
    saveHistory()
}

private func saveHistory() {
    let data = try encoder.encode(history)
    UserDefaults.standard.set(data, forKey: userDefaultsKey)
}
```

---

## 9. OpenAIClient.swift（OpenAI API通信）

### 役割
OpenAI APIを使って占い結果のテキストを生成する。

### 主要なプロパティ・関数

| 名前 | 種類 | 説明 |
|------|------|------|
| `shared` | static | シングルトンインスタンス |
| `apiURL` | let | APIエンドポイント |
| `apiKey` | let | APIキー（ここに入力） |
| `generateReading()` | 関数 | 占い結果を生成 |
| `generateDefaultReading()` | 関数 | デフォルト結果を生成 |

### 工夫した点

1. **シングルトンパターン**
   - `static let shared`で1つのインスタンスを共有
   - `private init()`で外部からのインスタンス化を防止

2. **フォールバック機能**
   - APIキー未設定やエラー時はデフォルト結果を返す
   - アプリがクラッシュしない安全設計

3. **async/await による非同期処理**
   - Swift Concurrencyでシンプルな非同期コード
   - `URLSession.shared.data(for:)`で通信

4. **カテゴリ別のデフォルトメッセージ**
   - 恋愛、仕事、金運、健康、総合運それぞれに適したメッセージ

```swift
func generateReading(card: TarotCard, category: String) async -> String {
    // APIキー未設定ならデフォルト結果
    if apiKey.isEmpty || apiKey == "YOUR_API_KEY_HERE" {
        return generateDefaultReading(card: card, category: category)
    }

    // APIリクエスト...
    // エラー時もデフォルト結果を返す
}
```

---

## 技術的な工夫まとめ

### 状態管理
- `@Observable`マクロでSwift 6対応
- `@Environment`で履歴データをアプリ全体で共有
- `@State`で画面ごとのローカル状態を管理

### 画面遷移
- `NavigationStack` + `NavigationPath`でプログラム的な遷移制御
- `navigationDestination`で型安全な遷移
- コールバック（`onGoHome`）で親ビューへの通知

### データ永続化
- `Codable`プロトコルでJSON変換
- `UserDefaults`で簡易的なデータ保存
- アプリ再起動後も履歴を保持

### UI/UX
- `LinearGradient`でグラデーション背景
- `animation`でカード引きアニメーション
- `ProgressView`でローディング表示
- `ScrollView`で長いコンテンツに対応

### エラーハンドリング
- API通信エラー時はデフォルト結果を表示
- オプショナルチェーン（`?`）でnilを安全に処理
- `guard`文で早期リターン
