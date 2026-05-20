//
//  AdManager.swift
//  Genesis
//

import GoogleMobileAds

@MainActor
final class AdManager {
    static let shared = AdManager()

    static var bannerAdUnitID: String {
        Bundle.main.object(forInfoDictionaryKey: "AdMobBannerAdUnitID") as? String ?? ""
    }

    private var isStarted = false

    private init() {}

    func startIfNeeded() {
        guard !isStarted else { return }
        isStarted = true
        MobileAds.shared.start()
    }
}
