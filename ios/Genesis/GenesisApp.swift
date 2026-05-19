//
//  GenesisApp.swift
//  Genesis
//
//  Created by jumpei ono on 2026/03/19.
//

import SwiftUI
import GoogleMobileAds
import AppTrackingTransparency

@main
struct GenesisApp: App {
    init() {
        MobileAds.shared.start()
    }

    var body: some Scene {
        WindowGroup {
            TitleView()
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                    requestTrackingAuthorization()
                }
        }
    }

    private func requestTrackingAuthorization() {
        ATTrackingManager.requestTrackingAuthorization { _ in }
    }
}
