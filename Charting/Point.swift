//
//  Point.swift
//  Charting
//
//  Created by Renato Ribeiro on 12/12/2019.
//  Copyright © 2019 Elphucorp, Lda. All rights reserved.
//

import Foundation
import CoreGraphics

public protocol Point2D {
    var x: CGFloat { get }
    var y: CGFloat { get }

    init(x: CGFloat, y: CGFloat)
}

public extension Point2D {
    var cgPoint: CGPoint {
        return CGPoint(x: self.x, y: self.y)
    }
}

extension CGPoint: Point2D {

}

public struct PointCluster: Point2D {

    public let point: Point2D
    public let data: [Point2D]

    public var x: CGFloat { return self.point.x }
    public var y: CGFloat { return self.point.y }

    public init(x: CGFloat, y: CGFloat) {
        self.point  = CGPoint(x: x, y: y)
        self.data   = []
    }
    public init(x: CGFloat, y: CGFloat, data: [Point2D]) {
        self.data   = data
        self.point  = CGPoint(x: x, y: y)
    }

}

public func / (_ point: Point2D, _ k: CGFloat) -> Point2D {
    return type(of: point).init(x: point.x / k, y: point.y / k)
}
public func * (_ point: Point2D, _ k: CGFloat) -> Point2D {
    return type(of: point).init(x: point.x * k, y: point.y * k)
}
public func + (_ a: Point2D, _ b: Point2D) -> Point2D {
    return type(of: a).init(x: a.x + b.x, y: a.y + b.y)
}
public func - (_ a: Point2D, _ b: Point2D) -> Point2D {
    return type(of: a).init(x: a.x - b.x, y: a.y - b.y)
}

public extension Point2D {

    var length: CGFloat { return sqrt(self.dot(self)) }
    var normalized: Point2D { return self / self.length }

    func rotate(_ radians: CGFloat) -> Point2D {
        let cos_a = cos(radians)
        let sin_a = sin(radians)

        return type(of: self).init(x: cos_a*self.length, y: sin_a*self.length)
    }
    func scale(_ xScale: CGFloat, _ yScale: CGFloat) -> Point2D {
        return type(of: self).init(x: xScale * self.x, y: yScale * self.y)
    }
    func translate(_ dx: CGFloat, _ dy: CGFloat) -> Point2D {
        return type(of: self).init(x: self.x + dx, y: self.y + dy)
    }
    func dot(_ point: Point2D) -> CGFloat {
        return self.x*point.x + self.y*point.y
    }
    func distance(_ point: Point2D) -> CGFloat {
        let v   = point - self
        return sqrt(v.x * v.x + v.y * v.y)
    }
    var angleRelativeToXAxis: CGFloat {
        let r: CGFloat
        let a: CGFloat  = -atan2(y, x)

        if a < 0 {
            r   = CGFloat.pi * 2 + a
        }
        else {
            r   = a
        }

        return r
    }

}


