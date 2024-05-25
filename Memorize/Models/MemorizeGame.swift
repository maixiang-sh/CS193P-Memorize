//
//  MemorizeGame.swift
//  Memorize
//
//  Created by 买祥 on 2024/5/10.
//

import Foundation

/// MemorizeGame 的 Model
struct MemorizeGame<CardContent> where CardContent: Equatable {
    /// 一组游戏卡片
    private(set) var cards: [Card]
    /// 游戏得分
    private(set) var score = 0
    
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
        willSet {
            debugPrint("[OnlyFaceUpCard]: Change to \(String(describing: (newValue != nil) ? cards[newValue!] : nil))")
        }
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
        
        // 检查是否已经有且只有一张面朝上的卡片
        if let potentialMatchIndex = indexOfTheOneAndOnlyFaceUpCard {
            // 如果有，检查这两张卡片的内容是否匹配
            if cards[chosenIndex].content == cards[potentialMatchIndex].content {
                // 如果匹配，标记这两张卡片为已匹配，且分数 + 2
                cards[chosenIndex].isMatched = true
                cards[potentialMatchIndex].isMatched = true
                // MARK: - 更新得分 score += 2 ， 额外加上卡片的时间奖励
                score += 2 + cards[chosenIndex].bonus + cards[potentialMatchIndex].bonus
            } else {
                // 如果两张卡片不匹配，若卡片已经被察看过，分数 - 1
                // MARK: - 更新得分 score -= 1
                if cards[chosenIndex].hasBeenSeen {
                    score -= 1
                }
                if cards[potentialMatchIndex].hasBeenSeen {
                    score -= 1
                }
            }
            // 重置面朝上的唯一卡片索引
            indexOfTheOneAndOnlyFaceUpCard = nil
        } else {
            // 如果没有唯一面朝上的卡片，将当前卡片设置为唯一面朝上的卡片
            indexOfTheOneAndOnlyFaceUpCard = chosenIndex
            // 将其他的卡片全部设置为面朝下
            cards.indices.forEach { index in
                guard cards[index].id != card.id else { return }
                cards[index].isFaceUp = false
            }
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
    
    
    // MARK: - Card 结构体
    
    /// Card 的结构体
    struct Card: Equatable, CustomStringConvertible, Identifiable {
        /// 卡片的唯一 id
        var id: String
        /// 表示卡片是否朝上
        var isFaceUp = false {
            // 重命名 oldValue 为 wasFacingUpBefore （之前卡片朝上）
            didSet(wasFacingUpBefore) {
                if isFaceUp {
                    startUsingBonusTime() // 开始使用奖励时间
                } else {
                    stopUsingBonusTime() //停止使用奖励时间
                }
                // 当卡片从朝上翻到朝下时，标记为已被查看。
                if wasFacingUpBefore && !isFaceUp {
                    hasBeenSeen = true
                }
            }
        }
        /// 表示卡片是否匹配
        var isMatched = false {
            didSet {
                if isMatched {
                    stopUsingBonusTime() // 停止使用奖励时间
                }
            }
        }

        /// 表示卡片是否被查看过
        var hasBeenSeen = false
        /// 卡片的内容，是一个范型
        let content: CardContent
        /// print 时，卡片的信息
        ///
        /// - up: face up
        /// - dw: face down
        /// - mtchd: matched
        /// - msmtch: mismatch
        
        var description: String {
            let info = "\(id) \(content) \(isFaceUp ? "up" : "dw") \(isMatched ? "mtchd " : "msmtch")"
            if !isMatched {
                return info
            } else {
                let displayWidth = info.reduce(0) { total, char in
                    let isEmoji = char.unicodeScalars.first?.properties.isEmojiPresentation ?? false || char.unicodeScalars.first?.value ?? 0 > 0x238C
                    return total + (isEmoji ? 2 : 1)
                }
                return String(repeating: " ", count: displayWidth)
            }
        }
        
        // MARK: - Bouns Time 奖励时间
        
        /// 激活卡片的奖励时间。
        ///
        /// 当卡片首次翻面朝上且尚未匹配且还有剩余奖励时间时，记录当前时间为奖励时间的起始时间。
        private mutating func startUsingBonusTime() {
            if isFaceUp && !isMatched && bonusPercentRemaining > 0, lastFaceUpDate == nil {
                lastFaceUpDate = Date()
            }
        }
        
        /// 停止卡片的奖励时间计算。
        ///
        /// 当卡片被盖下或成功匹配时，更新过去面朝上的时间，并重置最后翻面时间。
        private mutating func stopUsingBonusTime() {
            pastFaceUpTime = faceUpTime
            lastFaceUpDate = nil
        }
        
        /// 计算到目前为止获得的奖励点数。
        ///
        /// 奖励点数基于未使用的奖励时间计算，时间越长，剩余奖励点数越少。
        /// 即在奖励时间内，越快匹配到正确的卡片，得分越高。
        var bonus: Int {
            Int(bonusTimeLimit * bonusPercentRemaining)
        }
        
        /// 计算剩余奖励时间的百分比。
        ///
        /// 如果设置了奖励时间限制，并且卡片仍然面朝上，根据剩余时间计算剩余奖励百分比。
        var bonusPercentRemaining: Double {
            bonusTimeLimit > 0 ? max(0, bonusTimeLimit - faceUpTime)/bonusTimeLimit : 0
        }
        
        /// 计算卡片面朝上且未匹配的总时间。
        ///
        /// 总时间包括之前累计的面朝上时间和自上次翻面朝上至今的时间。
        var faceUpTime: TimeInterval {
            if let lastFaceUpDate {
                return pastFaceUpTime + Date().timeIntervalSince(lastFaceUpDate)
            } else {
                return pastFaceUpTime
            }
        }
        /// 设置卡片匹配前可获得奖励的时间限制。
        ///
        /// 在此时间限制内找到匹配的卡片可以获得额外的奖励点数。
        var bonusTimeLimit: TimeInterval = 6
        
        /// 记录卡片最后一次被翻面朝上的时间。
        var lastFaceUpDate: Date?
        
        /// 记录卡片过去面朝上的累积时间。
        /// 
        /// 不包括当前面朝上的时间段，如果卡片当前正面朝上。
        var pastFaceUpTime: TimeInterval = 0
    }
}

