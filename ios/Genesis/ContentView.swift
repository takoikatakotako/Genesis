import SwiftUI

struct ContentView: View {
    @State private var isAccelerating = false
    @State private var isBraking = false
    @State private var isReversing = false
    @State private var joystickX: Double = 0
    @State private var joystickY: Double = 0
    @State private var hasPlacedCar = false
    @State private var errorMessage: String?
    @State private var currentSpeedRatio: Double = 0

    var body: some View {
        ZStack {
            ARViewContainer(
                isAccelerating: $isAccelerating,
                isBraking: $isBraking,
                steeringX: $joystickX,
                isReverse: $isReversing,
                hasPlacedCar: $hasPlacedCar,
                errorMessage: $errorMessage,
                currentSpeedRatio: $currentSpeedRatio
            )
            .edgesIgnoringSafeArea(.all)

            VStack {
                // ステータステキスト
                if !hasPlacedCar {
                    Text("平面を検知中…タップで車を配置")
                        .font(.headline)
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                Spacer()

                // 操作パネル（車配置後のみ表示）
                if hasPlacedCar {
                    // ステアリングインジケーター
                    SteeringIndicator(steeringValue: joystickX)
                        .padding(.bottom, 8)

                    HStack(alignment: .bottom, spacing: 20) {
                        // ジョイスティック（ステアリング）+ 速度メーター
                        VStack(spacing: 8) {
                            SpeedMeter(speedRatio: currentSpeedRatio)
                            Joystick(xAxis: $joystickX, yAxis: $joystickY)
                        }

                        Spacer()

                        // アクセル + バック
                        ZStack(alignment: .bottomLeading) {
                            // アクセルボタン（大）
                            PedalButton(
                                icon: "arrow.up",
                                color: .green,
                                isPressed: isAccelerating,
                                size: 110
                            ) { pressed in
                                isAccelerating = pressed
                            }

                            // バックボタン（小・左下）
                            PedalButton(
                                icon: "arrow.uturn.backward",
                                color: .orange,
                                isPressed: isReversing,
                                size: 56
                            ) { pressed in
                                isReversing = pressed
                            }
                            .offset(x: -50, y: 10)
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 40)
                }
            }
        }
        .alert("エラー", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK") { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
    }
}

/// アクセル/ブレーキ/バック用のペダルボタン
struct PedalButton: View {
    let icon: String
    let color: Color
    let isPressed: Bool
    var size: CGFloat = 80
    let onPressChanged: (Bool) -> Void

    var body: some View {
        ZStack {
            Circle()
                .fill(isPressed ? color : color.opacity(0.4))
                .frame(width: size, height: size)

            Circle()
                .stroke(Color.white.opacity(0.4), lineWidth: 2)
                .frame(width: size, height: size)

            Image(systemName: icon)
                .font(.system(size: size * 0.3, weight: .bold))
                .foregroundColor(.white)
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in onPressChanged(true) }
                .onEnded { _ in onPressChanged(false) }
        )
    }
}

#Preview {
    ContentView()
}
