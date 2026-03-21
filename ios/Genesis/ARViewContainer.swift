import SwiftUI
import RealityKit
import ARKit

struct ARViewContainer: UIViewRepresentable {
    @Binding var isAccelerating: Bool
    @Binding var isBraking: Bool
    @Binding var isTurningLeft: Bool
    @Binding var isTurningRight: Bool
    @Binding var hasPlacedCar: Bool
    @Binding var errorMessage: String?
    @Binding var currentSpeedRatio: Double

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)

        // AR設定（水平面検知）
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]

        arView.session.run(config)

        // デリゲート設定
        context.coordinator.arView = arView
        arView.session.delegate = context.coordinator

        // ARViewのデフォルトジェスチャーを無効化（タップの横取りを防ぐ）
        arView.gestureRecognizers?.forEach { arView.removeGestureRecognizer($0) }

        // タップジェスチャーで車を配置
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        arView.addGestureRecognizer(tapGesture)

        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        context.coordinator.isAccelerating = isAccelerating
        context.coordinator.isBraking = isBraking
        context.coordinator.isTurningLeft = isTurningLeft
        context.coordinator.isTurningRight = isTurningRight
        context.coordinator.hasPlacedCarBinding = $hasPlacedCar
        context.coordinator.errorMessageBinding = $errorMessage
        context.coordinator.currentSpeedRatioBinding = $currentSpeedRatio
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, ARSessionDelegate {
        weak var arView: ARView?
        var hasPlacedCarBinding: Binding<Bool>?
        var errorMessageBinding: Binding<String?>?
        var currentSpeedRatioBinding: Binding<Double>?
        private var hasPlacedCar = false
        private var carEntity: Entity?
        private var carAnchor: AnchorEntity?
        private var currentSpeed: Float = 0.0
        private var currentRotation: Float = 0.0
        // モデルの向き補正（X軸で-90度回転して起こす + Y軸180度でモデルの前後反転）
        private let modelUpCorrection = simd_quatf(angle: .pi, axis: SIMD3<Float>(0, 1, 0)) * simd_quatf(angle: -.pi / 2, axis: SIMD3<Float>(1, 0, 0))
        private var updateTimer: Timer?
        private var planeEntities: [ARAnchor: (AnchorEntity, ModelEntity)] = [:]

        var isAccelerating: Bool = false {
            didSet { updateSpeed() }
        }
        var isBraking: Bool = false {
            didSet { updateSpeed() }
        }
        var isTurningLeft: Bool = false
        var isTurningRight: Bool = false

        private var maxSpeed: Float { Float(AppSettings.shared.maxSpeed) }
        private var acceleration: Float { Float(AppSettings.shared.acceleration) }
        private var deceleration: Float { acceleration * 4 }
        private var rotationSpeed: Float { Float(AppSettings.shared.steeringSensitivity) }

        // エラーをUIに通知
        private func reportError(_ message: String) {
            print("❌ \(message)")
            DispatchQueue.main.async {
                self.errorMessageBinding?.wrappedValue = message
            }
        }

        func session(_ session: ARSession, didFailWithError error: Error) {
            reportError("ARセッションエラー: \(error.localizedDescription)")
        }

        // 検知した平面をハイライト表示
        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            guard !hasPlacedCar, let arView = arView else { return }

            for anchor in anchors {
                guard let planeAnchor = anchor as? ARPlaneAnchor,
                      planeAnchor.alignment == .horizontal else { continue }

                let extent = planeAnchor.extent
                let mesh = MeshResource.generatePlane(width: extent.x, depth: extent.z)
                var material = SimpleMaterial()
                material.color = .init(tint: UIColor(red: 0.3, green: 0.7, blue: 1.0, alpha: 0.3))
                let planeEntity = ModelEntity(mesh: mesh, materials: [material])

                let anchorEntity = AnchorEntity(anchor: planeAnchor)
                anchorEntity.addChild(planeEntity)
                arView.scene.addAnchor(anchorEntity)

                planeEntities[anchor] = (anchorEntity, planeEntity)
            }
        }

        // 平面サイズの更新に追従
        func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
            guard !hasPlacedCar else { return }

            for anchor in anchors {
                guard let planeAnchor = anchor as? ARPlaneAnchor,
                      let (_, planeEntity) = planeEntities[anchor] else { continue }

                let extent = planeAnchor.extent
                let newMesh = MeshResource.generatePlane(width: extent.x, depth: extent.z)
                planeEntity.model?.mesh = newMesh
            }
        }

        // 削除された平面のハイライトを除去
        func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
            for anchor in anchors {
                guard let (anchorEntity, _) = planeEntities.removeValue(forKey: anchor) else { continue }
                anchorEntity.removeFromParent()
            }
        }

        // 全てのハイライトを削除
        private func removeAllPlaneHighlights() {
            for (_, (anchorEntity, _)) in planeEntities {
                anchorEntity.removeFromParent()
            }
            planeEntities.removeAll()
        }

        @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
            guard !hasPlacedCar, let arView = arView else {
                print("🔍 タップ無視: hasPlacedCar=\(hasPlacedCar), arView=\(arView != nil)")
                return
            }

            let location = recognizer.location(in: arView)
            print("🔍 タップ位置: \(location)")

            // レイキャストで平面上の位置を取得（検知済み平面 → 推定平面の順にフォールバック）
            var results = arView.raycast(from: location, allowing: .existingPlaneGeometry, alignment: .horizontal)
            if results.isEmpty {
                results = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .horizontal)
            }

            guard let result = results.first else {
                print("🔍 レイキャスト結果なし")
                return
            }

            print("🔍 車を配置します")
            placeCar(at: result.worldTransform)
            removeAllPlaneHighlights()
            hasPlacedCar = true
            DispatchQueue.main.async {
                self.hasPlacedCarBinding?.wrappedValue = true
            }
        }

        private func placeCar(at worldTransform: simd_float4x4) {
            guard let arView = arView else { return }

            guard let url = Bundle.main.url(forResource: "miniCooperbake", withExtension: "usdz") else {
                reportError("車のモデルデータが見つかりません")
                return
            }

            do {
                let entity = try Entity.load(contentsOf: url)

                // スケーリング
                let bounds = entity.visualBounds(relativeTo: nil)
                let modelSize = bounds.extents
                let maxDimension = max(modelSize.x, modelSize.z)
                let targetSize: Float = 0.075
                let scaleFactor = targetSize / maxDimension
                entity.scale = SIMD3<Float>(repeating: scaleFactor)

                // タップ位置にアンカーを作成
                let anchorEntity = AnchorEntity(world: worldTransform)

                entity.position = SIMD3<Float>(0, 0, 0)
                entity.orientation = modelUpCorrection

                self.carEntity = entity
                self.carAnchor = anchorEntity
                anchorEntity.addChild(entity)
                arView.scene.addAnchor(anchorEntity)

                startAnimationTimer()
            } catch {
                reportError("車のモデル読み込みに失敗しました: \(error.localizedDescription)")
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

            // 速度比率をUIに通知
            DispatchQueue.main.async {
                self.currentSpeedRatioBinding?.wrappedValue = Double(self.currentSpeed / self.maxSpeed)
            }

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
