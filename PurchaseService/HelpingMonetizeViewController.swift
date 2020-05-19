//
//  HelpingMonetizeViewController.swift
//  DataUsageCat
//
//  Created by 鈴木航 on 2019/08/28.
//  Copyright © 2019 Wataru Suzuki. All rights reserved.
//

import UIKit
import PureLayout
import GoogleMobileAds

open class HelpingMonetizeViewController: UIViewController {

    private var admobBannerView: UIView?
    
    public func addAdMobBannerView(unitId: String, toItem: UIView? = nil, edge: ALEdge = .bottom) {
        if admobBannerView == nil {
            admobBannerView = PurchaseService.shared.bannerView(unitId: unitId, rootViewController: self)
            if let toItem = toItem {
                toItem.addSubview(admobBannerView!)
                admobBannerView?.autoPinEdge(toSuperviewEdge: edge)
            } else {
                view.addSubview(admobBannerView!)
                admobBannerView?.autoPinEdge(toSuperviewSafeArea: edge)
            }
            admobBannerView?.autoAlignAxis(toSuperviewAxis: .vertical)
        }
    }

    public func removeAllAdBannerView() {
        admobBannerView?.removeFromSuperview()
        admobBannerView = nil
    }
    
    public func loadAdMobInterstitial(unitId: String) {
        PurchaseService.shared.loadInterstitial(unitId: unitId)
    }
    
    public func loadAdMobReward(unitId: String) {
        PurchaseService.shared.loadReward(unitId: unitId)
    }

    public func showAdMobInterstitial(rootViewController: UIViewController) {
        PurchaseService.shared.showInterstitial(rootViewController: rootViewController)
    }

    public func showAdMobReward(rootViewController: UIViewController) {
        PurchaseService.shared.showReward(rootViewController: rootViewController)
    }
}
