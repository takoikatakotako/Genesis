//
//  SteeringIndicator.swift
//  Genesis
//
//  Created by jumpei ono on 2026/03/20.
//

import SwiftUI

/// ステアリング角度の視覚表示
struct SteeringIndicator: View {
    let steeringValue: Double // -1.0（左）〜 1.0（右）

    var body: some View {
        VStack(spacing: 4) {
            // ステアリングバー
            ZStack {
                // 背景
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 120, height: 6)

                // 中央マーク
                Rectangle()
                    .fill(Color.white.opacity(0.5))
                    .frame(width: 2, height: 10)

                // インジケーター
                Circle()
                    .fill(indicatorColor)
                    .frame(width: 14, height: 14)
                    .offset(x: steeringValue * 53)
            }
            .frame(height: 14)

            Text("STEER")
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
        }
    }

    private var indicatorColor: Color {
        if abs(steeringValue) > 0.3 {
            return .orange
        }
        return .white
    }
}

#Preview {
    ZStack {
        Color.black
        VStack(spacing: 20) {
            SteeringIndicator(steeringValue: -0.8)
            SteeringIndicator(steeringValue: 0.0)
            SteeringIndicator(steeringValue: 0.5)
        }
    }
}
