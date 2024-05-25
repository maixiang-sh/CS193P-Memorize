//
//  EmojiMemorizeGame.swift
//  Memorize
//
//  Created by 买祥 on 2024/5/10.
//


import SwiftUI

/// `EmojiMemorizeGame` 提供了一个使用表情符号的记忆卡片游戏的功能实现。
///
/// 这个类封装了游戏的逻辑，并使用 `MemorizeGame` 通用游戏逻辑来处理卡片的匹配逻辑。
/// 游戏中使用的是一组表情符号，并提供了方法来选择卡片、洗牌和重置游戏。
@Observable
class EmojiMemorizeGame {
    typealias Card = MemorizeGame<String>.Card
    
    static private let emojis = ["🥐", "🥯", "🍞", "🥖", "🥨", "🥞", "🧇", "🍗", "🌭", "🍔", "🍟", "🍕", "🥪", "🥙", "🧆", "🌮", "🌯", "🫔", "🥗", "🥘", "🍣", "🍜", "🍱", "🥮", "🍩", "🍡"]
    
    /// 创建一个新的记忆游戏实例。
    /// - Returns: 返回一个新的 `MemorizeGame<String>` 实例，具体游戏逻辑由 `MemorizeGame` 处理。
    static private func createMemorizeGame() -> MemorizeGame<String> {
        MemorizeGame(numberOfPairsOfCards: 8) { pairIndex in
            if emojis.indices.contains(pairIndex) {
                return emojis[pairIndex]
            } else {
                return "⁉️"
            }
        }
    }
    
    /// 内部 `MemorizeGame` Model 实例，用于管理游戏状态。
    private var model = createMemorizeGame()
    
    /// 游戏卡片的颜色主题
    var color: Color = .orange
    
    /// 当前游戏分数，由 `MemorizeGame` 管理。
    var score: Int {
        model.score
    }
    
    /// 当前所有卡片的数组，外部只读访问。
    var cards: [Card] {
        model.cards
    }
    
    /// 选择一个卡片并尝试匹配。
    /// - Parameter card: 被选择的卡片。
    func choose(_ card: Card) {
        model.choose(card)
    }
    
    /// 洗牌，打乱卡片的顺序。
    func shuffle() {
        model.shuffle()
    }
    
    /// 重置游戏到初始状态。
    func reset() {
        model = EmojiMemorizeGame.createMemorizeGame()
    }

}
