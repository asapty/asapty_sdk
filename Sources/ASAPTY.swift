//
//  ASAPTY.swift
//  ASAPTY
//
//  Created by Pavel Kuznetsov on 14.01.2022.
//

import AdServices

public class ASAPTY: NSObject {
    @objc public static let shared = ASAPTY()

    @objc public func attribution(withASAPTYToken token: String) {
        if #available(iOS 14.3, *) {
            NetworkWorker.attribution(withToken: token)
        }
    }
}
