//
//  Settings.swift
//  Genesis
//
//  Created by jumpei ono on 2026/03/20.
//

import Foundation
import Combine

/// アプリ全体の設定を管理するクラス
class AppSettings: ObservableObject {
    static let shared = AppSettings()

    /// ステアリング感度（0.01〜0.1）
    @Published var steeringSensitivity: Double {
        didSet { UserDefaults.standard.set(steeringSensitivity, forKey: "steeringSensitivity") }
    }

    /// 最大速度（0.05〜0.5）
    @Published var maxSpeed: Double {
        didSet { UserDefaults.standard.set(maxSpeed, forKey: "maxSpeed") }
    }

    /// 加速度（0.001〜0.02）
    @Published var acceleration: Double {
        didSet { UserDefaults.standard.set(acceleration, forKey: "acceleration") }
    }

    private init() {
        let defaults = UserDefaults.standard

        // 初回起動時のデフォルト値を登録
        defaults.register(defaults: [
            "steeringSensitivity": 0.05,
            "maxSpeed": 0.2,
            "acceleration": 0.005
        ])

        self.steeringSensitivity = defaults.double(forKey: "steeringSensitivity")
        self.maxSpeed = defaults.double(forKey: "maxSpeed")
        self.acceleration = defaults.double(forKey: "acceleration")
    }

    /// デフォルト値にリセット
    func resetToDefaults() {
        steeringSensitivity = 0.05
        maxSpeed = 0.2
        acceleration = 0.005
    }
}
