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
    static let firstRunKey = "asapty_first_run_key"
    static let attributionSendKey = "asapty_attribution_send_key"
    static let serverPollingID = "server_polling_ID"
    static let currentSDKVersion = "0.3.0"
    // Server APIs
    static let serverAPI = "https://asapty.com/_api/mmpEvents/"
    static let serverDEVAPI = "https://dev.asapty.com/_api/mmpEvents/"
    static let serverByTokenDEVAPI = "https://dev.asapty.com/_api/mmpEvents/byToken"
    static let serverByTokenAPI = "https://asapty.com/_api/mmpEvents/byToken"
}

final class Storage {
    static var firstRunDate: Date = {
        if let date: Date = Storage.value(forKey: Constants.firstRunKey) {
            return date
        }
        
        let date = Date()
        Storage.storeValue(value: date, forKey: Constants.firstRunKey)
        return date
    }()
    
    class func storeValue<T>(value: T, forKey key: String) {
        UserDefaults(suiteName: Constants.database)?.set(value, forKey: key)
    }
    
    class func value<T>(forKey key: String) -> T? {
        guard let value = UserDefaults(suiteName: Constants.database)?.value(forKey: key) as? T else { return nil }
        return value
    }
    
    class func deleteValue(forKey key: String) {
        UserDefaults(suiteName: Constants.database)?.removeObject(forKey: key)
    }
}

struct ServerPollingResponse: Decodable {
    enum EncodingKeys: String, CodingKey {
        case id
        case status
        case completed
        case failed
    }
    
    let id: String
    let status: String
    let completed: Bool
    let failed: Bool
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: EncodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        status = try container.decode(String.self, forKey: .status)
        completed = try container.decode(Bool.self, forKey: .completed)
        failed = try container.decode(Bool.self, forKey: .failed)
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
