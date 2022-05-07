//
//  Command.swift
//  Core
//
//  Created by Pavel Kuznetsov on 12.10.2021.
//

import Foundation

public final class Command<T> {
    public init(id: String? = nil,
                file: StaticString = #file,
                function: StaticString = #function,
                line: Int = #line,
                action: @escaping (T) -> Void) {
        self.id = id
        self.action = action
        self.function = function
        self.file = file
        self.line = line
    }

    public func perform(with value: T) {
        action(value)
    }

    public static var nop: Command {
        Command { _ in }
    }

    /**
     Wraps a command into a new command that will throttle the execution to once in every `delay` seconds.

     - Parameter delay: A `TimeInterval` specifying the minimum number of seconds that needs to pass between each execution of `action`.
     - Parameter queue: The queue to perform the action on. Defaults to the main queue.

     - Returns: A new command that will only call `action` once every `delay` seconds at best, regardless of how often it is called.
     */
    public func throttled(with delay: TimeInterval, dispatcher: Dispatching = Dispatcher.main) -> Command {
        var previousRun = Date.distantPast
        var work: DispatchWorkItem?
        return Command(id: id, file: file, function: function, line: line, action: { value in
            work?.cancel()
            work = DispatchWorkItem {
                previousRun = Date()
                self.perform(with: value)
                work = nil
            }
            let delay = Date().timeIntervalSince(previousRun) > delay ? 0 : delay
            dispatcher.async(delay: delay, work: work!)
        })
    }

    /**
     Wraps a command in a new command that will only execute the wrapped command if `delay` has passed without this command being performed.

     - Parameter delay: A `TimeInterval` to wait before executing the wrapped command after last invocation.
     - Parameter queue: The queue to perform the action on. Defaults to the main queue.

     - Returns: A new command that will only call `action` if `delay` time passes between invocations.
     */
    public func debounced(with delay: TimeInterval, dispatcher: Dispatching = Dispatcher.main) -> Command {
        var work: DispatchWorkItem?
        return Command(id: id, file: file, function: function, line: line, action: { value in
            work?.cancel()
            work = DispatchWorkItem {
                self.perform(with: value)
            }
            dispatcher.async(delay: delay, work: work!)
        })
    }

    public func dispatched(on dispatcher: Dispatching) -> Command {
        Command(id: id, file: file, function: function, line: line, action: { value in
            dispatcher.async(delay: nil) {
                self.perform(with: value)
            }
        })
    }

    public func then(_ another: Command) -> Command {
        Command(id: id, file: file, function: function, line: line, action: { value in
            self.perform(with: value)
            another.perform(with: value)
        })
    }

    public func wrapped(with value: T) -> Command<Void> {
        Command<Void>(id: id, file: file, function: function, line: line, action: {
            self.perform(with: value)
        })
    }

    // MARK: - Private

    private let id: String?
    private let file: StaticString
    private let function: StaticString
    private let line: Int
    private let action: (T) -> Void
}

extension Command: Equatable where T: Any {
    public static func == (lhs: Command, rhs: Command) -> Bool {
        if lhs.id != nil || rhs.id != nil {
            return lhs.id == rhs.id
        }
        return
            lhs.file.description == rhs.file.description &&
            lhs.function.description == rhs.function.description &&
            lhs.line == rhs.line
    }
}

extension Command: Hashable where T: Any {
    public func hash(into hasher: inout Hasher) {
        if let id = id {
            hasher.combine(id)
            return
        }
        hasher.combine(file.description)
        hasher.combine(function.description)
        hasher.combine(line)
    }
}

extension Command where T: Any {
    func debugQuickLookObject() -> AnyObject? {
        """
        type: \(String(describing: type(of: self)))
        id: \(id ?? "no id")
        file: \(file)
        function: \(function)
        line: \(line)
        """ as NSString
    }
}

extension Command: CustomStringConvertible where T: Any {
    public var description: String {
        """
        id: \(id ?? "no id")
        file: \(file)
        function: \(function)
        line: \(line)
        """
    }
}
