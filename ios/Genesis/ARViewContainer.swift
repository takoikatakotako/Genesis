import SwiftUI
import RealityKit
import ARKit

struct ARViewContainer: UIViewRepresentable {
    @Binding var isAccelerating: Bool
    @Binding var isBraking: Bool
    @Binding var isTurningLeft: Bool
    @Binding var isTurningRight: Bool

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)

        // AR設定
        let config = ARWorldTrackingConfiguration()

        // AR Reference Imageを読み込み
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {
            print("❌ AR Reference Imageが見つかりません")
            return arView
        }

        config.detectionImages = referenceImages
        config.maximumNumberOfTrackedImages = 1

        arView.session.run(config)

        // デリゲート設定
        context.coordinator.arView = arView
        arView.session.delegate = context.coordinator

        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        context.coordinator.isAccelerating = isAccelerating
        context.coordinator.isBraking = isBraking
        context.coordinator.isTurningLeft = isTurningLeft
        context.coordinator.isTurningRight = isTurningRight
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, ARSessionDelegate {
        weak var arView: ARView?
        private var hasPlacedCar = false
        private var carEntity: Entity?
        private var currentSpeed: Float = 0.0
        private var currentRotation: Float = 0.0
        // モデルの向き補正（X軸で-90度回転して起こす + Y軸180度でモデルの前後反転）
        private let modelUpCorrection = simd_quatf(angle: .pi, axis: SIMD3<Float>(0, 1, 0)) * simd_quatf(angle: -.pi / 2, axis: SIMD3<Float>(1, 0, 0))
        private var updateTimer: Timer?

        var isAccelerating: Bool = false {
            didSet { updateSpeed() }
        }
        var isBraking: Bool = false {
            didSet { updateSpeed() }
        }
        var isTurningLeft: Bool = false
        var isTurningRight: Bool = false

        private let maxSpeed: Float = 0.2
        private let acceleration: Float = 0.005
        private let deceleration: Float = 0.02
        private let rotationSpeed: Float = 0.05

        func session(_ session: ARSession, didFailWithError error: Error) {
            print("❌ ARSession エラー: \(error.localizedDescription)")
        }

        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            guard !hasPlacedCar else { return }

            for anchor in anchors {
                if let imageAnchor = anchor as? ARImageAnchor {
                    placeCar(on: imageAnchor)
                    hasPlacedCar = true
                    break
                }
            }
        }

        private func placeCar(on imageAnchor: ARImageAnchor) {
            guard let arView = arView else { return }

            guard let url = Bundle.main.url(forResource: "miniCooperbake", withExtension: "usdz") else {
                print("❌ USDZファイルがバンドルに見つかりません")
                return
            }

            do {
                let entity = try Entity.load(contentsOf: url)

                // B5用紙サイズに収まるようスケーリング
                let bounds = entity.visualBounds(relativeTo: nil)
                let modelSize = bounds.extents
                let maxDimension = max(modelSize.x, modelSize.z)
                let targetSize: Float = 0.075
                let scaleFactor = targetSize / maxDimension
                entity.scale = SIMD3<Float>(repeating: scaleFactor)

                let anchorEntity = AnchorEntity(anchor: imageAnchor)

                entity.position = SIMD3<Float>(0, 0, 0)
                entity.orientation = modelUpCorrection

                self.carEntity = entity
                anchorEntity.addChild(entity)
                arView.scene.addAnchor(anchorEntity)

                startAnimationTimer()
            } catch {
                print("❌ USDZモデルの読み込みに失敗しました: \(error)")
            }
        }

        private func startAnimationTimer() {
            updateTimer?.invalidate()
            updateTimer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { [weak self] _ in
                self?.updateCarPosition()
            }
        }

        private func updateSpeed() {
            if isAccelerating {
                currentSpeed = min(currentSpeed + acceleration, maxSpeed)
            } else if isBraking {
                currentSpeed = max(currentSpeed - deceleration, 0)
            } else {
                currentSpeed = max(currentSpeed - deceleration * 0.5, 0)
            }
        }

        private func updateCarPosition() {
            guard let car = carEntity else { return }

            updateSpeed()

            if isTurningLeft {
                currentRotation += rotationSpeed
            } else if isTurningRight {
                currentRotation -= rotationSpeed
            }

            let steeringRotation = simd_quatf(angle: currentRotation, axis: SIMD3<Float>(0, 1, 0))
            car.orientation = steeringRotation * modelUpCorrection

            if currentSpeed > 0 {
                let direction = SIMD3<Float>(
                    -sin(currentRotation),
                    0,
                    -cos(currentRotation)
                )
                let movement = direction * (currentSpeed / 60.0)
                car.position += movement
            }
        }
    }
}
