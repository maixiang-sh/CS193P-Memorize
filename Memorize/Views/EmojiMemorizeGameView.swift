//
//  ContentView.swift
//  Memorize
//
//  Created by 买祥 on 2024/4/30.
//

import SwiftUI

struct EmojiMemorizeGameView: View {
    @Environment(EmojiMemorizeGame.self) private var viewModel
    
    private let aspectRatio: CGFloat = 2/3
    private let spacing: CGFloat = 4
    
    var body: some View {
        VStack {
            cards
                .foregroundColor(viewModel.color)
            
            Button {
                withAnimation(.bouncy) {
                    viewModel.reset()
                }
            } label: {
                VStack {
                    Image(systemName: "dice")
                        .imageScale(.large)
                    Text("New Game")
                }
            }
        }
        .padding()
    }
    
    @ViewBuilder
    var cards: some View {
        AspectVGrid(viewModel.cards, aspectRatio: aspectRatio) { card in
            CardView(card)
                .padding(spacing)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 1)) {
                        viewModel.choose(card)
                    }
                }
        }
    }
}

#Preview {
    EmojiMemorizeGameView()
        .environment(EmojiMemorizeGame())
}
