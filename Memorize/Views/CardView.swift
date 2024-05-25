//
//  CardView.swift
//  Memorize
//
//  Created by 买祥 on 2024/5/22.
//

import SwiftUI

/// `CardView` 用于显示 `MemorizeGame` 中的单个卡片视图。
/// 它结合了文本和形状覆盖，以及基于卡片状态的视觉效果处理。
struct CardView: View {
    /// 定义卡片的类型，这里是 `MemorizeGame` 中的 `Card` 泛型。
    typealias Card = MemorizeGame<String>.Card
    
    /// 卡片对象，存储显示内容和状态。
    var card: Card
    
    /// 初始化一个新的卡片视图。
    /// - Parameter card: `MemorizeGame` 中的卡片对象。
    init(_ card: Card) {
        self.card = card
    }
    
    /// 卡片视图的主体部分，包括形状、文本和其他视图修饰。
    var body: some View {
        TimelineView(.animation) { _ in
            if (card.isFaceUp || !card.isMatched) {
                Pie(endAngle: .degrees(card.bonusPercentRemaining * 360))  // 创建一个半圆形的饼图，用于显示剩余时间的百分比
                    .opacity(Constants.Pie.opacity)  // 设置饼图的透明度
                    .overlay {
                        cardContent
                    }
                    .padding(Constants.Pie.inset)  // 设置饼图的内边距
                    .cardify(isFaceUp: card.isFaceUp)  // 应用卡片翻转效果
                    .transition(.scale)
            } else {
                Color.clear
            }
        }  // 当卡片匹配成功，且再次面朝下时，透明显示
    }
    
    /// 卡片中的内容视图
    @ViewBuilder
    private var cardContent: some View {
        Text(card.content)  // 显示卡片内容
            .multilineTextAlignment(.center)  // 文本居中对齐
            .font(.system(size: Constants.FontSize.largest))  // 设置文本的字体大小
            .minimumScaleFactor(Constants.FontSize.scaleFactor)  //  设置文本缩放的最小比例因子
            .aspectRatio(1, contentMode: .fit)  // 设置视图的宽高比为1:1
            .padding(Constants.inset)  // 设置文本的内边距
            .rotationEffect(.degrees(card.isMatched ? 360 : 0)) // 旋转 Text
            .animation(.spin(duration: 2), value: card.isMatched) // 指定视图改变时的动画方式
    }
    
    /// 存储与卡片视图相关的配置常量。
    private struct Constants {
        static let cornerRadius: CGFloat = 12  // 圆角大小
        static let lineWidth: CGFloat = 2  // 边框线宽
        static let inset: CGFloat = 5  // 边距
        struct FontSize {
            static let largest: CGFloat = 200  // 最大字体大小
            static let smallest: CGFloat = 10  // 最小字体大小
            static let scaleFactor: CGFloat = smallest / largest  // 字体缩放比例因子
        }
        struct Pie {
            static let opacity: CGFloat = 0.4  // 饼图透明度
            static let inset: CGFloat = 5  // 饼图内边距
        }
    }
}

/// 扩展 `Animation` 以添加自定义动画效果。
extension Animation {
    /// 创建一个无限重复的线性旋转动画。
    ///
    /// 此动画将使视图进行持续的旋转，不会自动反向其动画方向。
    /// 可以用于指示器、加载动画等需要持续旋转的场景。
    ///
    /// - Parameter duration: 每次完整旋转的持续时间，以秒为单位。
    /// - Returns: 一个永不停止的旋转动画。
    static func spin(duration: TimeInterval) -> Animation {
        .linear(duration: duration).repeatForever(autoreverses: false)
    }
}


#Preview {
    typealias Card = CardView.Card
    return VStack {
        HStack {
            CardView(.init(id: "1A", isFaceUp: true, content: "🍉"))
            CardView(.init(id: "1B", isFaceUp: true, content: "🍉"))
        }
        HStack {
            CardView(.init(id: "2A", isFaceUp: true, content: "🍉"))
            CardView(.init(id: "2B", isFaceUp: true, content: "🍉"))
        }
    }
    .padding()
    .foregroundStyle(.orange)
}
