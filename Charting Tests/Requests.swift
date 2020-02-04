//
//  Requests.swift
//  Charting Tests
//
//  Created by Renato Ribeiro on 03/02/2020.
//  Copyright © 2020 Renato Ribeiro. All rights reserved.
//

import Foundation

public protocol Cancelable {
    func cancel() -> Void

    var isExecuted: Bool { get }
    var isCancelled: Bool { get }
}

public class DummyRequest: Cancelable {

    private var callback: (() -> Void)?
    private var timer: Timer? = nil {
        willSet {
            self.timer?.invalidate()
        }
    }

    private func fire() -> () {
        if self.isCancelled || self.isExecuted {
            return
        }

        self.isExecuted = true
        self.timer      = nil

        self.callback?()
        self.callback   = nil
    }

    public private(set) final var isExecuted: Bool  = false
    public private(set) final var isCancelled: Bool = false

    public func cancel() -> () {
        if self.isCancelled || self.isExecuted {
            return
        }

        self.isCancelled    = true
        self.timer          = nil
    }

    public init(interval t: TimeInterval, _ callback: @escaping () -> Void) {
        self.callback   = callback
        self.timer      = Timer.scheduledTimer(withTimeInterval: t, repeats: false) {
            [weak self] timer in
            self?.fire()
        }
    }

}
