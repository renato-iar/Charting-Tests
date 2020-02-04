//
//  Observables.swift
//  Observables
//
//  Created by Renato Ribeiro on 03/02/2020.
//  Copyright © 2020 Renato Ribeiro. All rights reserved.
//

public struct ObserverKey: Hashable, Equatable {
    private static var key_index: Int   = 0
    private static func next_key_index() -> Int {
        self.key_index += 1
        return self.key_index
    }

    private let key: Int

    fileprivate init() {
        self.key    = ObserverKey.next_key_index()
    }

    public var hashValue: Int { return self.key.hashValue }

    public func hash(into hasher: inout Hasher) {
        self.key.hash(into: &hasher)
    }

    public static func == (lhs: ObserverKey, rhs: ObserverKey) -> Bool {
        return lhs.key == rhs.key
    }
}

public class Observable<ObservedType> {

    private var will_change_observers: [ObserverKey: Observable<ObservedType>.WillChangeObserverCallback]   = [:]
    private var did_change_observers: [ObserverKey: Observable<ObservedType>.DidChangeObservedCallback]     = [:]

    public struct ObserverCallbackArgument {
        public let from: ObservedType
        public let to: ObservedType

        public var old: ObservedType { return self.from }
        public var new: ObservedType { return self.to }

        fileprivate init(from: ObservedType, to: ObservedType) {
            self.from   = from
            self.to     = to
        }
    }
    public typealias WillChangeObserverCallback = (Observable<ObservedType>.ObserverCallbackArgument) -> Void
    public typealias DidChangeObservedCallback  = (Observable<ObservedType>.ObserverCallbackArgument) -> Void

    public fileprivate(set) final var value: ObservedType {
        willSet {
            for (_, observer) in self.will_change_observers {
                observer(ObserverCallbackArgument(from: self.value, to: newValue))
            }
        }
        didSet {
            for (_, observer) in self.did_change_observers {
                observer(ObserverCallbackArgument(from: oldValue, to: self.value))
            }
        }
    }

    public final func register(willChange observer: @escaping Observable<ObservedType>.WillChangeObserverCallback) -> ObserverKey {
        let key = ObserverKey()
        self.will_change_observers[key] = observer

        return key
    }
    public final func unregister(willChangeObserverWith key: ObserverKey) -> () {
        self.will_change_observers[key] = nil
    }

    public final func register(didChange observer: @escaping Observable<ObservedType>.DidChangeObservedCallback) -> ObserverKey {
        let key = ObserverKey()
        self.did_change_observers[key] = observer

        return key
    }
    public final func unregister(didChangeObserverWith key: ObserverKey) -> () {
        self.did_change_observers[key] = nil
    }

    public init(with value: ObservedType) {
        self.value  = value
    }

}

extension Observable {

    public func unregister(willChangeObserverWith key: ObserverKey?) -> () {
        if let key = key {
            self.unregister(willChangeObserverWith: key)
        }
    }
    public func unregister(didChangeObserverWith key: ObserverKey?) -> () {
        if let key = key {
            self.unregister(didChangeObserverWith: key)
        }
    }

}

public final class MutableObservable<ObservedType>: Observable<ObservedType> {

    public final var writable: ObservedType {
        get {
            return self.value
        }
        set {
            self.value  = newValue
        }
    }

    public override init(with value: ObservedType) {
        super.init(with: value)
    }

}

public protocol ZeroValued {

    static var zero: Self { get }

}

extension Array: ZeroValued {
    public static var zero: Array<Element> {
        return []
    }
}

extension Int: ZeroValued {
    public static var zero: Int { return 0 }
}

extension Float: ZeroValued {
    public static var zero: Float { return 0 }
}

extension Double: ZeroValued {
    public static var zero: Double { return 0 }
}

extension Int8: ZeroValued {
    public static var zero: Int8 { return 0 }
}

extension Int16: ZeroValued {
    public static var zero: Int16 { return 0 }
}

extension Int32: ZeroValued {
    public static var zero: Int32 { return 0 }
}

extension Int64: ZeroValued {
    public static var zero: Int64 { return 0 }
}

extension Bool: ZeroValued {
    public static var zero: Bool { return false }
}

public extension MutableObservable where ObservedType: ZeroValued {
    convenience init() {
        self.init(with: ObservedType.zero)
    }
}

public typealias MutableObservableBool      = MutableObservable<Bool>
public typealias ObservableBool             = Observable<Bool>

public typealias MutableObservableInt       = MutableObservable<Int>
public typealias ObservableInt              = Observable<Int>

public typealias MutableObservableDouble    = MutableObservable<Double>
public typealias ObservableDouble           = Observable<Double>

public typealias MutableObservableFloat     = MutableObservable<Float>
public typealias ObservableFloat            = Observable<Float>

