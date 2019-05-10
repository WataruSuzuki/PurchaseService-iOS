//
//  OptionalError.swift
//  MealDock
//
//  Created by Wataru Suzuki on 2018/10/13.
//  Copyright © 2018 WataruSuzuki. All rights reserved.
//

import UIKit

class OptionalError: NSError {

    init(with type: Cause, userInfo: [String : Any]?) {
        super.init(domain: Bundle.main.bundleIdentifier ?? "(・w・)", code: type.rawValue, userInfo: userInfo)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func kaomojiErrorStr(funcName: String) -> String {
        return "(・A・)!! " + funcName
    }
    
    static func alertErrorMessage(error: Error) {
        print(error)
        alertErrorMessage(message: error.localizedDescription, actions: nil)
    }
    
    static func alertErrorMessage(message: String, actions: [UIAlertAction]?) {
        let alert = UIAlertController(title: "(=・A・=)!!", message: message, preferredStyle: .alert)
        if let actions = actions {
            for action in actions {
                alert.addAction(action)
            }
        } else {
            let empty = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(empty)
        }
        if let top = UIViewController.currentTop() {
            top.present(alert, animated: true, completion: nil)
        }
    }
    
    enum Cause: Int {
        case unknown = 600,
        failedToGetPhotoData,
        failedToGetToken,
        failedToCreatePhotoSaveSpace,
        max
    }
}
