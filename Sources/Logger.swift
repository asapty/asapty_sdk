//
//  Logger.swift
//  
//
//  Created by Aleksei Cherepanov on 07.08.2022.
//

import Foundation
import os

public protocol AsaptyLogger {
    var logLevel: OSLogType { get set }
    func debug(_ message: String, logger: OSLog)
    func error(_ message: String, logger: OSLog)
}

extension OSLog {
    static let general = OSLog(subsystem: "ASAPTY", category: "General")
    static let network = OSLog(subsystem: "ASAPTY", category: "NetworkWorker")
    static let inAppListener = OSLog(subsystem: "ASAPTY", category: "InAppListener")
}

class Logger: AsaptyLogger {
    var logLevel: OSLogType = .error
    
    init() {}
    
    func debug(_ message: String, logger: OSLog = .general) {
        guard logLevel <= .debug else { return }
        os_log("%@", log: logger, type: .debug, message)
    }

    func error(_ message: String, logger: OSLog = .general) {
        guard logLevel <= .error else { return }
        os_log("%@", log: logger, type: .error, message)
    }
}

func <=(_ lhs: OSLogType, _ rhs: OSLogType) -> Bool {
    lhs.rawValue <= rhs.rawValue
}
