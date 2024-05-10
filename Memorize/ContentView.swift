//
//  ContentView.swift
//  Memorize
//
//  Created by 买祥 on 2024/4/30.
//

import SwiftUI

struct ContentView: View {
    let emojis = ["🍎", "🍌", "🍇", "🍈", "🍓", "🍑"]
    @State var cardCount = 4
    
    var body: some View {
        VStack {
            cards
            Spacer()
            cardCountAdjusters
        }
        .padding()
    }
    
    /// 一组卡片
    var cards: some View {
        // 使用 GridItem(.adaptive(minimum: 60)) 意味着我们希望网格尽可能多地容纳每行的项目，每个项目的最小大小为 60 点。
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))]) {
            ForEach(0..<cardCount, id: \.self) { index in
                CardView(content: emojis[index])
                    .aspectRatio(2/3, contentMode: .fit)
            }
        }
        .foregroundColor(.orange)
    }
    
    
    var cardCountAdjusters: some View {
        HStack {
            cardRemover
            Spacer()
            cardAdder
        }
    }
    
    /// card 数量增减按钮
    func cardCountAdjuster(by offset: Int, symbol: String) -> some View {
        Button(action: {
            cardCount += offset
        }, label: {
            Image(systemName: symbol)
        })
        .disabled(cardCount + offset < 1 || cardCount + offset > emojis.count)
    }
    
    var cardRemover: some View {
        cardCountAdjuster(by: -1, symbol: "rectangle.fill.badge.minus")
    }
    
    var cardAdder: some View {
        cardCountAdjuster(by: +1, symbol: "rectangle.fill.badge.plus")
    }
}

#Preview {
    ContentView()
}

struct CardView: View {
    @State var isFaceUp = false
    let content: String
    
    var body: some View {
        let base = RoundedRectangle(cornerRadius: 12)
        base.fill(.white)
            .overlay {
                base.strokeBorder(lineWidth: 2) // 内部描边
                Text(content).font(.largeTitle)
                base.fill().opacity(isFaceUp ? 0 : 1)
            }
            .onTapGesture { isFaceUp.toggle() }
    }
}
