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
    public class func attribution(withToken token: String) {
        guard Storage.value(forKey: Constants.attributionSendKey) == nil else { return }
        
        let service = NetworkWorker()
        if #available(iOS 14.3, *) {
            guard let attributionToken = try? AAAttribution.attributionToken() else { return }
            DispatchQueue.global().async {
                service.requestAttribution(with: attributionToken) { result in
                    switch result {
                    case .failure:
                        return
                    case let .success(response):
                        service.sendAttribution(withToken: token, appleResponse: response)
                    }
                }
            }
        }
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
        print("ADAPTED RESPONSE: \(adaptedResponse)")
        var apiPath: String
        #if DEBUG
        apiPath = Constants.serverDEVAPI
        #else
        apiPath = Constants.serverAPI
        #endif
        
        var request = URLRequest(url: URL(string:apiPath)!)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: adaptedResponse, options: [])
        URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            guard error == nil, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else { return }
            Storage.storeValue(value: true, forKey: Constants.attributionSendKey)
        })
    }
}
