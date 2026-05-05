//
//  TitleView.swift
//  Genesis
//
//  Created by jumpei ono on 2026/03/20.
//

import SwiftUI
import SceneKit

struct TitleView: View {
    @State private var viewModel = TitleViewModel()

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                // 背景
                Image(.background)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                // 設定アイコン（右上）
                HStack {
                    Spacer()
                    Button {
                        viewModel.isShowingSettings = true
                    } label: {
                        Image(.settingIcon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 52, height: 52)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)
                .opacity(viewModel.buttonOpacity)

                // タイトル
                VStack(spacing: 8) {
                    Text("AR DRIVE")
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .tracking(4)
                        .foregroundColor(Color(red: 0.25, green: 0.45, blue: 0.25))

                    Text("いっしょに、どこまでも。")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(Color(red: 0.35, green: 0.5, blue: 0.35))
                        .padding(.top, 8)
                }
                .padding(.top, 140)
                .opacity(viewModel.titleOpacity)

                // 選択中の車（草に重なる位置に絶対配置）
                CarPreviewView(modelFileName: "miniCooperbake")
                    .frame(width: 500, height: 500)
                    .position(x: geo.size.width * 0.6, y: geo.size.height * 0.65)
                    .opacity(viewModel.titleOpacity)

                // うさぎ（草の上）
                HStack(alignment: .bottom) {
                    Image(.brownRabbit)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .padding(.leading, 24)

                    Spacer()

                    Image(.whiteRabbit)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 90, height: 90)
                        .padding(.trailing, 24)
                        .padding(.bottom, 12)
                }
                .frame(width: geo.size.width)
                .position(x: geo.size.width / 2, y: geo.size.height * 0.73)
                .opacity(viewModel.titleOpacity)

                // ドライブスタートボタン
                Button {
                    viewModel.requestCameraPermission()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 16, weight: .semibold))
                        Text("ドライブスタート")
                            .font(.system(size: 20, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(width: 260, height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 28)
                            .fill(Color(red: 0.85, green: 0.45, blue: 0.5))
                    )
                }
                .position(x: geo.size.width / 2, y: geo.size.height * 0.88)
                .opacity(viewModel.buttonOpacity)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            viewModel.startAnimations()
        }
        .fullScreenCover(isPresented: $viewModel.isShowingAR) {
            ContentView()
        }
        .fullScreenCover(isPresented: $viewModel.isShowingCameraPermissionDenied) {
            CameraPermissionDeniedView {
                viewModel.isShowingCameraPermissionDenied = false
            }
        }
        .sheet(isPresented: $viewModel.isShowingSettings) {
            SettingsView()
        }
    }
}

struct CarPreviewView: UIViewRepresentable {
    let modelFileName: String

    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.isOpaque = false
        scnView.backgroundColor = .clear
        scnView.autoenablesDefaultLighting = true
        scnView.allowsCameraControl = false
        scnView.antialiasingMode = .multisampling4X
        loadModel(into: scnView)
        return scnView
    }

    func updateUIView(_ scnView: SCNView, context: Context) {}

    private func loadModel(into scnView: SCNView) {
        guard let url = Bundle.main.url(forResource: modelFileName, withExtension: "usdz"),
              let scene = try? SCNScene(url: url, options: nil) else { return }

        scene.background.contents = UIColor.clear

        let wrapper = SCNNode()
        scene.rootNode.childNodes.forEach {
            $0.removeFromParentNode()
            wrapper.addChildNode($0)
        }

        wrapper.eulerAngles = SCNVector3(
            x: -Float.pi / 2,
            y: -Float.pi / 8,
            z: 0
        )

        let (minB, maxB) = wrapper.boundingBox
        let maxDim = max(maxB.x - minB.x, maxB.y - minB.y, maxB.z - minB.z)
        let lookAtY = minB.y + (maxB.y - minB.y) * 0.2

        scene.rootNode.addChildNode(wrapper)

        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, Float(lookAtY) + maxDim * 0.4, maxDim * 1.5)
        cameraNode.look(at: SCNVector3(0, lookAtY, 0))
        scene.rootNode.addChildNode(cameraNode)

        scnView.scene = scene
        scnView.pointOfView = cameraNode
    }
}

#Preview {
    TitleView()
}
