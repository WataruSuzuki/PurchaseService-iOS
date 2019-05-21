//
//  PurchaseService.swift
//  PurchaseService
//
//  Created by Wataru Suzuki 2018/10/19.
//  Copyright © 2018年 Wataru Suzuki. All rights reserved.
//

import UIKit
import GoogleMobileAds

public class PurchaseService: NSObject {
    public static let shared: PurchaseService = {
        return PurchaseService()
    }()
    var privacyPolicyUrl: String!
    
    var adLoader: GADAdLoader?
    var bannerViews = Set<GADBannerView>()
    var loadedNativeAd = [GADUnifiedNativeAd]()
    var nativeViews = Set<GADUnifiedNativeAdView>()
    var interstitialAd: GADInterstitial?

    var additionalParameters = [String : String]()
}
