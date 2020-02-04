//
//  PiePlot.swift
//  Charting
//
//  Created by Renato Ribeiro on 14/12/2019.
//  Copyright © 2019 Elphucorp, Lda. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit

public typealias PiePlotSegment       = CGFloat

public protocol PiePlotSegmentConvertible {
    var value: PiePlotSegment { get }
}

public struct PieSliceProperties {
    let paint: [Paint]
    let radiusPercent: CGFloat?
    let holeRadiusPercent: CGFloat?

    public init(paint ps: [Paint], radius percent: CGFloat? = nil, hole holeRadiusPercent: CGFloat? = nil) {
        self.paint              = ps
        self.radiusPercent      = percent
        self.holeRadiusPercent  = holeRadiusPercent
    }
}

public final class PiePlot<SliceType: PiePlotSegmentConvertible>: SegmentedPlot2D<SliceType> {

    public typealias PieSlicePropertiesArgumentsCallback                                                                    = (arguments: [String: Any]?, value: PiePlotSegment, total: PiePlotSegment, min: CGFloat, max: CGFloat, index: Int, count: Int)

    public final var pieSlicePropertiesCallback: ((PiePlot.PieSlicePropertiesArgumentsCallback) -> PieSliceProperties)? = nil

    public private(set) final var max: CGFloat      = 0
    public private(set) final var min: CGFloat      = 0
    public private(set) final var total: CGFloat    = 0

    public override func hook_SegmentsDidChange(from: [SliceType], to: [SliceType]) -> () {
        var total: CGFloat  = 0
        var min: CGFloat    = 0
        var max: CGFloat    = 0
        var first           = true

        for segment in to {
            let value   = segment.value

            if first {
                first   = false
                min     = value
                max     = value
            }
            else {
                min     = Swift.min(min, value)
                max     = Swift.max(max, value)
            }

            total   += value
        }

        self.total  = total
        self.min    = min
        self.max    = max

        super.hook_SegmentsDidChange(from: from, to: to)
    }
    public override func hook_PathPaint(for segment: SliceType, at index: Int, of total: Int, for chart: ChartLayer, parameters ps: [String : Any]?) -> [Paint]? {
        return self.pieSlicePropertiesCallback?((ps, segment.value, self.total, self.min, self.max, index, total)).paint
    }
    public override func hook_DrawPath(for segment: SliceType, at index: Int, of total: Int, transform m: UnsafePointer<CGAffineTransform>, for chart: ChartLayer, parameters ps: [String : Any]?) -> CGPath? {
        let path            = CGMutablePath()
        let t               = m.pointee
        let center          = chart.transformToViewCoordinates(point: chart.axisCenter).cgPoint
        let radius: CGFloat
        let start_angle: CGFloat
        let end_angle: CGFloat

        let props           = self.pieSlicePropertiesCallback?((ps, segment.value, self.total, self.min, self.max, index, total))
        let radius_percent  = props?.radiusPercent ?? 1.0

        if chart.xAxis.length < chart.yAxis.length {
            radius  = chart.transformToViewCoordinate(x: chart.xAxis.length - chart.xAxis.origin) * 0.5
        }
        else {
            radius  = chart.transformToViewCoordinate(y: chart.yAxis.length - chart.yAxis.origin) * 0.5
        }

        if index > 0 {
            var accum: PiePlotSegment = PiePlotSegment()
            for i in 0 ..< index {
                accum   += self.segments[i].value
            }
            start_angle = (accum / self.total) * CGFloat.pi * 2.0
        }
        else {
            start_angle = 0
        }

        end_angle   = start_angle + (segment.value / self.total) * CGFloat.pi * 2.0

        if let hole_percent = props?.holeRadiusPercent {
            path.addArc(center: center, radius: hole_percent * radius, startAngle: end_angle, endAngle: start_angle, clockwise: true, transform: t)
            path.addArc(center: center, radius: radius * radius_percent, startAngle: start_angle, endAngle: end_angle, clockwise: false, transform: t)
        }
        else {
            path.move(to: center, transform: t)
            path.addArc(center: center, radius: radius * radius_percent, startAngle: start_angle, endAngle: end_angle, clockwise: false, transform: t)
        }
        path.closeSubpath()

        return path
    }
    public override func hook_intersects(pointInViewCoordinates point: Point2D, in chart: ChartLayer) -> IntersectionResult? {

        var result: IntersectionResult?   = nil
        var i                               = 0
        var start_angle: CGFloat            = 0
        let n                               = self.segments.count
        let center                          = chart.transformToViewCoordinates(point: chart.axisCenter).cgPoint
        let radius: CGFloat

        if chart.xAxis.length < chart.yAxis.length {
            radius  = chart.transformToViewCoordinate(x: chart.xAxis.length - chart.xAxis.origin) * 0.5
        }
        else {
            radius  = chart.transformToViewCoordinate(y: chart.yAxis.length - chart.yAxis.origin) * 0.5
        }

        let vector_to_center                = (point - center).normalized.cgPoint
        let total                           = self.total
        let angle                           = vector_to_center.angleRelativeToXAxis
        let distance_to_center              = point.distance(center)

        while i < n && result == nil {
            let segment                     = self.segments[i].value
            let segment_properties          = self.pieSlicePropertiesCallback?((nil, segment, total, self.min, self.max, i, n))
            let radius_percent              = segment_properties?.radiusPercent ?? 1.0
            let hole_percent                = segment_properties?.holeRadiusPercent ?? 0.0
            let end_angle: CGFloat          = start_angle + ((segment / total) * 2.0 * CGFloat.pi)

            if
                distance_to_center <= radius*radius_percent &&
                distance_to_center >= radius*hole_percent &&
                angle >= start_angle &&
                angle <= end_angle
            {
                result  = IntersectionResult(index: i, data: segment)
            }

            i           += 1
            start_angle = end_angle
        }

        return result

    }

}

extension Float: PiePlotSegmentConvertible {
    public var value: PiePlotSegment {
        return PiePlotSegment(self)
    }
}

extension CGFloat: PiePlotSegmentConvertible {
    public var value: PiePlotSegment {
        return PiePlotSegment(self)
    }
}

extension Double: PiePlotSegmentConvertible {
    public var value: PiePlotSegment {
        return PiePlotSegment(self)
    }
}

extension Int: PiePlotSegmentConvertible {
    public var value: PiePlotSegment {
        return PiePlotSegment(self)
    }
}
