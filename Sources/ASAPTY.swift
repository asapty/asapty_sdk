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
    public var logger: AsaptyLogger {
        didSet {
            network.logger = logger
            listener.logger = logger
        }
    }
    let storage: Storage
    let network: NetworkWorker
    let listener: InAppListener
    
    override init() {
        let logger = Logger()
        let storage = UserDefaultsStorage.default
        let network = NetworkWorker(storage: storage,
                                    baseUrl: Constants.serverAPI,
                                    logger: logger)
        
        self.listener = InAppListener(network: network)
        self.network = network
        self.storage = storage
        self.logger = logger
    }
    
    /// ASAPTY SDK initialization
    /// - Parameter asaptyId: user own asaptyid
    @objc
    public func attribution(with asaptyId: String) {
        network.attribution(withToken: asaptyId)
    }
    
    /// Method is responsible for tracking user's events
    /// - Parameters:
    ///   - eventName: User event name, ex: "inapp_purchase"
    ///   - productId: product id of in-app purchase, ex: com.example.app.inapp_purchase
    ///   - revenue: revenue from in-app item
    ///   - currency: currency of in-app item
    @objc
    public func track(eventName: String, productId: String?, revenue: String?, currency: String?) {
        if #available(iOS 14.3, *) {
            network.track(eventName: eventName, productId: productId, revenue: revenue, currency: currency)
        }
    }
    
    @objc
    public func subscribeForInAppEvents() {
        listener.subscribe()
    }
}
