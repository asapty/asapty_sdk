//
//  UserDefaultsStorageTests.swift
//  
//
//  Created by Aleksei Cherepanov on 07.08.2022.
//

import XCTest
@testable import ASAPTY_SDK

class UserDefaultsStorageTests: XCTestCase {
    private var userDefaults: UserDefaults!
    private var storage: UserDefaultsStorage!
    
    override func setUp() {
        super.setUp()
        userDefaults = UserDefaults(suiteName: "TEST_SUITE")!
        userDefaults.removePersistentDomain(forName: "TEST_SUITE")
        storage = UserDefaultsStorage(suiteName: "TEST_SUITE")
    }
    
    func testFirstRunDate() {
        let beforeDate = Date()
        let firstValue = userDefaults.value(forKey: StorageKey.firstRun.rawValue)
        XCTAssertNil(firstValue)
        let date = storage.firstRunDate
        let secondValue = userDefaults.value(forKey: StorageKey.firstRun.rawValue)
        XCTAssertNotNil(secondValue)
        let savedDate = secondValue as? Date
        XCTAssertNotNil(savedDate)
        XCTAssertTrue(date.compare(savedDate!) == .orderedSame)
        let afterDate = Date()
        XCTAssertTrue(beforeDate.compare(savedDate!) == .orderedAscending)
        XCTAssertTrue(afterDate.compare(savedDate!) == .orderedDescending)
    }
    
    func testStoreValue() {
        let firstValue = userDefaults.value(forKey: StorageKey.attributionSend.rawValue)
        XCTAssertNil(firstValue)
        let value = "test_string"
        storage.storeValue(value: value, forKey: .attributionSend)
        let secondValue = userDefaults.string(forKey: StorageKey.attributionSend.rawValue)
        XCTAssertNotNil(secondValue)
        XCTAssertEqual(value, secondValue!)
    }
    
    func testGetValue() {
        let value = "test_string"
        userDefaults.set(value, forKey: StorageKey.attributionSend.rawValue)
        let result: String? = storage.getValue(forKey: .attributionSend)
        XCTAssertNotNil(result)
        XCTAssertEqual(value, result!)
    }
    
    func testDeleteValue() {
        let value = "test_string"
        userDefaults.set(value, forKey: StorageKey.attributionSend.rawValue)
        let savedValue: String? = storage.getValue(forKey: .attributionSend)
        XCTAssertNotNil(savedValue)
        storage.deleteValue(forKey: .attributionSend)
        let result: String? = storage.getValue(forKey: .attributionSend)
        XCTAssertNil(result)
    }
}
