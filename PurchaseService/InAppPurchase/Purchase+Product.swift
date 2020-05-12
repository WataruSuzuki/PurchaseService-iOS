//
//  Purchase+StoreDelegate.swift
//  PurchaseService
//
//  Created by Wataru Suzuki 2018/10/19.
//  Copyright © 2018年 Wataru Suzuki. All rights reserved.
//

import Foundation
import StoreKit
import SwiftyStoreKit

extension PurchaseService {
    
    func asyncRetrieveProductsInfo(productID: Set<String>) -> Result<RetrieveResults, Error> {
        var asyncResult = Result<RetrieveResults, Error>.failure(unknownError)
        let semaphore = DispatchSemaphore(value: 0)
        
        SwiftyStoreKit.retrieveProductsInfo(productID) { result in
            guard result.error == nil else {
                asyncResult = Result<RetrieveResults, Error>.failure(result.error!)
                semaphore.signal()
                return
            }
            if result.invalidProductIDs.count > 0 {
                for invalidProduct in result.invalidProductIDs {
                    print("Invalid product identifier: \(invalidProduct)")
                }
            }
            for product in result.retrievedProducts {
                debugPrint("Product: \(product.localizedDescription)")
                let priceString = product.localizedPrice ?? "(・∀・)??"
                debugPrint("Price: \(priceString)")
                if #available(iOS 11.2, *) {
                    if let period = product.subscriptionPeriod {
                        debugPrint("period numberOfUnits: \(period.numberOfUnits)")
                        debugPrint("period unit: \(period.unit)")
                    }
                }
            }
            asyncResult = Result<RetrieveResults, Error>.success(result)
            semaphore.signal()
        }
        semaphore.wait()
        return asyncResult
    }
    
    func asyncPurchase(productID: String) -> Result<PurchaseDetails, Error> {
        var asyncResult = Result<PurchaseDetails, Error>.failure(unknownError)
        let semaphore = DispatchSemaphore(value: 0)
        
        SwiftyStoreKit.purchaseProduct(productID) { (result) in
            switch result {
            case .success(let product):
                debugPrint(product)
                asyncResult = .success(product)
                break
            case .error(error: let error):
                asyncResult = .failure(error)
                break
            }
            semaphore.signal()
        }
        
        semaphore.wait()
        return asyncResult
    }
    
    func asyncValidateReceipt(productID: String, sharedSecret: String, isRetrySandBox: Bool = false) -> Result<ReceiptInfo, Error> {
        var asyncResult = Result<ReceiptInfo, Error>.failure(unknownError)
        let semaphore = DispatchSemaphore(value: 0)
        
        validateReceipt(productID: productID, sharedSecret: sharedSecret) { (result) in
            switch result {
            case .success(let receipt):
                debugPrint("Verify receipt success: \(receipt)")
                asyncResult = .success(receipt)
                
            case .error(let error):
                print("Verify receipt failed: \(error)")
                asyncResult = .failure(error)
            }
            semaphore.signal()
        }
        
        semaphore.wait()
        return asyncResult
    }
    
    func validateReceipt(productID: String, sharedSecret: String, isRetrySandBox: Bool = false, completion: @escaping (VerifyReceiptResult) -> Void) {
        #if DEBUG || DEBUG_SWIFT
        let appleValidator = AppleReceiptValidator(service: .sandbox, sharedSecret: sharedSecret)
        #else
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: sharedSecret)
        #endif
        SwiftyStoreKit.verifyReceipt(using: appleValidator, forceRefresh: false) { result in
            completion(result)
        }
    }
    
    func asyncVerifyRestredPurchase(productIDs: Set<String>, restoredPurchases: [Purchase]) {
        var errorMeessags = [String]()
        var restoredItem = [String]()
        
        for purchase in restoredPurchases {
            // fetch content from your server, then:
            if purchase.needsFinishTransaction {
                SwiftyStoreKit.finishTransaction(purchase.transaction)
            }
            if !productIDs.contains(purchase.productId) {
                print("Uknown purchase: \(purchase.productId)")
            } else {
                let validate = asyncValidateReceipt(productID: purchase.productId, sharedSecret: "")
                switch validate {
                case .success(let receipt):
                    let result = SwiftyStoreKit.verifyPurchase(productId: purchase.productId, inReceipt: receipt)
                    switch result {
                    case .purchased(let item):
                        restoredItem.append(item.productId)
                    case .notPurchased:
                        errorMeessags.append(purchase.productId)
                        try? keychain.remove(purchase.productId)
                    }
                case .failure(let error):
                    errorMeessags.append(error.localizedDescription)
                }
            }
        }
        if !errorMeessags.isEmpty {
            let alert = UIAlertController(title: "cannot_find_pay_history".localized, message: nil, preferredStyle: .alert)
            alert.addEmptyOkAction()
            UIViewController.currentTop()?.present(alert, animated: true, completion: nil)
        }
        if !restoredItem.isEmpty {
            restoredItem.forEach({ try? keychain.set($0, key: $0) })
            let alert = UIAlertController(title: "comp_restore".localized, message: nil, preferredStyle: .alert)
            alert.addEmptyOkAction()
            UIViewController.currentTop()?.present(alert, animated: true, completion: nil)
        }
    }
}
