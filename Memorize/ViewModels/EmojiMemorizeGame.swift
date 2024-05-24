//
//  EmojiMemorizeGame.swift
//  Memorize
//
//  Created by 买祥 on 2024/5/10.
//


import SwiftUI

@Observable
class EmojiMemorizeGame {
    typealias Card = MemorizeGame<String>.Card
    
    static private let emojis = ["🥐", "🥯", "🍞", "🥖", "🥨", "🥞", "🧇", "🍗", "🌭", "🍔", "🍟", "🍕", "🥪", "🥙", "🧆", "🌮", "🌯", "🫔", "🥗", "🥘", "🍣", "🍜", "🍱", "🥮", "🍩", "🍡"]
    static private func createMemorizeGame() -> MemorizeGame<String> {
        MemorizeGame(numberOfPairsOfCards: 8) { pairIndex in
            if emojis.indices.contains(pairIndex) {
                return emojis[pairIndex]
            } else {
                return "⁉️"
            }
        }
    }
    
    
    // 避免对外界暴露 model
    private var model = createMemorizeGame()
    
    var color: Color = .orange
    
    var cards: [Card] {
        model.cards
    }
    
    
    func choose(_ card: Card) {
        model.choose(card)
    }
    
    /// 洗牌
    func shuffle() {
        model.shuffle()
    }
    
    func reset() {
        model.reset()
    }

}
