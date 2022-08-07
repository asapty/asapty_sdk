//
//  NetworkWorkerTests.swift
//  
//
//  Created by Aleksei Cherepanov on 07.08.2022.
//

import XCTest
@testable import ASAPTY_SDK

class NetworkWorkerTests: XCTestCase {
    private var worker: NetworkWorker!
    private var storage: UserDefaultsStorage!
    private var session: MockSession!
    
    override func setUp() {
        super.setUp()
        let suiteName = "TEST_SUITE"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        storage = UserDefaultsStorage(suiteName: suiteName)
        session = MockSession()
        worker = NetworkWorker(
            storage: storage,
            session: session,
            baseUrl: "http://test.com/",
            logger: Logger()
        )
    }
    
    private func setupPolling() {
        let tmpResponse = ServerPollingResponse(
            id: "test_id",
            status: "ok",
            completed: false,
            failed: false
        )
        let data = try! JSONEncoder().encode(tmpResponse)
        storage.storeValue(value: data, forKey: .serverPollingId)
    }
    
    func testPollingInition() {
        setupPolling()
        worker.attribution(withToken: "token")
        let request = session.lastRequst
        XCTAssertNotNil(request)
        let url = request!.url!.absoluteString
        XCTAssertEqual(url, "http://test.com/byToken/?id=test_id")
    }
    
    func testPutAttributionToken() {
        let tmpResponse = ServerPollingResponse(
            id: "test_id",
            status: "ok",
            completed: false,
            failed: false
        )
        let data = try! JSONEncoder().encode(tmpResponse)
        session.attributionToken = "attribution_token"
        session.response = (data, 200, nil)
        let expectation = XCTestExpectation(description: "Send attribution token to the server.")
        session.onRequest = { expectation.fulfill() }
        worker.attribution(withToken: "token")
        let date = Date()
        let firstDate = storage.firstRunDate
        XCTAssertTrue(date.compare(firstDate) == .orderedDescending)
        
        wait(for: [expectation], timeout: 1.0)
        let request = session.lastRequst
        XCTAssertNotNil(request)
        let url = request!.url!.absoluteString
        XCTAssertEqual(url, "http://test.com/byToken")
        let requested = try! JSONDecoder().decode([String: String].self, from: request!.httpBody!)
        XCTAssertEqual(requested["asaptyId"], "token")
        XCTAssertEqual(requested["token"], "attribution_token")
        XCTAssertNotNil(requested["source"])
    }
    
    func testTrackEvent() {
        let date = Date()
        storage.storeValue(value: date, forKey: .firstRun)
        setupPolling()
        worker.track(eventName: "event_name_1",
                     productId: "poroduct_1",
                     revenue: "revenue_1",
                     currency: "currency_1")
        let request = session.lastRequst
        XCTAssertNotNil(request)
        let url = request!.url!.absoluteString
        XCTAssertEqual(url, "http://test.com/")
        let dict = try! JSONDecoder().decode([String: String].self, from: request!.httpBody!)
        XCTAssertEqual(dict["event_name"], "event_name_1")
        XCTAssertEqual(dict["attributionId"], "test_id")
        XCTAssertEqual(dict["install_time"], "\(Int(date.timeIntervalSince1970))")
        
        let json = dict["json"]
        XCTAssertNotNil(json)
        let innerJson = try! JSONDecoder().decode([String: String].self, from: json!.data(using: .utf8)!)
        XCTAssertEqual(innerJson["af_content_id"], "poroduct_1")
        XCTAssertEqual(innerJson["af_revenue"], "revenue_1")
        XCTAssertEqual(innerJson["af_currency"], "currency_1")
    }
    
    func testInAppReceipt() {
        let receipt = ReceiptValidation(
            receiptData: "receipt_data_1",
            bundleId: "bundle_id_1",
            attributionId: "attribution_id_1",
            amount: "amount_1",
            transactionId: "transaction_id_1"
        )
        worker.sendInAppReceipt(receipt: receipt)
        let request = session.lastRequst
        XCTAssertNotNil(request)
        let url = request!.url!.absoluteString
        XCTAssertEqual(url, "http://test.com/verifyReceipt")
        let dict = try! JSONDecoder().decode([String: String].self, from: request!.httpBody!)
        XCTAssertEqual(dict["receipt-data"], "receipt_data_1")
        XCTAssertEqual(dict["bundleId"], "bundle_id_1")
        XCTAssertEqual(dict["attributionId"], "attribution_id_1")
        XCTAssertEqual(dict["amount"], "amount_1")
        XCTAssertEqual(dict["transactionId"], "transaction_id_1")
    }
}

private class MockSession: NetworkSession {
    var response: (Data?, Int, Error?)
    var lastRequst: URLRequest?
    var attributionToken: String?
    var onRequest: (() -> Void)?
    
    init(response: (Data?, Int, Error?) = (nil, 0, nil)) {
        self.response = response
    }
    
    func sendRequest(_ request: URLRequest, completionHandler: @escaping (Data?, Int, Error?) -> Void) {
        lastRequst = request
        completionHandler(response.0, response.1, response.2)
        onRequest?()
    }
}
