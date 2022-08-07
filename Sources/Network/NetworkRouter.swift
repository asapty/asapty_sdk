//
//  NetworkRouter.swift
//  
//
//  Created by Aleksei Cherepanov on 07.08.2022.
//

import Foundation

enum NetworkRouter {
    case track
    case putAttributionToken
    case pollingServerId(String)
    case sendAttribution
    case sendInAppReceipt
    
    var method: NetworkMethod {
        switch self {
        case .track, .putAttributionToken, .sendAttribution, .sendInAppReceipt:
            return .put
        case .pollingServerId:
            return .get
        }
    }
    
    func path(_ url: String) -> String {
        switch self {
        case .track, .sendAttribution:
            return url
        case .putAttributionToken:
            return url + "byToken"
        case .pollingServerId(let id):
            return url + "byToken/?id=\(id)"
        case .sendInAppReceipt:
            return url + "verifyReceipt"
        }
    }
}

enum NetworkMethod: String {
    case `get` = "GET", put = "PUT"
}
