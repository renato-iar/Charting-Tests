//
//  Axis.swift
//  Charting
//
//  Created by Renato Ribeiro on 12/12/2019.
//  Copyright © 2019 Elphucorp, Lda. All rights reserved.
//

import Foundation
import CoreGraphics

public struct ChartAxis {
    public var origin: CGFloat  = 0
    public var length: CGFloat  = 1

    public init(origin o: CGFloat = 0, length l: CGFloat = 1) {
        self.origin = o
        self.length = l
    }
}
