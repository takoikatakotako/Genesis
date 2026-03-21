//
//  SpeedMeter.swift
//  Genesis
//
//  Created by jumpei ono on 2026/03/20.
//

import SwiftUI

/// 速度メーター（縦バー表示）
struct SpeedMeter: View {
    let speedRatio: Double // 0.0〜1.0

    private let barHeight: CGFloat = 100
    private let barWidth: CGFloat = 12

    private var barColor: Color {
        if speedRatio > 0.8 {
            return .red
        } else if speedRatio > 0.5 {
            return .yellow
        } else {
            return .green
        }
    }

    var body: some View {
        VStack(spacing: 4) {
            Text("\(Int(speedRatio * 100))")
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(.white)

            ZStack(alignment: .bottom) {
                // 背景
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white.opacity(0.2))
                    .frame(width: barWidth, height: barHeight)

                // メーターバー
                RoundedRectangle(cornerRadius: 4)
                    .fill(barColor)
                    .frame(width: barWidth, height: barHeight * speedRatio)
            }

            Text("km/h")
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.6))
        }
    }
}

#Preview {
    ZStack {
        Color.black
        HStack(spacing: 20) {
            SpeedMeter(speedRatio: 0.3)
            SpeedMeter(speedRatio: 0.6)
            SpeedMeter(speedRatio: 0.9)
        }
    }
}
