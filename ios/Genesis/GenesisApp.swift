//
//  GenesisApp.swift
//  Genesis
//
//  Created by jumpei ono on 2026/03/19.
//

import SwiftUI
import AppTrackingTransparency

@main
struct GenesisApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @State private var hasRequestedATT = false

    var body: some Scene {
        WindowGroup {
            TitleView()
        }
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active, !hasRequestedATT else { return }
            hasRequestedATT = true
            Task {
                // ATTダイアログはscene activeになり切ってから呼ばないと無音で失敗するため少し待つ
                try? await Task.sleep(for: .milliseconds(500))
                await requestTrackingAuthorizationIfNeeded()
                AdManager.shared.startIfNeeded()
            }
        }
    }

    private func requestTrackingAuthorizationIfNeeded() async {
        guard ATTrackingManager.trackingAuthorizationStatus == .notDetermined else { return }
        _ = await ATTrackingManager.requestTrackingAuthorization()
    }
}
