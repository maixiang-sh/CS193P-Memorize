//
//  Cardify.swift
//  Memorize
//
//  Created by 买祥 on 2024/5/24.
//

import SwiftUI

/// `Cardify` 为视图添加卡片样式效果，包括卡片的正反面显示。
///
/// 使用该视图修改器可以创建一个带有圆角矩形边框、内部填充和可选内容的卡片。
/// 根据 `isFaceUp` 的值决定显示卡片的正面还是背面。
struct Cardify: ViewModifier, Animatable {
    /// 初始化时，根据卡片是否正面朝上来设定旋转角度。
    /// - Parameter isFaceUp: 表示卡片初始时是否正面朝上。
    init(isFaceUp: Bool) {
        self.rotation = isFaceUp ? 0 : 180
    }
    
    /// 指示卡片是否正面朝上。
    var isFaceUp: Bool {
        rotation < 90
    }
    
    /// 使用 `rotation` 来表示卡片的翻转状态。当 `rotation` 小于90度时认为正面朝上。
    var rotation: Double
    
    /// `animatableData` 属性使 `rotation` 成为可动画的数据。
    /// 当 `rotation` 发生变化时，SwiftUI 自动应用动画。
    var animatableData: Double {
        get { rotation }
        set { rotation = newValue }
    }
    
    /// 定义如何根据该视图修改器修改内容并返回新的视图布局。
    ///
    /// - Parameter content: 被修改器装饰的内容。
    /// - Returns: 一个包含原始内容并修改以显示卡片样式的视图。
    func body(content: Content) -> some View {
        ZStack {
            // 卡片的基础形状
            let base = RoundedRectangle(cornerRadius: Constants.cornerRadius)
            
            // 如果卡片正面朝上，显示卡片正面
            base.strokeBorder(lineWidth: Constants.lineWidth) // 为卡片边缘添加内部描边
                .background(base.fill(.white)) // 填充白色背景
                .overlay(content) // 添加卡片的内容
                .opacity(isFaceUp ? 1 : 0) // 根据卡片是否面朝上来设置不透明度
            
            // 如果卡片背面朝上，显示卡片背面
            base.fill() // 填充卡片背面
                .opacity(isFaceUp ? 0 : 1) // 根据卡片是否面朝上来调整不透明度
        }
        .rotation3DEffect(.degrees(rotation), axis: (0,1,0)) // 这里使用 `rotation` 是为了避免 `isFaceUp` 的变化也产生动画效果
    }
    
    /// 存储卡片样式相关的常量。
    private struct Constants {
        static let cornerRadius: CGFloat = 12 // 卡片圆角半径
        static let lineWidth: CGFloat = 2 // 卡片边框宽度
    }
}


/// 扩展 `View` 以添加 `cardify` 方法，这使得任何视图可以方便地转换为具有卡片样式的视图。
extension View {
    /// 应用 `Cardify` 视图修改器到视图上，使其具备卡片的外观和行为。
    ///
    /// 此方法通过 `Cardify` 视图修改器给视图添加圆角矩形边框、背景填充和可选内容叠加。
    /// 它控制视图显示为卡片的正面或背面，取决于 `isFaceUp` 参数的值。
    ///
    /// - Parameter isFaceUp: 一个布尔值，表示卡片是否正面朝上。如果为 `true`，则显示卡片正面；如果为 `false`，则显示卡片背面。
    /// - Returns: 一个修改后的视图，现在具有卡片风格的外观。
    func cardify(isFaceUp: Bool) -> some View {
        modifier(Cardify(isFaceUp: isFaceUp))
    }
}
