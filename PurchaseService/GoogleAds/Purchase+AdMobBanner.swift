//
//  Purchase+AdMobBanner.swift
//  PurchaseService
//
//  Created by Wataru Suzuki 2018/10/22.
//  Copyright © 2018年 Wataru Suzuki. All rights reserved.
//

import Foundation
import GoogleMobileAds

extension PurchaseService: GADBannerViewDelegate {
    public func bannerView(unitId: String, rootViewController: UIViewController) -> UIView {
        return bannerView(unitId: unitId, size: kGADAdSizeBanner, rootViewController: rootViewController)
    }
    
    public func mediumSizeBanner(unitId: String, rootViewController: UIViewController) -> UIView {
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
    public func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("adViewDidReceiveAd")
    }
    
    /// Tells the delegate an ad request failed.
    public func adView(_ bannerView: GADBannerView,
                didFailToReceiveAdWithError error: GADRequestError) {
        print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    /// Tells the delegate that a full-screen view will be presented in response
    /// to the user clicking on an ad.
    public func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("adViewWillPresentScreen")
    }
    
    /// Tells the delegate that the full-screen view will be dismissed.
    public func adViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("adViewWillDismissScreen")
    }
    
    /// Tells the delegate that the full-screen view has been dismissed.
    public func adViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("adViewDidDismissScreen")
    }
    
    /// Tells the delegate that a user click will open another app (such as
    /// the App Store), backgrounding the current app.
    public func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        print("adViewWillLeaveApplication")
    }
}
