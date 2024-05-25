//
//  Theme.swift
//  Memorize
//
//  Created by 买祥 on 2024/5/22.
//

import SwiftUI

struct Theme {
    let name: String
    let emojis: [String]
    let numberOfPairs: Int
    let color: Color
}


struct ThemeManager {
    private(set) var themes: [Theme]
    
    init(themes: [Theme] = ThemeManager.defaultThemes) {
        self.themes = themes
    }
    
    mutating func add(theme: Theme) {
        themes.append(theme)
    }
}

extension ThemeManager {
    static let defaultThemes = [Theme.animals,
                                Theme.foods,
                                Theme.fruits,
                                Theme.products,
                                Theme.sports,
                                Theme.cars,
                                Theme.landmarks]
}

extension Theme {
    static let fruits = Theme(name: "fruits",
                              emojis: ["🍎", "🍌", "🍇", "🍈", "🍓", "🍑", "🍉", "🥝", "🍐", "🍏", "🍊", "🍋", "🫐", "🥭", "🍒", "🥥", "🍋‍🟩", "🍍"],
                              numberOfPairs: 10,
                              color: .indigo)
    static let foods = Theme(name: "foods",
                             emojis: ["🥐", "🥯", "🍞", "🥖", "🥨", "🥞", "🧇", "🍗", "🌭", "🍔", "🍟", "🍕", "🥪", "🥙", "🧆", "🌮", "🌯", "🫔", "🥗", "🥘", "🍣", "🍜", "🍱", "🥮", "🍩", "🍡"],
                             numberOfPairs: 10,
                             color: .green)
    
    static let animals = Theme(name: "animals",
                               emojis: ["🐶", "🐱", "🐭", "🐹", "🐰", "🦊", "🐻", "🐼", "🐻‍❄️", "🐨", "🐯", "🦁", "🐮", "🐷", "🐸", "🐵"],
                               numberOfPairs: 10,
                               color: .purple)
    
    static let products = Theme(name: "products",
                                emojis: ["⌚️", "📱", "💻", "🖥️", "🎧", "🖨️", "📷", "🎥", "🎙️", "📟", "☎️", "🕹️", "📼", "📠", "📻", "💽", "📺"],
                                numberOfPairs: 10,
                                color: .mint)
    
    static let sports = Theme(name: "sports",
                              emojis: ["⚽️", "🏀", "🏈", "⚾️", "🎾", "🏐", "🏉", "🥏", "🎱", "🪀", "🏓"],
                              numberOfPairs: 10,
                              color: .pink)
    static let cars = Theme(name: "cars",
                            emojis: ["🚗", "🚕", "🚙", "🚌", "🚎", "🏎️", "🚓", "🚑", "🚒", "🚐", "🛻", "🚚", "🚛", "🚜"],
                            numberOfPairs: 10,
                            color: .teal)
    static let landmarks = Theme(name: "landmarks",
                                 emojis: ["🗿", "🗽", "🗼", "🏯", "🗻", "🕋", "⛩️", "🕌", "🕍", "⛪️", "🏛️", "🛕", "🏰"],
                                 numberOfPairs: 10,
                                 color: .brown)
}
