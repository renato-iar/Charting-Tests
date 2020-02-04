//
//  ScatterPlot.swift
//  Charting
//
//  Created by Renato Ribeiro on 13/12/2019.
//  Copyright © 2019 Elphucorp, Lda. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit

public final class ScatterPlot: XYPlot2D {

    public struct DotProperties {
        public var radius: CGFloat

        public init(radius rad: CGFloat = 5) {
            self.radius = rad
        }
    }

    public typealias DotPropertiesCallbackArgs  = (parameters: [String: Any]?, index: Int, total: Int)

    public final var dotPropertiesCallback: ((ScatterPlot.DotPropertiesCallbackArgs) -> DotProperties?)?  = nil

    public override func hook_DrawPath(transform m: UnsafePointer<CGAffineTransform>, for chart: ChartLayer, parameters: [String : Any]?) -> CGPath {
        let path    = CGMutablePath()
        let n       = self.points.count
        let t       = m.pointee

        for i in 0 ..< self.points.count {
            if let properties   = self.dotPropertiesCallback?((parameters, i, n)) {
                let point   = self.points[i]
                let pt      = chart.transformToViewCoordinates(point: point).cgPoint
                let rad     = properties.radius
                let rect    = CGRect(x: pt.x - rad, y: pt.y - rad, width: rad*2, height: rad*2)

                path.addEllipse(in: rect, transform: t)
            }
        }

        return path
    }
    public override func hook_intersects(pointInViewCoordinates point: Point2D, in chart: ChartLayer) -> IntersectionResult? {

        var result: IntersectionResult?   = nil
        let adjusted_point                  = CGPoint(x: point.x, y: chart.bounds.height - point.y)
        let n                               = self.points.count
        var i                               = 0

        while i < n && result == nil {
            if let radius = self.dotPropertiesCallback?((nil, i, n))?.radius {
                let p           = chart.transformToViewCoordinates(point: self.points[i]).cgPoint
                let distance    = p.distance(adjusted_point)
                if distance < radius {
                    result          = IntersectionResult(index: i, data: nil)
                }
            }

            i += 1
        }

        return result

    }

}

public typealias BubblePlotSegment    = CGPoint

public final class BubblePlot: SegmentedPlot2D<BubblePlotSegment> {

    public struct BubbleProperties {
        public let radius: CGFloat
        public let paint: [Paint]

        public init(radius rad: CGFloat, paint ps: [Paint]) {
            self.radius = rad
            self.paint  = ps
        }
    }

    public typealias BubblePropertiesCallbackArgs   = (parameters: [String: Any]?, index: Int, count: Int, segment: BubblePlotSegment)

    public final var bubblePropertiesCallback: ((BubblePlot.BubblePropertiesCallbackArgs) -> BubblePlot.BubbleProperties?)? = nil

    public override func hook_DrawPath(for segment: BubblePlotSegment, at index: Int, of total: Int, transform m: UnsafePointer<CGAffineTransform>, for chart: ChartLayer, parameters ps: [String : Any]?) -> CGPath? {

        if let properties = self.bubblePropertiesCallback?((ps, index, total, segment)) {
            let path    = CGMutablePath()
            let pt      = chart.transformToViewCoordinates(point: segment).cgPoint
            let rad     = properties.radius
            let rect    = CGRect(x: pt.x - rad, y: pt.y - rad, width: rad * 2, height: rad * 2)

            path.addEllipse(in: rect, transform: m.pointee)

            return path
        }

        return nil

    }
    public override func hook_PathPaint(for segment: BubblePlotSegment, at index: Int, of total: Int, for chart: ChartLayer, parameters ps: [String : Any]?) -> [Paint]? {
        return self.bubblePropertiesCallback?((ps, index, total, segment))?.paint
    }
    public override func hook_intersects(pointInViewCoordinates point: Point2D, in chart: ChartLayer) -> IntersectionResult? {

        var result: IntersectionResult?   = nil
        let adjusted_point                  = CGPoint(x: point.x, y: chart.bounds.height - point.y)
        let n                               = self.segments.count
        var i                               = 0

        while i < n && result == nil {
            if let radius = self.bubblePropertiesCallback?((nil, i, n, self.segments[i]))?.radius {
                let p           = chart.transformToViewCoordinates(point: self.segments[i]).cgPoint
                let distance    = p.distance(adjusted_point)
                if distance < radius {
                    result          = IntersectionResult(index: i, data: nil)
                }
            }

            i += 1
        }

        return result

    }

}
