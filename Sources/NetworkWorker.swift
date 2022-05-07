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
        if #available(iOS 14.3, *) {
            if let data: Data = Storage.value(forKey: Constants.serverPollingID),
               let serverResponse = try? JSONDecoder().decode(ServerPollingResponse.self, from: data) {
                if !serverResponse.failed, !serverResponse.completed {
                    pollingServerID(serverResponse.id)
                } else {
                    return
                }
            }
            
            guard let attributionToken = try? AAAttribution.attributionToken() else { return }
            let _ = Storage.firstRunDate
            DispatchQueue.global().async { [weak self] in
                guard let self = self else { return }
                self.putAttributionToken(attr: attributionToken)
            }
        }
    }
    
    public func track(eventName: String, productId: String?, revenue: String?, currency: String?) {
        guard let data: Data = Storage.value(forKey: Constants.serverPollingID),
        let serverResponse = try? JSONDecoder().decode(ServerPollingResponse.self, from: data) else { return }
        var rawData = [String: Any]()
        rawData["event_name"] = eventName
        let innerJson = ["af_content_id": productId ?? "",
                         "af_revenue": revenue ?? "",
                         "af_currency": currency ?? "" ]
        guard let innerJSONData = try? JSONSerialization.data(withJSONObject: innerJson, options: []) else { return }
        let innerJSONDataString = String(data: innerJSONData, encoding: String.Encoding.ascii)
        rawData["json"] = innerJSONDataString
        rawData["attributionId"] = serverResponse.id
        rawData["source"] = "sdk_\(Constants.currentSDKVersion)"
        rawData["install_time"] = "\(Int64(Storage.firstRunDate.timeIntervalSince1970))"
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
    
    private func putAttributionToken(attr: String) {
        var apiPath: String
        #if DEBUG
        apiPath = Constants.serverByTokenDEVAPI
        #else
        apiPath = Constants.serverByTokenAPI
        #endif
        
        var request = URLRequest(url: URL(string:apiPath)!)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let uploadData = [
            "token": attr,
            "asaptyId": "\(userToken)",
            "source": "sdk_\(Constants.currentSDKVersion)"
        ]
        let encodedData = try? JSONSerialization.data(withJSONObject: uploadData, options: [])
        request.httpBody = encodedData
        URLSession.shared.dataTask(with: request, completionHandler: { [weak self] data, response, error in
            guard let self = self, error == nil,
                  let data = data,
                  let rawData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let result = rawData["result"], let resultData = try? JSONSerialization.data(withJSONObject: result, options: []),
                  let serverResponse = try? JSONDecoder().decode(ServerPollingResponse.self, from: resultData)
            else { return }
            
            Storage.storeValue(value: resultData, forKey: Constants.serverPollingID)
            print("STORE ID \(serverResponse.id)")
            
            if serverResponse.failed { return }
            
            if !serverResponse.completed {
                self.pollingServerID(serverResponse.id)
            }
        }).resume()
    }
    
    private func pollingServerID(_ id: String) {
        var apiPath: String
        #if DEBUG
        apiPath = "\(Constants.serverByTokenDEVAPI)/?id=\(id)"
        #else
        apiPath = "\(Constants.serverByTokenAPI)/?id=\(id)"
        #endif
        
        var request = URLRequest(url: URL(string:apiPath)!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        URLSession.shared.dataTask(with: request, completionHandler: { [weak self] data, response, error in
            guard let self = self, error == nil,
                  let data = data,
                  let rawData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let result = rawData["result"], let resultData = try? JSONSerialization.data(withJSONObject: result, options: []),
                  let serverResponse = try? JSONDecoder().decode(ServerPollingResponse.self, from: resultData)
            else { return }
            
            Storage.storeValue(value: resultData, forKey: Constants.serverPollingID)
            print("STORE ID FROM POLLING \(serverResponse.id)")
            
            if serverResponse.failed { return }
            
            if !serverResponse.completed {
                Dispatcher.background.async(delay: 1) { [weak self] in
                    self?.pollingServerID(serverResponse.id)
                }
            }
        }).resume()
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
