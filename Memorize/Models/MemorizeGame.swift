//
//  MemorizeGame.swift
//  Memorize
//
//  Created by 买祥 on 2024/5/10.
//

import Foundation

/// MemorizeGame 的 Model
struct MemorizeGame<CardContent> where CardContent: Equatable {
    /// 外部仅可读，不可修改
    private(set) var cards: [Card]
    
    /// MemorizeGame 初始化方法
    /// - Parameters:
    ///   - numberOfPairsOfCards: 卡片的对数，1 对卡片即 2 张
    ///   - CardContentFactory: 用于创建卡片内容的方法，pairIndex 表示第 n 张卡片，需要返回一个 CardContent
    init(numberOfPairsOfCards: Int, cardContentFactory: (_ pairIndex: Int) -> CardContent) {
        self.cards = []
        for pairIndex in 0..<numberOfPairsOfCards {
            /// 使用 cardContentFactory 方法创建 cardContent
            let cardContent = cardContentFactory(pairIndex)
            /// 一次创建 2 张卡片（一对）
            cards.append(Card(id: "\(pairIndex + 1)A", content: cardContent))
            cards.append(Card(id: "\(pairIndex + 1)B", content: cardContent))
        }
        shuffle()
//        debugPrint("[Cards]: Initialized \(cards)")
    }
    
    /// 唯一一张正面朝上的卡片索引
    var indexOfTheOneAndOnlyFaceUpCard: [Card].Index? = nil {
        willSet { debugPrint("[OnlyFaceUpCard]: Change to \(newValue.map { String(describing: cards[$0]) } ?? "nil")") }
    }
    
    /// 选择卡片的方法
    /// - Parameter card:
    mutating func choose(_ card: Card) {
        // 查找选中的卡片在卡片数组中的索引，并确保该卡片未被翻开且未被匹配
        guard let chosenIndex = index(of: card),
              !cards[chosenIndex].isFaceUp,
              !cards[chosenIndex].isMatched else { return }
        
        // 打印选中卡片的信息
        debugPrint("[Chosen]: \(card) => up")
        
        // 检查是否有其他面朝上的卡片
        if let potentialMatchIndex = indexOfTheOneAndOnlyFaceUpCard {
            // 如果有，检查这两张卡片的内容是否匹配
            if cards[chosenIndex].content == cards[potentialMatchIndex].content {
                // 如果匹配，标记这两张卡片为已匹配
                cards[chosenIndex].isMatched = true
                cards[potentialMatchIndex].isMatched = true
            }

            // 重置面朝上的唯一卡片索引
            indexOfTheOneAndOnlyFaceUpCard = nil
        } else {
            // 如果没有其他面朝上的卡片，将当前卡片设置为唯一面朝上的卡片
            indexOfTheOneAndOnlyFaceUpCard = chosenIndex
            // 翻转所有未匹配的卡片，使其面朝下
            cards.indices.forEach { cards[$0].isFaceUp = cards[$0].isMatched }
        }
        
        // 翻开当前选中的卡片
        cards[chosenIndex].isFaceUp = true
    }
    
    /// 查找 card 在 cards 中的 index
    /// - Parameter card: 需要查找的 card
    /// - Returns:  card 在 cards 中的 index
    private func index(of card: Card) -> [Card].Index? {
        return cards.firstIndex(where: { $0.id == card.id})
    }
    
    /// 洗牌
    mutating func shuffle() {
        cards.shuffle()
//        debugPrint("[Shuffled]: \(cards)")
    }
    
    mutating func reset() {
        cards.indices.forEach {
            cards[$0].isFaceUp = false
            cards[$0].isMatched = false
        }
        shuffle()
    }
    
    /// Card 的结构体
    struct Card: Equatable, CustomStringConvertible, Identifiable {
        var id: String
        /// 表示卡片是否朝上
        var isFaceUp = false
        /// 表示卡片是否匹配
        var isMatched = false
        /// 卡片的内容，是一个范型
        let content: CardContent
        
        var description: String {
            "\(id) \(content) \(isFaceUp ? " up ": "down") \(isMatched ? "matched " : "mismatch")"
        }
    }
}

