//
//  Storage.swift
//  
//
//  Created by Aleksei Cherepanov on 07.08.2022.
//

import Foundation

protocol Storage {
    var firstRunDate: Date { get }
    func storeValue<T>(value: T, forKey key: StorageKey)
    func getValue<T>(forKey key: StorageKey) -> T?
    func deleteValue(forKey key: StorageKey)
}

enum StorageKey: String {
    case firstRun = "asapty_first_run_key"
    case inAppEvents = "in_app_events_key"
    case serverPollingId = "server_polling_ID"
    case attributionSend = "asapty_attribution_send_key"
}

final class UserDefaultsStorage: Storage {
    static let `default` = UserDefaultsStorage(suiteName: Constants.database)
    let defaults: UserDefaults?
    
    var firstRunDate: Date {
        if let date: Date = getValue(forKey: .firstRun) { return date }
        let date = Date()
        storeValue(value: date, forKey: .firstRun)
        return date
    }
    
    init(suiteName: String) {
        defaults = UserDefaults(suiteName: suiteName)
    }
    
    func storeValue<T>(value: T, forKey key: StorageKey) {
        defaults?.set(value, forKey: key.rawValue)
    }
    
    func getValue<T>(forKey key: StorageKey) -> T? {
        defaults?.value(forKey: key.rawValue) as? T
    }
    
    func deleteValue(forKey key: StorageKey) {
        defaults?.removeObject(forKey: key.rawValue)
    }
}
