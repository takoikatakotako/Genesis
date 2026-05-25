//
//  AdManager.swift
//  Genesis
//

import GoogleMobileAds

@MainActor
final class AdManager {
    static let shared = AdManager()

    // Google公式のテスト用バナー広告ユニットID
    private static let testBannerAdUnitID = "ca-app-pub-3940256099942544/2934735716"

    static var bannerAdUnitID: String {
        if shouldUseTestAds {
            return testBannerAdUnitID
        }
        return Bundle.main.object(forInfoDictionaryKey: "AdMobBannerAdUnitID") as? String ?? testBannerAdUnitID
    }

    /// Debug ビルドまたは TestFlight 配信時は true。App Store 本番のみ false
    private static var shouldUseTestAds: Bool {
        #if DEBUG
        return true
        #else
        return Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
        #endif
    }

    private var isStarted = false

    private init() {}

    func startIfNeeded() {
        guard !isStarted else { return }
        isStarted = true
        MobileAds.shared.start()
    }
}
