//
//  Purchase+AdMobReward.swift
//  PurchaseService
//
//  Created by Wataru Suzuki 2018/10/22.
//  Copyright © 2018年 Wataru Suzuki. All rights reserved.
//

import Foundation
import GoogleMobileAds

extension PurchaseService: GADRewardBasedVideoAdDelegate {
    static let keyTicket = "RewardedTicket"
    
    public func loadReward(unitId: String) {
        UserDefaults.standard.register(defaults: [PurchaseService.keyTicket : 1])
        GADRewardBasedVideoAd.sharedInstance().delegate = self
        #if DEBUG
        GADRewardBasedVideoAd.sharedInstance().load(adRequest(), withAdUnitID: "ca-app-pub-3940256099942544/1712485313")
        #else
        GADRewardBasedVideoAd.sharedInstance().load(adRequest(), withAdUnitID: unitId)
        #endif
    }
    
    public func showReward(rootViewController: UIViewController) {
        if GADRewardBasedVideoAd.sharedInstance().isReady {
            GADRewardBasedVideoAd.sharedInstance().present(fromRootViewController: rootViewController)
        } else {
            let action = UIAlertAction(title: "OK", style: .default) { (action) in
                self.confirmConsent(publisherIds: ["your_pub_id"], privacyPolicyUrl: PurchaseService.shared.privacyPolicyUrl, completion: { (confirmed) in
                    if confirmed {
                        self.loadReward(unitId: "your_reward_unit_id")
                    }
                })
            }
            ErrorHandler.alert(message: "(・A・)!!", actions: [action])
        }
    }
    
    public func hasTicket() -> Bool {
        let userDefault = UserDefaults.standard
        guard let current =
            userDefault.object(forKey: PurchaseService.keyTicket) as? Int, current > 0 else {
                return false
        }
        userDefault.set(current - 1, forKey: PurchaseService.keyTicket)
        userDefault.synchronize()
        return true
    }
    
    // MARK: - GADRewardBasedVideoAdDelegate
    public func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd,
                            didRewardUserWith reward: GADAdReward) {
        debugPrint("Reward received with currency: \(reward.type), amount \(reward.amount).")
        let userDefault = UserDefaults.standard
        if let current =
            userDefault.object(forKey: PurchaseService.keyTicket) as? Int {
            userDefault.set(current + reward.amount.intValue, forKey: PurchaseService.keyTicket)
        } else {
            userDefault.set(reward.amount.intValue, forKey: PurchaseService.keyTicket)
        }
        userDefault.synchronize()
    }
    
    public func rewardBasedVideoAdDidReceive(_ rewardBasedVideoAd:GADRewardBasedVideoAd) {
        debugPrint("Reward based video ad is received.")
    }
    
    public func rewardBasedVideoAdDidOpen(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        debugPrint("Opened reward based video ad.")
    }
    
    public func rewardBasedVideoAdDidStartPlaying(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        debugPrint("Reward based video ad started playing.")
    }
    
    public func rewardBasedVideoAdDidCompletePlaying(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        debugPrint("Reward based video ad has completed.")
    }
    
    public func rewardBasedVideoAdDidClose(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        debugPrint("Reward based video ad is closed.")
        //TODO -> guard let user = FirebaseService.shared.currentUser, !user.isPurchased else { return }
        loadReward(unitId: "your_reward_unit_id")
    }
    
    public func rewardBasedVideoAdWillLeaveApplication(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        debugPrint("Reward based video ad will leave application.")
    }
    
    public func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd,
                            didFailToLoadWithError error: Error) {
        print("Reward based video ad failed to load.")
    }
    
}
