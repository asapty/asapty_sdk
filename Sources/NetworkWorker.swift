//
//  NetworkWorker.swift
//  ASAPTY
//
//  Created by Pavel Kuznetsov on 23.02.2022.
//

import Foundation
import AdServices
import UIKit

final class NetworkWorker {
    public static let shared = NetworkWorker()
    private var userToken: String = ""
    
    public func attribution(withToken token: String) {
        userToken = token
        if let _: Data = Storage.value(forKey: Constants.attributionSendKey) { return }
        
        if #available(iOS 14.3, *) {
            guard let attributionToken = try? AAAttribution.attributionToken() else { return }
            DispatchQueue.global().async { [weak self] in
                guard let self = self else { return }
                self.requestAttribution(with: attributionToken) { result in
                    switch result {
                    case .failure:
                        return
                    case let .success(response):
                        self.sendAttribution(withToken: token, appleResponse: response)
                    }
                }
            }
        }
    }
    
    public func track(eventName: String, productId: String?, revenue: String?, currency: String?) {
        guard let encodedData: Data = Storage.value(forKey: Constants.attributionSendKey),
              var rawData = try? JSONSerialization.jsonObject(with: encodedData, options: .mutableContainers) as? [String: Any] else { return }
        rawData["event_name"] = eventName
        let innerJson = ["af_content_id": productId ?? "",
                         "af_revenue": revenue ?? "",
                         "af_currency": currency ?? "" ]
        guard let innerJSONData = try? JSONSerialization.data(withJSONObject: innerJson, options: []) else { return }
        let innerJSONDataString = String(data: innerJSONData, encoding: String.Encoding.ascii)
        rawData["json"] = innerJSONDataString
        var apiPath: String
        #if DEBUG
        apiPath = Constants.serverDEVAPI
        #else
        apiPath = Constants.serverAPI
        #endif
        
        var request = URLRequest(url: URL(string:apiPath)!)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: rawData, options: [])
        URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            guard error == nil, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else { return }
            #if DEBUG
            print("TRACKED EVENT: \(rawData)")
            #endif
        }).resume()
    }
    
    private func requestAttribution(with token: String, completion: @escaping (Result<[String: Any], Error>) -> ()) {
        var request = URLRequest(url: URL(string: Constants.appleAttributionAPI)!)
        request.httpMethod = "POST"
        request.setValue("text/plain", forHTTPHeaderField: "Content-Type")
        request.httpBody = Data(token.utf8)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                let error = NSError(domain: "com.asapty.sdk", code: 100, userInfo: nil)
                completion(.failure(error))
                return
            }
            
            guard let rawData = data, let attribution = try? JSONSerialization.jsonObject(with: rawData, options: []) as? [String: Any] else {
                let error = NSError(domain: "com.asapty.sdk", code: 100, userInfo: nil)
                completion(.failure(error))
                return
            }
            completion(.success(attribution))
        }.resume()
    }
    
    private func sendAttribution(withToken token: String, appleResponse: [String: Any]) {
        guard let attribution = appleResponse["attribution"] as? Bool, attribution == true else { return }
        let installDate = "\(Int64(Storage.firstRunDate.timeIntervalSince1970))"
        let adaptedResponse = ModelAdapter.adapt(appleResponse: appleResponse, token: token, installDate: installDate)
        
        var apiPath: String
        #if DEBUG
        apiPath = Constants.serverDEVAPI
        print("ADAPTED RESPONSE: \(adaptedResponse)")
        #else
        apiPath = Constants.serverAPI
        #endif
        
        var request = URLRequest(url: URL(string:apiPath)!)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let encodedData = try? JSONSerialization.data(withJSONObject: adaptedResponse, options: [])
        request.httpBody = encodedData
        URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            guard error == nil, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else { return }
            Storage.storeValue(value: encodedData, forKey: Constants.attributionSendKey)
            print("STORE RESPONSE")
        }).resume()
    }
}
