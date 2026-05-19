//
//  AdManager.swift
//  Genesis
//

import GoogleMobileAds

@MainActor
class AdManager: NSObject, ObservableObject {
    static let shared = AdManager()

    // テスト用ID。本番リリース時は実際の広告ユニットIDに差し替える
    #if DEBUG
    static let bannerAdUnitID = "ca-app-pub-3940256099942544/2934735716"
    static let interstitialAdUnitID = "ca-app-pub-3940256099942544/4411468910"
    #else
    static let bannerAdUnitID = "YOUR_BANNER_AD_UNIT_ID"
    static let interstitialAdUnitID = "YOUR_INTERSTITIAL_AD_UNIT_ID"
    #endif

    private var interstitialAd: InterstitialAd?

    override private init() {
        super.init()
    }

    func loadInterstitialAd() async {
        do {
            interstitialAd = try await InterstitialAd.load(
                with: AdManager.interstitialAdUnitID,
                request: Request()
            )
        } catch {
            print("インタースティシャル広告のロード失敗: \(error)")
        }
    }

    func showInterstitialAd(from viewController: UIViewController) {
        guard let ad = interstitialAd else { return }
        ad.present(from: viewController)
        interstitialAd = nil
        Task { await loadInterstitialAd() }
    }
}
