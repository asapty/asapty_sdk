//
//  ASAPTY.swift
//  ASAPTY
//
//  Created by Pavel Kuznetsov on 14.01.2022.
//

import AdServices
import CoreGraphics

public class ASAPTY: NSObject {
    @objc public static let shared = ASAPTY()

    @objc
    public func attribution(withASAPTYToken token: String) {
        if #available(iOS 14.3, *) {
            NetworkWorker.shared.attribution(withToken: token)
        }
    }
    
    @objc
    public func track(eventName: String, productId: String?, revenue: String?, currency: String?) {
        if #available(iOS 14.3, *) {
            NetworkWorker.shared.track(eventName: eventName, productId: productId, revenue: revenue, currency: currency)
        }
    }
}
