//
//  AdManager.swift
//  Genesis
//

import GoogleMobileAds

@MainActor
final class AdManager {
    static let shared = AdManager()

    // テスト用ID。本番リリース時は実際の広告ユニットIDに差し替える
    #if DEBUG
    static let bannerAdUnitID = "ca-app-pub-3940256099942544/2934735716"
    #else
    static let bannerAdUnitID = "YOUR_BANNER_AD_UNIT_ID"
    #endif

    private var isStarted = false

    private init() {}

    func startIfNeeded() {
        guard !isStarted else { return }
        isStarted = true
        MobileAds.shared.start()
    }
}
