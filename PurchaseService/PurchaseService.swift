//
//  PurchaseService.swift
//  MealDock
//
//  Created by Wataru Suzuki 2018/10/19.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

import UIKit
import GoogleMobileAds

class PurchaseService: NSObject {
    static let shared: PurchaseService = {
        return PurchaseService()
    }()
    var adLoader: GADAdLoader?
    var bannerViews = Set<GADBannerView>()
    var loadedNativeAd = [GADUnifiedNativeAd]()
    var nativeViews = Set<GADUnifiedNativeAdView>()

    var additionalParameters = [String : String]()
}
