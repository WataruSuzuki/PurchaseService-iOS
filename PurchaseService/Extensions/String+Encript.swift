//
//  String+encript.swift
//  MealDock
//
//  Created by Wataru Suzuki 2018/10/22.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

import Foundation

extension String {
    
    func sha1(with param: String) -> String {
        let str = "\(self)_\(param)"
        let data = str.data(using: .utf8)!
        let length = Int(CC_SHA1_DIGEST_LENGTH)
        var digest = [UInt8](repeating: 0, count: length)
        _ = data.withUnsafeBytes { CC_SHA1($0, CC_LONG(data.count), &digest) }
        let crypt = digest.map { String(format: "%02x", $0) }.joined(separator: "")
        debugPrint("crypt : \(crypt)")
        
        return crypt
    }

    func md5() -> String {
        let data = self.data(using: .utf8)!
        let length = Int(CC_MD5_DIGEST_LENGTH)
        var digest = [UInt8](repeating: 0, count: length)
        _ = data.withUnsafeBytes { CC_MD5($0, CC_LONG(data.count), &digest) }
        let crypt = digest.map { String(format: "%02x", $0) }.joined(separator: "")
        debugPrint("md5 : \(crypt)")
        
        return crypt
    }
}
