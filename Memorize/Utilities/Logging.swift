//
//  Logging.swift
//  Memorize
//
//  Created by 买祥 on 2024/5/22.
//

import Foundation

/// 打印调试信息，仅在 Debug 环境下有效
/// - Parameter message: 要打印的消息
func debugPrint(_ message: String) {
    #if DEBUG
    print(message)
    #endif
}
