//
//  InAppListener.swift
//  ASAPTY_SDK
//
//  Created by Pavel Kuznetsov on 02.06.2022.
//

import Foundation
import StoreKit

final public class InAppListener: NSObject, SKPaymentTransactionObserver, SKProductsRequestDelegate {
    var logger: AsaptyLogger
    private var products = [String: SKProduct]()
    private let storage: Storage
    private let network: NetworkWorker
    
    init(network: NetworkWorker) {
        self.storage = network.storage
        self.logger = network.logger
        self.network = network
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
        let productRequest: SKProductsRequest = SKProductsRequest(productIdentifiers: productsIDs)
        productRequest.delegate = self
    }
    
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        logger.debug("Received \(response.products.count) products", logger: .inAppListener)
        response.products.forEach { products[$0.productIdentifier] = $0 }
        processProducts()
    }
    
    private func processProducts() {
        guard let receiptURL = Bundle.main.appStoreReceiptURL,
              let receipt = try? Data(contentsOf: receiptURL)/*,
              let attributionId: String = Storage.value(forKey: Constants.attributionSendKey)*/ else {
            logger.debug("Receipt didn't found", logger: .inAppListener)
            return
        }
        var storedEvents: [ReceiptValidation] = storage.getValue(forKey: .inAppEvents) ?? []
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
        logger.debug("Save \(storedEvents.count) stored events", logger: .inAppListener)
        storage.storeValue(value: storedEvents, forKey: .inAppEvents)
        sendEvents()
    }
    
    private func sendEvents() {
        guard let storedEvents: [ReceiptValidation] = storage.getValue(forKey: .inAppEvents) else { return }
        for value in storedEvents where !value.processed {
            logger.debug("Submit \(value.transactionId) receipt", logger: .inAppListener)
            network.sendInAppReceipt(receipt: value)
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
