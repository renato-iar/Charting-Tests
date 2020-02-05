//
//  Utils.swift
//  Utils
//
//  Created by Renato Ribeiro on 04/02/2020.
//  Copyright © 2020 Renato Ribeiro. All rights reserved.
//

public struct Utils {

    private init() {
    }

}

public func then<A, B> (_ f: @escaping (A) -> B?) -> ((A?) -> B?) {
    return {
        input in
        if let value = input {
            return f(value)
        }
        return nil
    }
}
