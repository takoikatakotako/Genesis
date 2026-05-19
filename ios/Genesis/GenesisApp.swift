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
    var body: some Scene {
        WindowGroup {
            TitleView()
                .task {
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
