//
//  Dispatcher.swift
//  Core
//
//  Created by Pavel Kuznetsov on 12.10.2021.
//

import Foundation

// sourcery: AutoMockable
public protocol Dispatching {
    static var main: Dispatching { get }
    static var userInteractive: Dispatching { get }
    static var userInitiated: Dispatching { get }
    static var `default`: Dispatching { get }
    static var utility: Dispatching { get }
    static var background: Dispatching { get }

    func async(delay: TimeInterval?, work: @escaping () -> Void)
    func async(delay: TimeInterval?, work: DispatchWorkItem)
    
    func async(_ work: @escaping () -> Void)
    func async(_ work: DispatchWorkItem)
    
    func sync(_ work: @escaping () -> Void)
    func sync(_ work: DispatchWorkItem)
}

public final class Dispatcher: Dispatching {
    public static let main: Dispatching = Dispatcher(queue: .main)
    public static let userInteractive: Dispatching = Dispatcher(queue: .global(qos: .userInteractive))
    public static let userInitiated: Dispatching = Dispatcher(queue: .global(qos: .userInitiated))
    public static let `default`: Dispatching = Dispatcher(queue: .global(qos: .default))
    public static let utility: Dispatching = Dispatcher(queue: .global(qos: .utility))
    public static let background: Dispatching = Dispatcher(queue: .global(qos: .background))

    public init(queue: DispatchQueue) {
        self.queue = queue
    }
    
    public func async(_ work: @escaping () -> Void) {
        async(delay: nil, work: work)
    }
    
    public func async(_ work: DispatchWorkItem) {
        async(delay: nil, work: work)
    }

    public func async(delay: TimeInterval? = nil, work: @escaping () -> Void) {
        if let delay = delay {
            queue.asyncAfter(deadline: .now() + delay, execute: work)
        } else {
            queue.async(execute: work)
        }
    }

    public func async(delay: TimeInterval? = nil, work: DispatchWorkItem) {
        if let delay = delay {
            queue.asyncAfter(deadline: .now() + delay, execute: work)
        } else {
            queue.async(execute: work)
        }
    }

    public func sync(_ work: @escaping () -> Void) {
        queue.sync(execute: work)
    }

    public func sync(_ work: DispatchWorkItem) {
        queue.sync(execute: work)
    }

    // MARK: - Private

    private let queue: DispatchQueue
}
