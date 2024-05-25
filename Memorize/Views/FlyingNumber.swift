//
//  FlyingNumber.swift
//  Memorize
//
//  Created by 买祥 on 2024/5/24.
//

import SwiftUI

struct FlyingNumber: View, Animatable {
    let number: Int
    
    @State var offset: CGFloat = 0

    var body: some View {
        if number != 0 {
            // sign: 这是一个格式化选项，用于指定如何显示数字的符号（正号或负号）。
            Text(number, format: .number.sign(strategy: .always()))
                .font(.largeTitle)
                .foregroundStyle(number < 0 ? .red : .green) // 负数为红色，正数为绿色
                .shadow(color: .black, radius: 1.5, x: 1, y: 1)
                .offset(y: offset)
                .opacity(offset == 0 ? 1 : 0)
                .onAppear {
                    withAnimation(.easeOut(duration: 2)) {
                        offset = number < 0 ? 150 : -150
                    }
                }
                .onDisappear {
                    offset = 0
                }
        }
    }
}

#Preview {
    FlyingNumber(number: 1)
}
