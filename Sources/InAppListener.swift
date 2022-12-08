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
        var storedEvents: [ReceiptValidation] = Storage.value(forKey: Constants.inAppEventsKey) ?? []
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
        Storage.storeValue(value: storedEvents, forKey: Constants.inAppEventsKey)
        sendEvents()
    }
    
    private func sendEvents() {
        guard let storedEvents: [ReceiptValidation] = Storage.value(forKey: Constants.inAppEventsKey) else { return }
        for (index, value) in storedEvents.enumerated() {
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
