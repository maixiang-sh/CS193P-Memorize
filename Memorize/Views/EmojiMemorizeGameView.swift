//
//  ContentView.swift
//  Memorize
//
//  Created by 买祥 on 2024/4/30.
//

import SwiftUI

/// EmojiMemorizeGameView 是一个 SwiftUI 视图，用于展示和控制一个表情记忆游戏。
/// 游戏中包括一个卡片网格、得分显示和重置游戏的按钮。
struct EmojiMemorizeGameView: View {
    /// 定义了用于游戏中的卡片类型。
    typealias Card = MemorizeGame<String>.Card
    
    /// 从环境中获取的游戏 ViewModel。
    @Environment(EmojiMemorizeGame.self) private var viewModel
    
    // MARK: - Constants 视图和动画中所用到的常量
    /// 卡片的宽高比。
    private let aspectRatio: CGFloat = 2/3
    /// 卡片之间的间距。
    private let spacing: CGFloat = 4
    /// 卡组的宽度
    private let deckWidth: CGFloat = 50
    /// 发牌时，每张卡片之间的动画延迟间隔
    private let dealInterval = 0.05
    /// 发牌动画 （snappy: 迅速且有些许弹性）
    private let dealAnimation: Animation = .snappy(duration: 1)
    
    @Namespace private var dealingNamespace
    
    var body: some View {
        VStack {
            cards.foregroundColor(viewModel.color)
            HStack {
                score
                Spacer()
                deck.foregroundColor(viewModel.color)
                Spacer()
                reset
            }.font(.largeTitle)
        }
        .padding()
    }
    
    /// 创建并返回一个卡片网格视图。
    ///
    /// 使用 `AspectVGrid` 来展示所有的卡片。对于每张已发牌的卡片，为其添加视图和交互功能。
    /// - 视图中包括每张卡片的 `CardView` 表示，以及在卡片被点击时触发的动画和游戏逻辑。
    /// - 已发牌的卡片通过检查 `dealt` 集合来确定。
    /// - 当卡片被点击时，调用 `choose` 方法来处理选择逻辑，该方法内部可能包含游戏的得分逻辑。
    /// - 初始显示时，将未发牌的卡片标记为已发牌，确保它们在视图中正确处理。
    @ViewBuilder
    private var cards: some View {
        AspectVGrid(viewModel.cards, aspectRatio: aspectRatio) { card in
            if isDealt(card) {
                CardView(card)
                    .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                    .transition(.asymmetric(insertion: .identity, removal: .identity)) // MARK: - 关于 .transition(.asymmetric(insertion:, removal:))
                    .padding(spacing)
                    .overlay {
                        FlyingNumber(number: scoreChange(causedBy: card)) // 为每张卡添加跳出分数的视图
                    }
                    .zIndex(scoreChange(causedBy: card) != 0 ? 100 : 0) // 根据分数变化调整卡片的视图层级
                    .onTapGesture {
                        withAnimation() { choose(card) }
                    }
            }
        }
    }
    
    // MARK: - 发牌动画
    
    /// 已经发牌的卡片的集合。
    @State private var dealt = Set<Card.ID>()
    
    /// 检查指定的卡片是否已经被发牌。
    ///
    /// 通过检查卡片的 ID 是否存在于已发牌的 ID 集合中来判断该卡片是否已发牌。
    /// - Parameter card: 需要检查的卡片。
    /// - Returns: 如果卡片已经发牌则返回 `true`，否则返回 `false`。
    private func isDealt(_ card: Card) -> Bool {
        return dealt.contains(card.id)
    }
    
    /// 获取尚未发牌的卡片列表。
    ///
    /// 通过过滤出所有未在 `dealt` 集合中的卡片来获取未发牌的卡片。
    /// - Returns: 一个包含所有未发牌卡片的数组。
    private var undealtCards: [Card] {
        return viewModel.cards.filter { !isDealt($0) }
    }
    
    /// 提供一个显示一组未发牌的卡片的视图。
    ///
    /// 使用 `ZStack` 来重叠卡片，以模拟一副牌的视觉效果。每张卡片都用 `CardView` 来表示，
    /// 并应用了 `matchedGeometryEffect` 来确保卡片之间的过渡动画是连贯的。
    ///
    /// - `matchedGeometryEffect(id:in:)` 用于同步卡片在不同视图状态之间的位置和尺寸变化，
    ///   使动画过渡看起来更自然。
    ///
    /// - `.transition(.asymmetric(insertion:removal:))` 用于定义卡片的插入和移除动画，
    ///   在这里，无论是插入还是移除，都设置为 `.identity`，意味着卡片的显示和隐藏将瞬间完成，无过渡效果。
    ///
    /// `onTapGesture` 中包含了一个动画序列，用于模拟发牌过程，每张卡片的发牌动画都稍有延迟，
    /// 从而创建一种动态的发牌效果。
    @ViewBuilder
    private var deck: some View {
        ZStack {
            ForEach(undealtCards) { card in
                CardView(card)
                    .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                    .transition(.asymmetric(insertion: .identity, removal: .identity)) // MARK: - 关于 .transition(.asymmetric(insertion:, removal:))
            }
        }
        .frame(width: deckWidth, height: deckWidth / aspectRatio)
        .onTapGesture {
            deal() // 发牌
        }
    }
    
