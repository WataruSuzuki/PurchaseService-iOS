//
//  Purchase+AdMob.swift
//  MealDock
//
//  Created by Wataru Suzuki 2018/10/22.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

import Foundation
import GoogleMobileAds

extension PurchaseService: GADAdLoaderDelegate {
    
    func adRequest() -> GADRequest {
        let request = GADRequest()
        let extras = GADExtras()
        extras.additionalParameters = additionalParameters
        request.register(extras)

        return request
    }
    
    // MARK: - GADAdLoaderDelegate
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
        
    }
}
