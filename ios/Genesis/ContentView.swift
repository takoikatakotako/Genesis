import SwiftUI

struct ContentView: View {
    @State private var isAccelerating = false
    @State private var joystickX: Double = 0
    @State private var joystickY: Double = 0
    @State private var hasPlacedCar = false
    @State private var errorMessage: String?
    @State private var currentSpeedRatio: Double = 0

    private var isTurningLeft: Bool {
        joystickX < -0.3
    }

    private var isTurningRight: Bool {
        joystickX > 0.3
    }

    var body: some View {
        ZStack {
            ARViewContainer(
                isAccelerating: $isAccelerating,
                isBraking: .constant(false),
                isTurningLeft: .constant(isTurningLeft),
                isTurningRight: .constant(isTurningRight),
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
                        // ジョイスティック
                        Joystick(xAxis: $joystickX, yAxis: $joystickY)

                        Spacer()

                        // 速度メーター
                        SpeedMeter(speedRatio: currentSpeedRatio)

                        // アクセルボタン
                        Button(action: {}) {
                            ZStack {
                                Circle()
                                    .fill(isAccelerating
                                        ? Color.green
                                        : Color.green.opacity(0.4))
                                    .frame(width: 100, height: 100)

                                Circle()
                                    .stroke(Color.white.opacity(0.4), lineWidth: 2)
                                    .frame(width: 100, height: 100)

                                Image(systemName: "arrow.up")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { _ in isAccelerating = true }
                                .onEnded { _ in isAccelerating = false }
                        )
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

#Preview {
    ContentView()
}
