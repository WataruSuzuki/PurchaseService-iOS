//
//  Purchase+SwiftyStoreKit.swift
//  PurchaseService
//
//  Created by Wataru Suzuki on 2018/10/20.
//  Copyright © 2018 Wataru Suzuki. All rights reserved.
//

import Foundation
import StoreKit
import SwiftyStoreKit

extension PurchaseService {
    static let sharedSecret = "your-shared-secret"
    
    
    func retrieveProductInfo(productID: String, completion: @escaping (SKProduct?) -> Void) {
//        let indicator = UIViewController.topIndicatorStart()
//        retrieveProductsInfo(productID: [productID]) { (results) in
//            UIViewController.topIndicatorStop(view: indicator)
//            guard let results = results, results.retrievedProducts.count > 0 else {
                completion(nil)
//                return
//            }
//            for product in results.retrievedProducts {
//                completion(product)
//                break
//            }
//        }
    }

    private func purchaseProduct(with product: SKProduct, purchaseIds: Set<String>, subscriptionIds: Set<String>,  atomically: Bool, completion: @escaping () -> Void) {
        SwiftyStoreKit.purchaseProduct(product, quantity: 1, atomically: atomically) { result in
            self.handlePurchaseResult(result: result, purchaseIds: purchaseIds, subscriptionIds: subscriptionIds, atomically: atomically, completion: completion)
        }
    }
    
    private func handlePurchaseResult(result: PurchaseResult, purchaseIds: Set<String>, subscriptionIds: Set<String>, atomically: Bool, completion: @escaping () -> Void) {
        switch result {
        case .success(let product):
            // fetch content from your server, then:
            if !atomically && product.needsFinishTransaction {
                SwiftyStoreKit.finishTransaction(product.transaction)
            }
            debugPrint("Purchase Success: \(product.productId)")
            if purchaseIds.contains(product.productId) {
                verifyPurchase(productId: product.productId) { (verified) in
                    completion()
                }
            } else if subscriptionIds.contains(product.productId) {
                verifySubscriptions(productIds: [product.productId]) { (verified) in
                    completion()
                }
            }
            
        case .error(let error):
            completion()
            switch error.code {
            case .paymentCancelled:
                //Unnecessary to alert error
                return
            case .unknown: print("Unknown error. Please contact support")
            case .clientInvalid: print("Not allowed to make the payment")
            case .paymentInvalid: print("The purchase identifier was invalid")
            case .paymentNotAllowed: print("The device is not allowed to make the payment")
            case .storeProductNotAvailable: print("The product is not available in the current storefront")
            case .cloudServicePermissionDenied: print("Access to cloud service information is not allowed")
            case .cloudServiceNetworkConnectionFailed: print("Could not connect to the network")
            case .cloudServiceRevoked: print("User has revoked permission to use this cloud service")
            case .privacyAcknowledgementRequired:
                fallthrough
            case .unauthorizedRequestData:
                fallthrough
            case .invalidOfferIdentifier:
                fallthrough
            case .invalidSignature:
                fallthrough
            case .missingOfferParams:
                fallthrough
            case .invalidOfferPrice:
                fallthrough
            case .overlayCancelled:
                fallthrough
            case .overlayInvalidConfiguration:
                fallthrough
            case .overlayTimeout:
                fallthrough
            case .ineligibleForOffer:
                fallthrough
            @unknown default:
                print(error.localizedDescription)
            }
            ErrorHandler.alert(error: error)
        }
    }
    
