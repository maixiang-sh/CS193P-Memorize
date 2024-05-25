//
//  Pie.swift
//  Memorize
//
//  Created by 买祥 on 2024/5/24.
//

import SwiftUI
import CoreGraphics

/// `Pie` 结构体定义了一个扇形，可用于在 SwiftUI 视图中绘制饼图或扇形图。
///
/// 该结构体遵循 `Shape` 协议，允许使用 SwiftUI 的绘图系统自定义形状。
/// 通过指定开始角度和结束角度，可以控制扇形的形状和方向。
struct Pie: Shape {
    /// 扇形的开始角度，默认为0度（向上）。
    let startAngle: Angle = .zero
    /// 扇形的结束角度，需要在使用时指定。
    let endAngle: Angle
    /// 定义扇形绘制方向是否为顺时针。由于 SwiftUI 的坐标系和传统坐标系相反，这里使用逻辑取反。
    let clockwise = true
    
    /// 定义如何根据所提供的矩形框绘制路径。
    ///
    /// - Parameter rect: 定义扇形绘制边界的矩形。
    /// - Returns: 一个路径对象，描述了扇形。
    func path(in rect: CGRect) -> Path {
        // 调整角度以符合SwiftUI的坐标系（原点在顶部，而非传统的底部）
        let startAngle = startAngle - .degrees(90)
        let endAngle = endAngle - .degrees(90)
        // 计算中心点
        let center = CGPoint(x: rect.midX, y: rect.midY)
        // 计算半径
        let radius = min(rect.width, rect.height) / 2
        // 计算开始点的坐标
        let start = CGPoint(
            x: center.x + radius * cos(startAngle.radians),
            y: center.y + radius * sin(startAngle.radians)
        )
        
        var path = Path()
        path.move(to: center)
        path.addLine(to: start)
        path.addArc(
            center: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: !clockwise // 适应SwiftUI的坐标系，逆时针实际上是顺时针
        )
        
        return path
    }
}
