import SwiftUI
import GoogleMobileAds

struct DriveView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = DriveViewModel()

    var body: some View {
        ZStack {
            ARViewContainer(
                isAccelerating: $viewModel.isAccelerating,
                isBraking: $viewModel.isBraking,
                steeringX: $viewModel.joystickX,
                isReverse: $viewModel.isReversing,
                hasPlacedCar: $viewModel.hasPlacedCar,
                hasDetectedPlane: $viewModel.hasDetectedPlane,
                errorMessage: $viewModel.errorMessage,
                currentSpeedRatio: $viewModel.currentSpeedRatio
            )
            .edgesIgnoringSafeArea(.all)

            VStack {
                // 戻るボタン
                HStack {
                    Button {
                        showInterstitialAndDismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.black.opacity(0.4))
                            .clipShape(Circle())
                    }
                    .padding(.leading, 16)
                    .padding(.top, 16)
                    Spacer()
                }

                // ステータステキスト
                if !viewModel.hasPlacedCar {
                    PlaneDetectionStatusView(hasDetectedPlane: viewModel.hasDetectedPlane)
                }
                Spacer()

                // 操作パネル（車配置後のみ表示）
                if viewModel.hasPlacedCar {
                    HStack(alignment: .bottom, spacing: 20) {
                        // ステアリング
                        VStack(spacing: 8) {
                            SteeringIndicator(steeringValue: viewModel.joystickX)
                                .padding(.bottom, 4)
                            Joystick(xAxis: $viewModel.joystickX, yAxis: $viewModel.joystickY)
                        }

                        Spacer()

                        // スピードメーター + アクセル + バック
                        VStack(alignment: .trailing, spacing: 8) {
                            SpeedMeter(speedRatio: viewModel.currentSpeedRatio)
                            ZStack(alignment: .bottomLeading) {
                                // アクセルボタン（大）
                                PedalButton(
                                    icon: "arrow.up",
                                    color: .green,
                                    isPressed: viewModel.isAccelerating,
                                    size: 110
                                ) { pressed in
                                    viewModel.isAccelerating = pressed
                                }

                                // バックボタン（小・左下）
                                PedalButton(
                                    icon: "arrow.uturn.backward",
                                    color: .orange,
                                    isPressed: viewModel.isReversing,
                                    size: 56
                                ) { pressed in
                                    viewModel.isReversing = pressed
                                }
                                .offset(x: -50, y: 10)
                            }
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 40)
                }
            }
        }
        .task {
            await AdManager.shared.loadInterstitialAd()
        }
        .alert("エラー", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.clearError() } }
        )) {
            Button("OK") { viewModel.clearError() }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private func showInterstitialAndDismiss() {
        guard let rootVC = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows.first?.rootViewController else {
            dismiss()
            return
        }
        AdManager.shared.showInterstitialAd(from: rootVC)
        dismiss()
    }
}

// MARK: - カメラ権限拒否時の表示

struct CameraPermissionDeniedView: View {
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 24) {
                Image(systemName: "camera.slash.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.white.opacity(0.6))

                VStack(spacing: 8) {
                    Text("カメラへのアクセスが必要です")
                        .font(.title3.bold())
                        .foregroundColor(.white)

                    Text("AR Drive はARKit を使用するためカメラの許可が必要です。設定アプリからカメラへのアクセスを許可してください。")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Button {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Text("設定アプリを開く")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }

                Button {
                    onDismiss()
                } label: {
                    Text("戻る")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.6))
                }
            }
        }
    }
}

// MARK: - 平面検知ステータス表示

struct PlaneDetectionStatusView: View {
    let hasDetectedPlane: Bool

    var body: some View {
        HStack(spacing: 10) {
            if hasDetectedPlane {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text("平面を検知しました！タップして車を配置")
            } else {
                ProgressView()
                    .tint(.white)
                Text("平面を探しています...")
            }
        }
        .font(.headline)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.black.opacity(0.7))
        .foregroundColor(.white)
        .cornerRadius(10)
        .animation(.easeInOut, value: hasDetectedPlane)
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

#Preview("操作パネル") {
    ZStack {
        Image(.previewRoomSample)
            .resizable()
            .frame(width: 393, height: 852)
            .scaledToFill()
            .clipped()

        VStack {
            Spacer()

            HStack(alignment: .bottom, spacing: 20) {
                VStack(spacing: 8) {
                    SteeringIndicator(steeringValue: 0.3)
                        .padding(.bottom, 4)
                    Joystick(xAxis: .constant(0), yAxis: .constant(0))
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 8) {
                    SpeedMeter(speedRatio: 0.5)
                    ZStack(alignment: .bottomLeading) {
                        PedalButton(icon: "arrow.up", color: .green, isPressed: false, size: 110) { _ in }
                        PedalButton(icon: "arrow.uturn.backward", color: .orange, isPressed: false, size: 56) { _ in }
                            .offset(x: -50, y: 10)
                    }
                }
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
        .frame(width: 393, height: 852)
    }
    .frame(width: 393, height: 852)
    .clipped()
}
