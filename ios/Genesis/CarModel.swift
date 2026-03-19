//
//  CarModel.swift
//  Genesis
//
//  Created by jumpei ono on 2026/03/20.
//

import Foundation

/// 選択可能な車モデルの定義
struct CarModel: Identifiable, Equatable {
    let id: String
    let name: String
    let description: String
    let modelFileName: String
    let emoji: String

    /// 利用可能な車モデル一覧（モック）
    static let all: [CarModel] = [
        CarModel(
            id: "mini_cooper",
            name: "Mini Cooper",
            description: "コンパクトでキビキビ走る街乗りの定番",
            modelFileName: "miniCooperbake",
            emoji: "🚗"
        ),
        CarModel(
            id: "sports_car",
            name: "スポーツカー",
            description: "圧倒的な加速力とスピード",
            modelFileName: "sports_car",
            emoji: "🏎️"
        ),
        CarModel(
            id: "suv",
            name: "SUV",
            description: "安定感抜群のオフロード仕様",
            modelFileName: "suv",
            emoji: "🚙"
        ),
        CarModel(
            id: "truck",
            name: "トラック",
            description: "パワフルな大型車両",
            modelFileName: "truck",
            emoji: "🛻"
        ),
    ]
}
