import SwiftUI

struct ContentView: View {
    @State private var isAccelerating = false
    @State private var joystickX: Double = 0
    @State private var joystickY: Double = 0

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
                isTurningRight: .constant(isTurningRight)
            )
            .edgesIgnoringSafeArea(.all)

            VStack {
                Text("B5用紙をカメラに向けてください")
                    .font(.headline)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                Spacer()

                HStack(alignment: .bottom, spacing: 40) {
                    VStack {
                        Text("移動")
                            .font(.caption)
                            .foregroundColor(.white)
                        Joystick(xAxis: $joystickX, yAxis: $joystickY)
                    }

                    Spacer()

                    VStack {
                        Text("アクセル")
                            .font(.caption)
                            .foregroundColor(.white)
                        Button(action: {}) {
                            Text("A")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 120, height: 120)
                                .background(isAccelerating ? Color.green : Color.green.opacity(0.6))
                                .cornerRadius(60)
                        }
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { _ in isAccelerating = true }
                                .onEnded { _ in isAccelerating = false }
                        )
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 50)
            }
        }
    }
}

#Preview {
    ContentView()
}