    /// 发牌过程的执行函数。
    ///
    /// 此函数遍历 `viewModel.cards` 中的所有卡片，
    /// 使用 `withAnimation` 为每张卡片设置动画，每张卡片的动画延迟时间比前一张多若干秒 ，
    /// 从而创建一种逐张发牌的效果。
    private func deal() {
        // 动画延迟开始的时间
        var delay: TimeInterval = 0
        viewModel.cards.forEach { card in
            // 对每次一次发牌都触发动画效果
            withAnimation(dealAnimation.delay(delay)) {
                // 使用 `let _ = ...` 来忽略 `insert` 方法的返回值
                let _ = dealt.insert(card.id)
            }
            // 为下一张卡片增加 0.05 秒的延迟
            delay += dealInterval
        }
    }
    
    // MARK: - 选择卡片、时间奖励得分
    
    /// 选择一张卡片并处理与选择相关的游戏逻辑。
    ///
    /// 此方法处理游戏中卡片被选中的事件。它首先记录选择卡片前的得分，
    /// 然后调用 ViewModel 的 `choose` 方法来更新游戏状态（包括检查卡片是否匹配等），
    /// 最后计算并记录得分变化，并更新 `lastScroeChange` 状态，以便视图可以反应这一变化。
    ///
    /// - Parameter card: 被选中的卡片，需要包含有效的 ID。
    ///
    /// 使用此方法时，会自动处理得分的更新和状态变更，包括：
    /// - 计算选择卡片前后的得分差异。
    /// - 更新关联的状态，用于视图更新或其他逻辑处理。
    private func choose(_ card: Card) {
        let scoreBeforeChoosing = viewModel.score // 记录选择前的得分
        viewModel.choose(card) // 调用 ViewModel 来处理卡片选择逻辑
        let scoreAfterChoosing = viewModel.score // 记录选择后的得分
        let scoreChange = scoreAfterChoosing - scoreBeforeChoosing // 计算得分变化
        lastScroeChange = (scoreChange, card.id) // 更新状态，记录最近一次的得分变化和卡片 ID
    }
    
    /// 显示当前得分的视图。
    @ViewBuilder
    private var score: some View {
        Text("Score: \(viewModel.score)")
            .animation(nil)
    }
    
    /// 重置游戏的按钮视图。
    @ViewBuilder
    private var reset: some View {
        Button {
            withAnimation(.bouncy) {
                viewModel.reset()
            }
        } label: {
            VStack {
                Image(systemName: "dice")
                Text("New Game")
            }
        }
    }
    
    /// 记录上一次卡片选择引起的分数变化以及引起变化的卡片 ID。
    /// 这个状态变量用来存储由卡片选择引发的最近一次得分变化的数量和相关卡片的唯一标识符。
    /// - 注意: 这个元组的第一个元素是分数变化量，第二个元素是引起变化的卡片的 ID。
    @State private var lastScroeChange = (0, causedBycardId: "")
    
    /// 计算由特定卡片引起的得分变化。
    ///
    /// 这个函数根据卡片是否是上次改变分数的卡片来返回相应的分数变化。
    /// 如果是同一张卡片，则返回记录的分数变化值；如果不是，返回 0。
    /// - Note: 这个函数重点关心 **最后一次被点击** 的卡片，及其引起的游戏得分变化。不是最后一次点击的卡片，都会返回 **0**
    ///
    /// 在本视图的 `cards` View 中，当创建卡片网格视图时，每一张卡片都被作为参数传入到了这个函数。
    /// 在函数内部 每一张卡片都会和 **@State** 变量 `lastScroeChange` 中存储的卡片做对比。
    /// - 如果传入的这张卡片**是**最后一次被点击的卡片，那么则返回最后一次点击的游戏得分变化。
    /// - 如果传入的这张卡片**不是**最后一次被点击的卡片，那么则返回 0。
    ///
    /// - Parameter card: 需要评估得分变化的卡片。
    /// - Returns: 如果传入的卡片是上次操作中改变分数的卡片，返回对应的分数变化值；否则返回 0。
    private func scoreChange(causedBy card: Card)-> Int {
        let (amount, id) = lastScroeChange
        return card.id == id ? amount : 0
    }
}

#Preview {
    EmojiMemorizeGameView()
        .environment(EmojiMemorizeGame())
}


// MARK: - 关于 .transition(.asymmetric(insertion:, removal:))
//在 SwiftUI 中，.transition 修饰符用于定义视图的进入和退出动画。使用 .asymmetric 可以为视图的插入和移除分别指定不同的动画效果。理解 .asymmetric(insertion: removal:) 中的 .identity 就需要了解这些参数是如何影响视图的动画表现的。

//.asymmetric 解析
//
//.asymmetric 允许你为视图的插入和移除设置不同的转换效果。这是非常有用的，因为在很多情况下，你可能希望视图出现和消失的方式不同。例如，一个视图可能通过淡入的方式出现，但通过向下滑动的方式消失。
//
//    •    insertion: 插入动画，即视图添加到界面上时的动画。
//    •    removal: 移除动画，即视图从界面上移除时的动画。
//
//.identity 解析
//
//.identity 是一个特殊的动画类型，表示没有动画效果，视图会立即出现或消失，没有任何过渡效果。这意味着视图的插入和移除会瞬间完成，用户不会看到任何动画。
//
// .transition(.identity) 和 .transition(.asymmetric(insertion: .identity, removal: .identity)) 的区别
// 后者会保留 matchedGeometryEffect(id:in:properties:anchor:isSource:) 的动画效果
