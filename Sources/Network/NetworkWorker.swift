//
//  NetworkWorker.swift
//  ASAPTY
//
//  Created by Pavel Kuznetsov on 23.02.2022.
//

import Foundation

final class NetworkWorker {
    var logger: AsaptyLogger
    private var userToken: String = ""
    let storage: Storage
    let baseUrl: String
    let session: NetworkSession
    
    init(storage: Storage, session: NetworkSession = URLSession.shared, baseUrl: String, logger: AsaptyLogger) {
        self.storage = storage
        self.baseUrl = baseUrl
        self.session = session
        self.logger = logger
    }
    
    public func attribution(withToken token: String) {
        userToken = token
        if #available(iOS 14.3, *) { initPolling() }
    }
    
    @available(iOS 14.3, *)
    func initPolling() {
        if let data: Data = storage.getValue(forKey: .serverPollingId),
           let serverResponse = try? JSONDecoder().decode(ServerPollingResponse.self, from: data) {
            guard !serverResponse.failed, !serverResponse.completed else { return }
            pollingServerID(serverResponse.id)
        }
        
        guard let attributionToken = session.attributionToken else { return }
        let _ = storage.firstRunDate
        DispatchQueue.global().async { [weak self] in
            self?.putAttributionToken(attr: attributionToken)
        }
    }
    
    public func track(eventName: String, productId: String?, revenue: String?, currency: String?) {
        guard let data: Data = storage.getValue(forKey: .serverPollingId),
        let serverResponse = try? JSONDecoder().decode(ServerPollingResponse.self, from: data) else { return }
        var rawData = [String: Any]()
        rawData["event_name"] = eventName
        let innerJson = [
            "af_content_id": productId ?? "",
            "af_revenue": revenue ?? "",
            "af_currency": currency ?? "",
        ]
        guard let innerJSONData = try? JSONSerialization.data(withJSONObject: innerJson, options: []) else { return }
        let innerJSONDataString = String(data: innerJSONData, encoding: String.Encoding.ascii)
        rawData["json"] = innerJSONDataString
        rawData["attributionId"] = serverResponse.id
        rawData["source"] = "sdk_\(Constants.currentSDKVersion)"
        rawData["install_time"] = "\(Int64(storage.firstRunDate.timeIntervalSince1970))"
        
        var request = makeRequest(.track)!
        request.httpBody = try? JSONSerialization.data(withJSONObject: rawData, options: [])
        session.sendRequest(request) { [logger] data, statusCode, error in
            guard error == nil, (200..<300).contains(statusCode) else { return }
            logger.debug("TRACKED EVENT: \(rawData)", logger: .network)
        }
    }
    
    private func putAttributionToken(attr: String) {
        var request = makeRequest(.putAttributionToken)!
        let uploadData = [
            "token": attr,
            "asaptyId": "\(userToken)",
            "source": "sdk_\(Constants.currentSDKVersion)"
        ]
        let encodedData = try? JSONSerialization.data(withJSONObject: uploadData, options: [])
        request.httpBody = encodedData
        session.sendRequest(request) { [weak self] data, response, error in
            guard let self = self, error == nil,
                  let data = data,
                  let rawData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let result = rawData["result"], let resultData = try? JSONSerialization.data(withJSONObject: result, options: []),
                  let serverResponse = try? JSONDecoder().decode(ServerPollingResponse.self, from: resultData)
            else { return }
            
            self.storage.storeValue(value: resultData, forKey: .serverPollingId)
            if serverResponse.failed { return }
            
            if !serverResponse.completed {
                self.pollingServerID(serverResponse.id)
            }
        }
    }
    
    private func pollingServerID(_ id: String) {
        let request = makeRequest(.pollingServerId(id))!
        session.sendRequest(request) { [weak self] data, response, error in
            guard let self = self, error == nil,
                  let data = data,
                  let rawData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let result = rawData["result"],
                  let resultData = try? JSONSerialization.data(withJSONObject: result, options: []),
                  let serverResponse = try? JSONDecoder().decode(ServerPollingResponse.self, from: resultData)
            else { return }
            
            self.storage.storeValue(value: resultData, forKey: .serverPollingId)
            if serverResponse.failed { return }
            
            if !serverResponse.completed {
                Dispatcher.background.async(delay: 1) { [weak self] in
                    self?.pollingServerID(serverResponse.id)
                }
            }
        }
    }
    
    private func sendAttribution(withToken token: String, appleResponse: [String: Any]) {
        guard let attribution = appleResponse["attribution"] as? Bool, attribution == true else { return }
        let installDate = "\(Int64(storage.firstRunDate.timeIntervalSince1970))"
        let adaptedResponse = ModelAdapter.adapt(appleResponse: appleResponse, token: token, installDate: installDate)
        logger.debug("ADAPTED RESPONSE: \(adaptedResponse)", logger: .network)
        var request = makeRequest(.sendAttribution)!
        let encodedData = try? JSONSerialization.data(withJSONObject: adaptedResponse, options: [])
        request.httpBody = encodedData
        session.sendRequest(request) { [storage] data, statusCode, error in
            guard error == nil, (200..<300).contains(statusCode) else { return }
            storage.storeValue(value: encodedData, forKey: .attributionSend)
        }
    }
    
    public func sendInAppReceipt(receipt: ReceiptValidation) {
        var request = makeRequest(.sendInAppReceipt)!
        let uploadData = receipt.dictionaryRepresentation()
        let encodedData = try? JSONSerialization.data(withJSONObject: uploadData, options: [])
        request.httpBody = encodedData
        session.sendRequest(request) { data, statusCode, error in
            guard error == nil, (200..<300).contains(statusCode) else { return }
        }
    }
    
    private func makeRequest(_ route: NetworkRouter) -> URLRequest? {
        guard let url = URL(string: route.path(baseUrl)) else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = route.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
}
