//
//  ContentView.swift
//  Memorize
//
//  Created by 买祥 on 2024/4/30.
//

import SwiftUI

let fruits = ["🍎", "🍌", "🍇", "🍈", "🍓", "🍑", "🍉", "🥝", "🍐", "🍏", "🍊", "🍋", "🫐", "🥭", "🍒", "🥥", "🍋‍🟩", "🍍"]
let foods = ["🥐", "🥯", "🍞", "🥖", "🥨", "🥞", "🧇", "🍗", "🌭", "🍔", "🍟", "🍕", "🥪", "🥙", "🧆", "🌮", "🌯", "🫔", "🥗", "🥘", "🍣", "🍜", "🍱", "🥮", "🍩", "🍡"]
let animals = ["🐶", "🐱", "🐭", "🐹", "🐰", "🦊", "🐻", "🐼", "🐻‍❄️", "🐨", "🐯", "🦁", "🐮", "🐷", "🐸", "🐵"]
let sports = ["⚽️", "🏀", "🏈", "⚾️", "🎾", "🏐", "🏉", "🥏", "🎱", "🪀"]


struct ContentView: View {
    @State var emojis = fruits
    @State var currentThemeNmae = "Fruits"
    
    var body: some View {
        VStack {
            ///  Title
            Text("Memorize").font(.largeTitle).bold()
            /// Cards
            ScrollView {
                cards
            }
            Spacer()
            /// Button
            themesButtons
        }
        .padding()
    }
    
    /// 一组卡片
    var cards: some View {
        // 使用 GridItem(.adaptive(minimum: 60)) 意味着我们希望网格尽可能多地容纳每行的项目，每个项目的最小大小为 60 点。
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))]) {
            ForEach(emojis, id: \.self) { emoji in
                CardView(content: emoji)
                    .aspectRatio(2/3, contentMode: .fit)
            }
        }
        .foregroundColor(.orange)
    }
    
    
    var themesButtons: some View {
        HStack(spacing: 20) {
            themeButton(symbol: "carrot", name: "Fruits", emojis: fruits)
            themeButton(symbol: "fork.knife", name: "Foods", emojis: foods)
            themeButton(symbol: "cat", name: "Animals", emojis: animals)
            themeButton(symbol: "basketball", name: "Sports", emojis: sports)
        }
    }
    
    func themeButton(symbol: String, name: String, emojis: [String]) -> some View {
            Button {
                self.emojis = emojis.shuffled()
            } label: {
                VStack {
                    Image(systemName: symbol)
                    Text(name)
                }
            }
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
