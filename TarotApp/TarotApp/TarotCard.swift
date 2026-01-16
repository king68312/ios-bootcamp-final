import Foundation

enum TarotCard: String, CaseIterable, Codable {
    case theFool
    case theMagician
    case theHighPriestess
    case theEmpress
    case theEmperor
    case theHierophant
    case theLovers
    case theChariot
    case strength
    case theHermit
    case wheelOfFortune
    case justice
    case theHangedMan
    case death
    case temperance
    case theDevil
    case theTower
    case theStar
    case theMoon
    case theSun
    case judgement
    case theWorld

    var name: String {
        switch self {
        case .theFool: return "愚者"
        case .theMagician: return "魔術師"
        case .theHighPriestess: return "女教皇"
        case .theEmpress: return "女帝"
        case .theEmperor: return "皇帝"
        case .theHierophant: return "教皇"
        case .theLovers: return "恋人"
        case .theChariot: return "戦車"
        case .strength: return "力"
        case .theHermit: return "隠者"
        case .wheelOfFortune: return "運命の輪"
        case .justice: return "正義"
        case .theHangedMan: return "吊るされた男"
        case .death: return "死神"
        case .temperance: return "節制"
        case .theDevil: return "悪魔"
        case .theTower: return "塔"
        case .theStar: return "星"
        case .theMoon: return "月"
        case .theSun: return "太陽"
        case .judgement: return "審判"
        case .theWorld: return "世界"
        }
    }

    var emoji: String {
        switch self {
        case .theFool: return "🃏"
        case .theMagician: return "🎩"
        case .theHighPriestess: return "🌙"
        case .theEmpress: return "👑"
        case .theEmperor: return "🏰"
        case .theHierophant: return "📿"
        case .theLovers: return "💕"
        case .theChariot: return "🏎️"
        case .strength: return "🦁"
        case .theHermit: return "🏔️"
        case .wheelOfFortune: return "🎡"
        case .justice: return "⚖️"
        case .theHangedMan: return "🙃"
        case .death: return "💀"
        case .temperance: return "🏺"
        case .theDevil: return "😈"
        case .theTower: return "🗼"
        case .theStar: return "⭐"
        case .theMoon: return "🌕"
        case .theSun: return "☀️"
        case .judgement: return "📯"
        case .theWorld: return "🌍"
        }
    }

    var meaning: String {
        switch self {
        case .theFool: return "新しい始まり、冒険、自由な精神。恐れずに一歩を踏み出すとき。"
        case .theMagician: return "創造力、意志の力、新たな可能性。あなたには実現する力がある。"
        case .theHighPriestess: return "直感、神秘、内なる声。静かに自分の心に耳を傾けて。"
        case .theEmpress: return "豊かさ、創造性、母性。愛と美に満ちた時期。"
        case .theEmperor: return "安定、権威、リーダーシップ。しっかりとした基盤を築くとき。"
        case .theHierophant: return "伝統、教え、精神的な導き。信頼できる人からの助言を。"
        case .theLovers: return "愛、調和、選択。心に従って大切な決断を。"
        case .theChariot: return "勝利、意志の強さ、前進。困難を乗り越える力がある。"
        case .strength: return "内なる強さ、勇気、忍耐。優しさこそが本当の強さ。"
        case .theHermit: return "内省、探求、知恵。一人の時間が答えをくれる。"
        case .wheelOfFortune: return "運命の転換、チャンス、変化。流れに乗るとき。"
        case .justice: return "公正、バランス、真実。正しい判断ができる時期。"
        case .theHangedMan: return "視点の転換、手放し、待機。違う角度から見てみて。"
        case .death: return "終わりと始まり、変容、再生。古いものを手放し新しく。"
        case .temperance: return "調和、バランス、癒し。穏やかに物事を進めて。"
        case .theDevil: return "執着、誘惑、束縛。自分を縛るものから解放されて。"
        case .theTower: return "突然の変化、崩壊、気づき。壊れることで新しくなる。"
        case .theStar: return "希望、インスピレーション、癒し。明るい未来が待っている。"
        case .theMoon: return "不安、幻想、潜在意識。直感を信じて霧を抜けて。"
        case .theSun: return "成功、喜び、活力。明るく輝く時期。すべてがうまくいく。"
        case .judgement: return "復活、判断、目覚め。過去を振り返り新たなステージへ。"
        case .theWorld: return "完成、達成、統合。一つのサイクルの完了。おめでとう！"
        }
    }
}
