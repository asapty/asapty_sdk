//
//  InAppListener.swift
//  ASAPTY_SDK
//
//  Created by Pavel Kuznetsov on 02.06.2022.
//

import Foundation
import StoreKit

final public class InAppListener: NSObject, SKPaymentTransactionObserver, SKProductsRequestDelegate {
    public static let shared = InAppListener()
    
    private var products = [String: SKProduct]()
    private var productsRequest: SKProductsRequest? {
        willSet {
            productsRequest?.delegate = nil
            productsRequest?.cancel()
        }
        didSet {
            productsRequest?.delegate = self
            productsRequest?.start()
        }
    }

    private var receiptValidations: [ReceiptValidation]? {
        get {
            guard let storedData: [Data] = Storage.value(forKey: Constants.inAppEventsKey) else { return nil }
            return storedData.compactMap {
                try? JSONDecoder().decode(ReceiptValidation.self, from: $0)
            }
        }
        set {
            let eventsToStore = newValue?.compactMap {
                try? JSONEncoder().encode($0)
            }
            Storage.storeValue(value: eventsToStore, forKey: Constants.inAppEventsKey)
        }
    }
    
    func subscribe() {
        SKPaymentQueue.default().add(self)
    }
    
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        let purchasedItems = transactions.compactMap({ $0.transactionState == .purchased ? $0 : nil })
        var productsIDs: Set<String> = []
        purchasedItems.forEach {
            let productId = $0.payment.productIdentifier
            productsIDs.insert(productId)
        }
        productsRequest = SKProductsRequest(productIdentifiers: productsIDs)
    }
    
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        response.products.forEach {
            products[$0.productIdentifier] = $0
        }
        processProducts()
    }

    private func processProducts() {
        guard let receiptURL = Bundle.main.appStoreReceiptURL,
              let receipt = try? Data(contentsOf: receiptURL)/*,
              let attributionId: String = Storage.value(forKey: Constants.attributionSendKey)*/ else { return }
        var storedEvents = receiptValidations ?? []
        products.forEach { product in
            let validationModel = ReceiptValidation(receiptData: receipt.base64EncodedString(),
                                                    bundleId: Bundle.main.bundleIdentifier ?? "",
                                                    attributionId: "blablabla",
                                                    amount: product.value.localizedPrice ?? "",
                                                    transactionId: product.key)
            if !storedEvents.contains(where: { receipt in
                receipt.transactionId == product.key
            }) {
                storedEvents.append(validationModel)
            }
        }
        receiptValidations = storedEvents
        sendEvents()
    }
    
    private func sendEvents() {
        guard let storedEvents = receiptValidations else { return }
        for value in storedEvents {
            guard !value.processed else { continue }
            NetworkWorker.shared.sendInAppReceipt(receipt: value)
        }
    }
}

extension SKProduct {
    var localizedPrice: String? {
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = priceLocale
        numberFormatter.numberStyle = .currency

        return numberFormatter.string(from: price)
    }
}
