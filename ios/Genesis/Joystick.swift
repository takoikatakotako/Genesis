import SwiftUI

struct Joystick: View {
    @Binding var xAxis: Double // -1.0（左）〜 1.0（右）
    @Binding var yAxis: Double // -1.0（後）〜 1.0（前）

    @State private var offset: CGSize = .zero

    private let baseSize: CGFloat = 150
    private let stickSize: CGFloat = 60
    private let maxDistance: CGFloat = 45 // スティックが移動できる最大距離

    var body: some View {
        ZStack {
            // ベース（外側の円）
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: baseSize, height: baseSize)

            // 十字の目印
            VStack(spacing: 0) {
                Rectangle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 2, height: baseSize)
            }
            HStack(spacing: 0) {
                Rectangle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: baseSize, height: 2)
            }

            // スティック（内側の円）
            Circle()
                .fill(Color.white.opacity(0.8))
                .frame(width: stickSize, height: stickSize)
                .offset(offset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let vector = CGSize(
                                width: value.translation.width,
                                height: value.translation.height
                            )

                            let distance = sqrt(vector.width * vector.width + vector.height * vector.height)

                            if distance > maxDistance {
                                let angle = atan2(vector.height, vector.width)
                                offset = CGSize(
                                    width: cos(angle) * maxDistance,
                                    height: sin(angle) * maxDistance
                                )
                            } else {
                                offset = vector
                            }

                            xAxis = Double(offset.width / maxDistance)
                            yAxis = -Double(offset.height / maxDistance)
                        }
                        .onEnded { _ in
                            withAnimation(.spring(response: 0.3)) {
                                offset = .zero
                                xAxis = 0
                                yAxis = 0
                            }
                        }
                )
        }
        .frame(width: baseSize, height: baseSize)
    }
}

#Preview {
    Joystick(xAxis: .constant(0), yAxis: .constant(0))
}
