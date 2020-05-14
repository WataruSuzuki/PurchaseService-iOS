//
//  PurchaseService.swift
//  PurchaseService
//
//  Created by Wataru Suzuki 2018/10/19.
//  Copyright © 2018年 Wataru Suzuki. All rights reserved.
//

import UIKit
import GoogleMobileAds
import SwiftyStoreKit
import KeychainAccess
import AppTrackingTransparency

public class PurchaseService: NSObject {
    let unknownError = NSError(domain: "PurchaseService", code: 500, userInfo: nil)
    let keychain = Keychain(service: Bundle.main.bundleIdentifier!)
    
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
    
    //Note that completeTransactions() should only be called once in your code
    func completeTransactions() {
    //func completeTransactions(completion: @escaping ([Purchase]) -> Void) {
        // see notes below for the meaning of Atomic / Non-Atomic
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                // Unlock content
                case .failed, .purchasing, .deferred:
                    fallthrough
                @unknown default:
                    print(purchase)
                }
            }
        }
    }
    
    func isPurchased(productID: String) -> Bool {
        do {
            guard let exist = try keychain.getString(productID) else {
                return false
            }
            validateInBackground(exist: exist)
            return true

        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    
    private func validateInBackground(exist: String) {
        validateReceipt(productID: exist, sharedSecret: "") { (result) in
            switch result {
            case .success(let receipt):
                let result = SwiftyStoreKit.verifyPurchase(productId: exist, inReceipt: receipt)
                switch result {
                case .notPurchased:
                    try? self.keychain.remove(exist)
                default:
                    break
                }
            default:
                break
            }
        }
    }
    
    func purchase(productID: String, sharedSecret: String? = nil, completion: ((Bool) -> Void)?) {
        let indicator = UIViewController.topIndicatorStart()
        
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue_purchase", attributes: .concurrent)

        dispatchGroup.enter()
        var details: PurchaseDetails? = nil
        dispatchQueue.async(group: dispatchGroup) {
            SwiftyStoreKit.purchaseProduct(productID) { (result) in
                switch result {
                case .success(let product):
                    details = product
                case .error(error: let error):
                    print(error.localizedDescription)
                }
                dispatchGroup.leave()
            }
        }
        //TODO
//        if let sharedSecret = sharedSecret {
//        }
        
        dispatchGroup.notify(queue: .main) {
            if let product = details {
                do {
                    try self.keychain.set(product.productId, key: product.productId)
                } catch {
                    print(error.localizedDescription)
                }
            }

            UIViewController.topIndicatorStop(view: indicator)
            completion?(details != nil)
        }

    }
    
    func restore(productIDs: Set<String>? = nil, subscriptionIDs: Set<String>? = nil, completion: ((Bool) -> Void)?) {
        let indicator = UIViewController.topIndicatorStart()
        var result = false
        
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue_restore", attributes: .concurrent)
        dispatchGroup.enter()
        dispatchQueue.async(group: dispatchGroup) {
            SwiftyStoreKit.restorePurchases { (results) in
                if results.restoreFailedPurchases.count > 0 {
                    var message = "Restore Failed:"
                    results.restoreFailedPurchases.forEach({ message.append("\n - \($0)") })
                    ErrorHandler.alert(message: message, actions: nil)
                    
                } else if results.restoredPurchases.count > 0 {
                    if let productIDs = productIDs {
                        productIDs.forEach({
                            do {
                                try self.keychain.set($0, key: $0)
                            } catch {
                                print(error.localizedDescription)
                            }
                        })
                    }
                    //TODO
//                    if let subscriptionsIDs = subscriptionIDs {
//                        self.verifyRestoredPurchase(productIDs: productIDs, restoredPurchases: results.restoredPurchases)
//                    }
                    result = true
                } else {
                    ErrorHandler.alert(message: "cannot_find_pay_history".localized, actions: nil)
                }
                dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: .main) {
            UIViewController.topIndicatorStop(view: indicator)
            completion?(result)
        }
    }
}
