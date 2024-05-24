//
//  AspectVGrid.swift
//  Memorize
//
//  Created by 买祥 on 2024/5/22.
//

import SwiftUI

/// 一个根据指定宽高比自适应调整的网格视图组件。
///
/// 此视图使用 `LazyVGrid` 创建一个网格布局，其中项目的尺寸会自动调整以保持给定的宽高比。
/// - Parameters:
///   - Item: 必须符合 `Identifiable` 协议的项目类型。
///   - ItemView: 用于呈现每个项目的视图类型，是一个符合 `View` 协议的泛型。
struct AspectVGrid<Item: Identifiable, ItemView: View>: View {
    /// 网格中的项目数组。
    let items: [Item]
    /// 每个项目的宽高比。
    var aspectRatio: CGFloat = 1
    /// 一个闭包，接受一个项目并返回一个视图用于该项目的呈现。
    let content: (Item) -> ItemView
    
    /// 初始化网格视图。
    /// - Parameters:
    ///   - items: 要显示的项目数组。
    ///   - aspectRatio: 每个项目的宽高比。
    ///   - content: 一个视图构建器闭包，用于为每个项目生成视图。
    init(_ items: [Item], aspectRatio: CGFloat, @ViewBuilder content: @escaping (Item) -> ItemView) {
        self.items = items
        self.aspectRatio = aspectRatio
        self.content = content
    }
    
    var body: some View {
        GeometryReader { geometry in
            let gridItemSize = gridItemWidthThatFits(
                count: items.count,
                size: geometry.size,
                atAspectRatio: aspectRatio
            )
            
            let columns: [GridItem] = [
                GridItem(.adaptive(minimum: gridItemSize), spacing: 0)
            ]
            
            // 打印网格的信息
            debugGridInfo(geometry, gridItemSize)
            
            return LazyVGrid(columns: columns, spacing: 0) {
                ForEach(items) { item in
                    content(item)
                        .aspectRatio(aspectRatio, contentMode: .fit)
                }
            }
        }
    }
    
    /// 计算适合于可用空间并保持指定宽高比的网格项目宽度。
    /// - Parameters:
    ///   - count: 网格中项目的总数。
    ///   - size: 可用的空间尺寸。
    ///   - aspectRatio: 指定的项目宽高比。
    /// - Returns: 计算得出的每个网格项目的适宜宽度。
    private func gridItemWidthThatFits(
        count: Int,
        size: CGSize,
        atAspectRatio aspectRatio: CGFloat
    ) -> CGFloat {
        let count = CGFloat(count)
        var columnCount = 1.0
        
        repeat {
            let width = size.width / columnCount
            let height = width / aspectRatio
            
            let rowCount = (count / columnCount).rounded(.up)
            if rowCount * height < size.height {
                return (size.width / columnCount).rounded(.down)
            }
            columnCount += 1
        } while columnCount < count
        
        return min(size.width / count, size.height * aspectRatio).rounded(.down)
    }
}


extension AspectVGrid {
    /// 在 debug 环境打印网格的详细信息。
    /// - Parameters:
    ///   - geometry: 当前视图的几何信息。
    ///   - gridItemSize: 网格项目的尺寸。
    private func debugGridInfo(_ geometry: GeometryProxy, _ gridItemSize: CGFloat) {
        let numberOfColumns = Int(geometry.size.width / gridItemSize)
        let numberOfRows = (items.count + numberOfColumns - 1) / numberOfColumns
        // Grid 的信息
        debugPrint("""
                           [AspectVGrid]:
                           - screen size: \(UIScreen.main.bounds.size)
                           - geometry size: \(geometry.size)
                           - gridItem size: \(gridItemSize)
                           - grid size: (rows: \(numberOfRows), cols: \(numberOfColumns))
                           """)
        
        // 网格内容的信息
        // stride 用于生成一个步进的序列
        for i in stride(from: 0, to: items.count, by: numberOfColumns){
            if i == 0 {
                debugPrint("- grid content:")}
            let itemsInRow = items[i..<min(i + numberOfColumns, items.count)]
            debugPrint(itemsInRow.map { "\($0)" }.joined(separator: " | "))
        }
    }
    
}
