//
//  Purchase+StoreDelegate.swift
//  MealDock
//
//  Created by Wataru Suzuki 2018/10/19.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

import Foundation
import StoreKit
/*
extension PurchaseService: SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    func validateProduct(with productIdentifiers: Set<String>) {
        guard SKPaymentQueue.canMakePayments() else {
            if let top = UIViewController.currentTop() {
                let alert = UIAlertController(title: "Error", message: "Cannot make payments", preferredStyle: .alert)
                alert.addEmptyOkAction()
                top.present(alert, animated: true, completion: nil)
            } else {
                print("Cannot make payments")
            }
            return
        }
        
        let request = SKProductsRequest(productIdentifiers: productIdentifiers)
        request.delegate = self
        request.start()
        productIDs = productIdentifiers
    }
    
    // MARK: - SKPaymentTransactionObserver
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                debugPrint(transaction)
                break
                
            case .purchased:
                fallthrough
            case .restored:
                queue.finishTransaction(transaction)
                if updatedPurchasedStatus(transaction: transaction) {
                    UIViewController.snackBarMessage(text: "m(_ _)m")
                } else {
                    OptionalError.alertErrorMessage(message: "Cannot find valid item", actions: nil)
                }
                break

            case .failed:
                alertTransactionError(transaction: transaction)
                break

            default:
                break
            }
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        for transaction in queue.transactions {
            alertTransactionError(transaction: transaction)
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        var result = true
        for transaction in queue.transactions {
            if !updatedPurchasedStatus(transaction: transaction) {
                result = false
            }
        }
        
        if result {
            UIViewController.snackBarMessage(text: NSLocalizedString("comp_restore", comment: ""))
        } else {
            OptionalError.alertErrorMessage(message: "cannot_find_paid_history", actions: nil)
        }
    }
    
    private func updatedPurchasedStatus(transaction: SKPaymentTransaction) -> Bool {
        let purchasedId = transaction.payment.productIdentifier
        //let original = transaction.original?.payment.productIdentifier
        
        guard productIDs.contains(purchasedId) else {
            return false
        }
        A0SimpleKeychain().setString(purchasedId, forKey: purchasedId)
        return true
    }
    
    private func alertTransactionError(transaction: SKPaymentTransaction) {
        if let nsError = transaction.error as NSError? {
            let skError = SKError(_nsError: nsError)
            if skError.code != .paymentCancelled {
                OptionalError.alertErrorMessage(error: skError)
            }
        }
    }
    
    // MARK: - SKProductsRequestDelegate
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        guard response.invalidProductIdentifiers.count == 0 else {
            OptionalError.alertErrorMessage(message: "Given invalid product", actions: nil)
            return
        }
        
        productResponse = response
        SKPaymentQueue.default().add(self)
        addPayment(with: response)
    }
    
    private func addPayment(with response: SKProductsResponse) {
        for product in response.products {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        OptionalError.alertErrorMessage(error: error)
    }
}
*/
