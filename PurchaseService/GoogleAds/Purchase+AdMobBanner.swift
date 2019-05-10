//
//  Purchase+AdMobBanner.swift
//  MealDock
//
//  Created by Wataru Suzuki 2018/10/22.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

import Foundation
import GoogleMobileAds

extension PurchaseService: GADBannerViewDelegate {
    func bannerView(unitId: String, rootViewController: UIViewController) -> UIView {
        return bannerView(unitId: unitId, size: kGADAdSizeBanner, rootViewController: rootViewController)
    }
    
    func mediumSizeBanner(unitId: String, rootViewController: UIViewController) -> UIView {
        return bannerView(unitId: unitId, size: kGADAdSizeMediumRectangle, rootViewController: rootViewController)
    }
    
    private func bannerView(unitId: String, size: GADAdSize, rootViewController: UIViewController) -> UIView {
        let bannerView = GADBannerView(adSize: size)
        bannerView.delegate = self
        #if DEBUG
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        #else
        bannerView.adUnitID = unitId
        #endif
        bannerView.rootViewController = rootViewController
        bannerView.load(adRequest())
        
        //bannerViews.update(with: bannerView)
        return bannerView
    }
    
    // MARK: - GADBannerViewDelegate
    
    /// Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("adViewDidReceiveAd")
    }
    
    /// Tells the delegate an ad request failed.
    func adView(_ bannerView: GADBannerView,
                didFailToReceiveAdWithError error: GADRequestError) {
        print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    /// Tells the delegate that a full-screen view will be presented in response
    /// to the user clicking on an ad.
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("adViewWillPresentScreen")
    }
    
    /// Tells the delegate that the full-screen view will be dismissed.
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("adViewWillDismissScreen")
    }
    
    /// Tells the delegate that the full-screen view has been dismissed.
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("adViewDidDismissScreen")
    }
    
    /// Tells the delegate that a user click will open another app (such as
    /// the App Store), backgrounding the current app.
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        print("adViewWillLeaveApplication")
    }
}
