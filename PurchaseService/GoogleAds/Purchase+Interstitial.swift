//
//  Purchase+Interstitial.swift
//  PurchaseService
//
//  Created by Wataru Suzuki on 2019/08/28.
//  Copyright © 2019 Wataru Suzuki. All rights reserved.
//

import Foundation
import GoogleMobileAds

extension PurchaseService: GADInterstitialDelegate {
    
    func loadInterstitial(unitId: String) {
        #if DEBUG
        interstitialAd = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910")
        #else
        interstitialAd = GADInterstitial(adUnitID: unitId)
        #endif
        interstitialAd?.delegate = self
    }
    
    func showInterstitial(rootViewController: UIViewController) {
        if let ad = interstitialAd, ad.isReady {
            ad.present(fromRootViewController: rootViewController)
        }
    }
    
    // MARK: - GADInterstitialDelegate
}
