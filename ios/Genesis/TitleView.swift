//
//  TitleView.swift
//  Genesis
//
//  Created by jumpei ono on 2026/03/20.
//

import SwiftUI

struct TitleView: View {
    @State private var isShowingAR = false
    @State private var titleOpacity: Double = 0
    @State private var buttonOpacity: Double = 0

    var body: some View {
        ZStack {
            // 背景
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.15),
                    Color(red: 0.1, green: 0.1, blue: 0.3)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 60) {
                Spacer()

                // タイトル
                VStack(spacing: 12) {
                    Text("GENESIS")
                        .font(.system(size: 52, weight: .bold, design: .default))
                        .tracking(12)
                        .foregroundColor(.white)

                    Text("AR RC Car")
                        .font(.system(size: 18, weight: .light))
                        .tracking(4)
                        .foregroundColor(.white.opacity(0.6))
                }
                .opacity(titleOpacity)

                Spacer()

                // スタートボタン
                Button {
                    isShowingAR = true
                } label: {
                    Text("START")
                        .font(.system(size: 20, weight: .semibold))
                        .tracking(6)
                        .foregroundColor(.white)
                        .frame(width: 220, height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 28)
                                .stroke(Color.white.opacity(0.6), lineWidth: 1)
                        )
                }
                .opacity(buttonOpacity)

                Spacer()
                    .frame(height: 80)
            }
        }
        .onAppear {
            withAnimation(.easeIn(duration: 1.0)) {
                titleOpacity = 1.0
            }
            withAnimation(.easeIn(duration: 1.0).delay(0.5)) {
                buttonOpacity = 1.0
            }
        }
        .fullScreenCover(isPresented: $isShowingAR) {
            ContentView()
        }
    }
}

#Preview {
    TitleView()
}