    func restorePurchases(productIDs: Set<String>, subscriptionIDs: Set<String>) {
        let indicator = UIViewController.topIndicatorStart()
        SwiftyStoreKit.restorePurchases(atomically: false) { results in
            guard results.restoreFailedPurchases.count == 0 else {
                print("Restore Failed: \(results.restoreFailedPurchases)")
                var message = "Restore Failed:"
                for restoreFailed in results.restoreFailedPurchases {
                    message.append("\n - \(restoreFailed)")
                }
                UIViewController.topIndicatorStop(view: indicator)
                ErrorHandler.alert(message: message, actions: nil)
                return
            }
            if results.restoredPurchases.count > 0 {
                var productIDs = Set<String>()
                for purchase in results.restoredPurchases {
                    // fetch content from your server, then:
                    if purchase.needsFinishTransaction {
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    if productIDs.contains(purchase.productId) {
                        self.verifyPurchase(productId: purchase.productId, completion: { (verified) in
                            switch verified {
                            case .purchased(let item):
                                self.restoredMessage(item: item)
                            default:
                                break
                            }
                        })
                    } else {
                        productIDs.update(with: purchase.productId)
                    }
                }
                self.verifySubscriptions(productIds: subscriptionIDs, completion: { (verified) in
                    switch verified {
                    case .purchased( _, let items):
                        for item in items {
                            self.restoredMessage(item: item)
                        }
                        break
                    default:
                        break
                    }
                })
                debugPrint("Restore Success: \(results.restoredPurchases)")
            } else {
                print("Nothing to Restore")
                ErrorHandler.alert(message: "cannot_find_paid_history", actions: nil)
            }
            UIViewController.topIndicatorStop(view: indicator)
        }
    }
    
    private func restoredMessage(item: ReceiptItem) {
        var itemName = ""
        if let range = item.productId.range(of: Bundle.main.bundleIdentifier! + ".") {
            itemName = item.productId
            itemName.replaceSubrange(range, with: "")
        }
        //TODO -> UIViewController.snackBarMessage(text: "comp_restore".purchaseWord)
    }
    
    func fetchReceipt(force: Bool, completion: @escaping (String?) -> Void) {
        SwiftyStoreKit.fetchReceipt(forceRefresh: force) { result in
            switch result {
            case .success(let receiptData):
                let encryptedReceipt = receiptData.base64EncodedString(options: [])
                debugPrint("Fetch receipt success:\n\(encryptedReceipt)")
                completion(encryptedReceipt)
            case .error(let error):
                print("Fetch receipt failed: \(error)")
                completion(nil)
            }
        }
    }
    
    func verifyReceipt(completion: @escaping (ReceiptInfo?) -> Void) {
        fetchReceipt(force: false) { (base64EncodedReceipt) in
            self.validateReceipt(type: .production, completion: completion)
        }
    }
    
    func validateReceipt(type: AppleReceiptValidator.VerifyReceiptURLType, isRetrySandBox: Bool = false, completion: @escaping (ReceiptInfo?) -> Void) {
        let appleValidator = AppleReceiptValidator(service: type, sharedSecret: PurchaseService.sharedSecret)
        SwiftyStoreKit.verifyReceipt(using: appleValidator, forceRefresh: false) { result in
            switch result {
            case .success(let receipt):
                debugPrint("Verify receipt success: \(receipt)")
                completion(receipt)
                
            case .error(let error):
                print("Verify receipt failed: \(error)")
            }
        }
    }
    
    func verifyPurchase(productId: String, completion: @escaping (VerifyPurchaseResult) -> Void) {
        let indicator = UIViewController.topIndicatorStart()
        verifyReceipt { (info) in
            guard let receipt = info else {
                UIViewController.topIndicatorStop(view: indicator)
                completion(.notPurchased)
                return
            }
            // Verify the purchase of Consumable or NonConsumable
            let purchaseResult = SwiftyStoreKit.verifyPurchase(
                productId: productId,
                inReceipt: receipt)
            
            switch purchaseResult {
            case .purchased(let receiptItem):
                debugPrint("\(productId) is purchased: \(receiptItem)")
                switch productId {
                //TODO -> case UsageInfo.PurchasePlan.unlockAd.productId():
                    //TODO -> FirebaseService.shared.updateUnlockAdInfo(unlock: true)
                //TODO -> case UsageInfo.PurchasePlan.unlockPremium.productId():
                    //TODO -> FirebaseService.shared.updateUnlockPremiumInfo(unlock: true)
                default:
                    break
                }
            case .notPurchased:
                print("The user has never purchased \(productId)")
                switch productId {
                //TODO -> case UsageInfo.PurchasePlan.unlockAd.productId():
                    //TODO -> FirebaseService.shared.updateUnlockAdInfo(unlock: false)
                //TODO -> case UsageInfo.PurchasePlan.unlockPremium.productId():
                    //TODO -> FirebaseService.shared.updateUnlockPremiumInfo(unlock: false)
                default:
                    break
                }
            }
            UIViewController.topIndicatorStop(view: indicator)
            completion(purchaseResult)
        }
    }
    
    func verifySubscriptions(productIds: Set<String>, completion: @escaping (VerifySubscriptionResult) -> Void) {
        let indicator = UIViewController.topIndicatorStart()
        verifyReceipt { (info) in
            guard let receipt = info else {
                UIViewController.topIndicatorStop(view: indicator)
                completion(.notPurchased)
                return
            }
            let purchaseResult = SwiftyStoreKit.verifySubscriptions(productIds: productIds, inReceipt: receipt)
            switch purchaseResult {
            case .purchased(let expiryDate, let items):
                debugPrint("\(productIds) are valid until \(expiryDate)\n\(items)\n")
                //TODO -> FirebaseService.shared.updateSubscriptionPlanInfo(plan: .subscriptionBasic, expiryDate: expiryDate.timeIntervalSince1970)
                
            case .expired(let expiryDate, let items):
                print("\(productIds) are expired since \(expiryDate)\n\(items)\n")
                //TODO -> FirebaseService.shared.updateSubscriptionPlanInfo(plan: .free, expiryDate: nil)
                
            case .notPurchased:
                print("The user has never purchased \(productIds)")
            }
            UIViewController.topIndicatorStop(view: indicator)
            completion(purchaseResult)
        }
    }
}
