//
//  MemorizeApp.swift
//  Memorize
//
//  Created by 买祥 on 2024/4/30.
//

import SwiftUI

@main

struct MemorizeApp: App {
    @State var emojiMemorizeGame = EmojiMemorizeGame()
    
    var body: some Scene {
        WindowGroup {
            EmojiMemorizeGameView()
                .environment(emojiMemorizeGame)
        }
    }
}
