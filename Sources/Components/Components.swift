//
//  Components.swift
//  ASAPTY
//
//  Created by Pavel Kuznetsov on 23.02.2022.
//

import Foundation

struct Constants {
    // UserDefaults keys
    static let database = "asapty_database"
    static let currentSDKVersion = "0.4.0"
    // Server APIs
    #if DEBUG
    static let serverAPI = "https://asapty.com/_api/mmpEvents/"
    #else
    static let serverAPI = "https://dev.asapty.com/_api/mmpEvents/"
    #endif
}

struct ServerPollingResponse: Codable {
    enum EncodingKeys: String, CodingKey {
        case id, status, completed, failed
    }
    
    let id: String
    let status: String
    let completed: Bool
    let failed: Bool
    
    init(id: String, status: String, completed: Bool, failed: Bool) {
        self.id = id
        self.status = status
        self.completed = completed
        self.failed = failed
    }
    
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: EncodingKeys.self)
//        id = try container.decode(String.self, forKey: .id)
//        status = try container.decode(String.self, forKey: .status)
//        completed = try container.decode(Bool.self, forKey: .completed)
//        failed = try container.decode(Bool.self, forKey: .failed)
//    }
}

struct ReceiptValidation: Codable {
    enum EncodingKeys: String, CodingKey {
        case receiptData = "receipt-data"
        case bundleId
        case attributionId
        case amount
        case transactionId
        case processed
    }
    let receiptData: String
    let bundleId: String
    let attributionId: String
    let amount: String
    var processed: Bool = false
    let transactionId: String
    
    init(receiptData: String, bundleId: String, attributionId: String, amount: String, transactionId: String) {
        self.receiptData = receiptData
        self.bundleId = bundleId
        self.attributionId = attributionId
        self.amount = amount
        self.transactionId = transactionId
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: EncodingKeys.self)
        receiptData = try container.decode(String.self, forKey: .receiptData)
        bundleId = try container.decode(String.self, forKey: .bundleId)
        attributionId = try container.decode(String.self, forKey: .attributionId)
        amount = try container.decode(String.self, forKey: .amount)
        transactionId = try container.decode(String.self, forKey: .transactionId)
        processed = try container.decode(Bool.self, forKey: .processed)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: EncodingKeys.self)
        try container.encode(receiptData, forKey: .receiptData)
        try container.encode(bundleId, forKey: .bundleId)
        try container.encode(attributionId, forKey: .attributionId)
        try container.encode(amount, forKey: .amount)
        try container.encode(processed, forKey: .processed)
        try container.encode(transactionId, forKey: .transactionId)
    }
    
    func dictionaryRepresentation() -> [String: Any] {
        return [
            EncodingKeys.receiptData.rawValue: receiptData,
            EncodingKeys.amount.rawValue: amount,
            EncodingKeys.attributionId.rawValue: attributionId,
            EncodingKeys.bundleId.rawValue: bundleId,
            EncodingKeys.transactionId.rawValue: transactionId,
        ]
    }
}

struct ModelAdapter {
    private struct Keys {
        static let asaptyid = "asaptyid"
        static let source = "source"
        static let campaignid = "campaignid"
        static let installTime = "install_time"
        static let adgroupid = "adgroupid"
        static let keywordid = "keywordid"
        static let orgname = "orgname"
        static let iadCreativeId = "iad-creative-id"
    }
    static func adapt(appleResponse: [String: Any], token: String, installDate: String) -> [String: String] {
        var result: [String: String] = [:]
        result[Keys.asaptyid] = token
        result[Keys.source] = "sdk"
        if let campaignId = appleResponse["campaignId"] as? Int {
            result[Keys.campaignid] = "\(campaignId)"
        }
        result[Keys.installTime] = installDate
        if let adGroupId = appleResponse["adGroupId"] as? Int {
            result[Keys.adgroupid] = "\(adGroupId)"
        }
        if let keywordId = appleResponse["keywordId"] as? Int {
            result[Keys.keywordid] = "\(keywordId)"
        }
        if let orgId = appleResponse["orgId"] as? Int {
            result[Keys.orgname] = "\(orgId)"
        }
        if let adId = appleResponse["adId"] as? Int {
            result[Keys.iadCreativeId] = "\(adId)"
        }
        return result
    }
}
