//
//  Purchase+Consent.swift
//  PurchaseService
//
//  Created by Wataru Suzuki 2018/10/22.
//  Copyright © 2018年 Wataru Suzuki. All rights reserved.
//

import Foundation
import GoogleMobileAds
import AdSupport
import PersonalizedAdConsent
#if canImport(SwiftExtensionChimera)
  import SwiftExtensionChimera
#endif
import AppTrackingTransparency

extension PurchaseService {

    public func confirmConsent(publisherIds: [String], productId: String = "", privacyPolicyUrl: String, completion: @escaping (Bool) -> Void) {
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue_confirm_consent", attributes: .concurrent)
        
        dispatchGroup.enter()
        if #available(iOS 14, *) {
            DispatchQueue.main.async {
                guard ATTrackingManager.trackingAuthorizationStatus == .notDetermined else {
                    dispatchGroup.leave()
                    return
                }
                ATTrackingManager.requestTrackingAuthorization { (status) in
                    dispatchGroup.leave()
                }
            }
        } else {
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: dispatchQueue) {
            DispatchQueue.main.async {
                self.confirmPersonalizedConsent(publisherIds: publisherIds, productId: productId, privacyPolicyUrl: privacyPolicyUrl, completion: completion)
            }
        }
    }
    
    private func confirmPersonalizedConsent(publisherIds: [String], productId: String = "", privacyPolicyUrl: String, completion: @escaping (Bool) -> Void) {
        let info = PACConsentInformation.sharedInstance
        PurchaseService.shared.privacyPolicyUrl = privacyPolicyUrl
        
        #if DEBUG
        info.debugIdentifiers = [ASIdentifierManager.shared().advertisingIdentifier.uuidString.md5]
        
        // Geography appears as in EEA for debug devices.
        //info.debugGeography = .EEA
        
        // Geography appears as not in EEA for debug devices.
        //info.debugGeography = .notEEA
        
        //Uncommented if you reset consent status
        //info.consentStatus = .unknown
        
        let ids = ["pub-3940256099942544"]
        #else
        let ids = publisherIds
        #endif

        if info.consentStatus != .unknown {
            completion(true)
        } else {
            requestConsentInfoUpdate(publisherIds: ids) { (isRequestLocationInEEAOrUnknown) in
                guard isRequestLocationInEEAOrUnknown else {
                    completion(true)
                    return
                }
                self.collectPersonalizedAdsConsent(shouldPersonalize: true, shouldAdFree: !productId.isEmpty, productId: productId, privacyPolicyUrl: privacyPolicyUrl, completion: completion)
            }
        }
    }
    
    private func requestConsentInfoUpdate(publisherIds: [String], completion: @escaping (Bool) -> Void) {
        let info = PACConsentInformation.sharedInstance
        info.requestConsentInfoUpdate(forPublisherIdentifiers: publisherIds) { (error) in
            if let error = error {
                ErrorHandler.alert(error: error)
                completion(false)
            } else {
                completion(info.isRequestLocationInEEAOrUnknown)
            }
        }
    }
    
    private func collectPersonalizedAdsConsent(shouldPersonalize: Bool, shouldAdFree: Bool, productId: String = "", privacyPolicyUrl: String, completion: @escaping (Bool) -> Void) {
        guard let form = PACConsentForm(applicationPrivacyPolicyURL: URL(string: privacyPolicyUrl)!) else {
            completion(false)
            return
        }
        form.shouldOfferPersonalizedAds = shouldPersonalize
        form.shouldOfferNonPersonalizedAds = shouldPersonalize
        form.shouldOfferAdFree = shouldAdFree

        form.load { (error) in
            guard let top = UIViewController.currentTop(), error == nil else {
                ErrorHandler.alert(error: error ?? ErrorHandler(userInfo: nil))
                completion(false)
                return
            }
            form.present(from: top, dismissCompletion: { (error, userPrefersAdFree) in
                guard error == nil else {
                    ErrorHandler.alert(error: error ?? ErrorHandler(userInfo: nil))
                    completion(false)
                    return
                }
                if userPrefersAdFree {
                    self.purchase(productID: productId, completion: nil)
                    completion(false)
                } else {
                    let status = PACConsentInformation.sharedInstance.consentStatus
                    if status == .nonPersonalized {
                        self.additionalParameters = ["npa": "1"]
                    }
                    completion(status != .unknown)
                }
            })
        }
    }
}
