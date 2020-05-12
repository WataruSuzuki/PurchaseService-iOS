//
//  OptionalError.swift
//  PurchaseService
//
//  Created by Wataru Suzuki on 2018/10/13.
//  Copyright © 2018 Wataru Suzuki. All rights reserved.
//

import UIKit

class ErrorHandler: NSError {

    init(userInfo: [String : Any]?) {
        super.init(domain: Bundle.main.bundleIdentifier ?? "(・w・)", code: 500, userInfo: userInfo)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func kaomojiErrorStr(funcName: String) -> String {
        return "(・A・)!! " + funcName
    }
    
    static func alert(error: Error) {
        print(error)
        alert(message: error.localizedDescription, actions: nil)
    }
    
    static func alert(message: String, actions: [UIAlertAction]?) {
        let alert = UIAlertController(title: "(=・A・=)!!", message: message, preferredStyle: .alert)
        if let actions = actions {
            actions.forEach({ alert.addAction($0) })
        } else {
            let empty = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(empty)
        }
        if let top = UIViewController.currentTop() {
            top.present(alert, animated: true, completion: nil)
        }
    }
//
//    enum Cause: Int {
//        case unknown = 600,
//        failedToGetPhotoData,
//        failedToGetToken,
//        failedToCreatePhotoSaveSpace,
//        max
//    }
}
