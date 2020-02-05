//
//  OptionalExtensions.swift
//  Utils
//
//  Created by Renato Ribeiro on 04/02/2020.
//  Copyright © 2020 Renato Ribeiro. All rights reserved.
//

import Foundation

public extension Optional {

    func then<B>(_ f: @escaping (Wrapped) -> B?) -> B? {
        if case let .some(value) = self {
            return f(value)
        }
        return nil
    }

}
