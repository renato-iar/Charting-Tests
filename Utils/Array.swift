//
//  Array.swift
//  Utils
//
//  Created by Renato Ribeiro on 05/02/2020.
//  Copyright © 2020 Renato Ribeiro. All rights reserved.
//

import Foundation

public extension Array {

    func fmap(_ f: (Array.Element) -> Void) -> Void {
        for x in self {
            f(x)
        }
    }

}
