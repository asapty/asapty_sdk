//
//  NetworkSession.swift
//  
//
//  Created by Aleksei Cherepanov on 07.08.2022.
//

import Foundation
import AdServices

protocol NetworkSession {
    @available(iOS 14.3, *) var attributionToken: String? { get }
    func sendRequest(_ request: URLRequest, completionHandler: @escaping (Data?, Int, Error?) -> Void)
}

extension URLSession: NetworkSession {
    @available(iOS 14.3, *) var attributionToken: String? {
        try? AAAttribution.attributionToken()
    }
    
    func sendRequest(_ request: URLRequest, completionHandler: @escaping (Data?, Int, Error?) -> Void) {
        let task = dataTask(with: request) { data, response, error in
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            completionHandler(data, statusCode, error)
        }
        task.resume()
    }
}
