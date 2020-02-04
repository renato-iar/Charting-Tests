//
//  BarPlot.swift
//  Charting
//
//  Created by Renato Ribeiro on 13/12/2019.
//  Copyright © 2019 Elphucorp, Lda. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit

public typealias BarPlotSegment   = CGFloat

public protocol BarPlotSegmentConvertible {
    var barValue: BarPlotSegment { get }
}

public final class BarPlot<SegmentType: BarPlotSegmentConvertible>: SegmentedPlot2D<SegmentType?> {

    public typealias BarSegmentPaintCallbackArg                                                         = (parameters: [String: Any]?, index: Int, count: Int, segment: BarPlotSegment)
    public typealias BarSegmentDrawCallbackArg                                                          = (parameters: [String: Any]?, index: Int, count: Int, segment: BarPlotSegment, transform: UnsafePointer<CGAffineTransform>, path: CGMutablePath, rect: CGRect)

    public final var maxValue: BarPlotSegment                                                         = BarPlotSegment(0)
    public final var minValue: BarPlotSegment                                                         = BarPlotSegment(0)

    public final var barSegmentPaintCallback: ((BarPlot.BarSegmentPaintCallbackArg) -> [Paint]?)?   = nil {
        didSet {
            self.chart?.setNeedsDisplay()
        }
    }
    public final var barSegmentDrawCallback: ((BarPlot.BarSegmentDrawCallbackArg) -> Void)?           = nil {
        didSet {
            self.chart?.setNeedsDisplay()
        }
    }
    public final var barSegmentInsets: (left: CGFloat, right: CGFloat)?                                 = nil {
        didSet {
            self.chart?.setNeedsDisplay()
        }
    }

    // MARK: - overrides
    // MARK: EC2DSegmentedPlot
    public override func hook_SegmentsDidChange(from: [SegmentType?], to: [SegmentType?]) -> () {
        var min: BarPlotSegment   = BarPlotSegment(0)
        var max: BarPlotSegment   = BarPlotSegment(0)
        var first: Bool     = true

        for i in 0 ..< to.count {
            guard let value = to[i] else {
                continue
            }

            if first {
                first   = false
                min     = value.barValue
                max     = value.barValue
            }
            else {
                min     = Swift.min(min, value.barValue)
                max     = Swift.max(max, value.barValue)
            }
        }

        self.minValue   = min
        self.maxValue   = max

        super.hook_SegmentsDidChange(from: from, to: to)
    }
    public override func hook_DrawPath(for segment: SegmentType?, at index: Int, of total: Int, transform m: UnsafePointer<CGAffineTransform>, for chart: ChartLayer, parameters ps: [String : Any]?) -> CGPath? {

        guard let value = segment else {
            return nil
        }

        let path    = CGMutablePath()
        let w       = chart.xAxis.length / max(1, CGFloat(total))
        let bottom  = chart.transformToViewCoordinate(y: chart.yAxis.origin)

        let left    = chart.transformToViewCoordinate(x: chart.xAxis.origin + w * CGFloat(index))
        let right   = chart.transformToViewCoordinate(x: chart.xAxis.origin + w * CGFloat(index+1))
        let vw      = right - left
        let top     = chart.transformToViewCoordinate(y: value.barValue)
        let left_inset  = self.barSegmentInsets?.left ?? 0
        let right_inset = self.barSegmentInsets?.right ?? 0
        let rect    = CGRect(x: left + left_inset, y: bottom, width: vw - left_inset - right_inset, height: top - bottom)

        if let callback = self.barSegmentDrawCallback {
            callback((ps, index, total, value.barValue, m, path, rect))
        }
        else {
            path.addRect(rect, transform: m.pointee)
        }

        return path
    }
    public override func hook_PathPaint(for segment: SegmentType?, at index: Int, of total: Int, for chart: ChartLayer, parameters ps: [String : Any]?) -> [Paint]? {

        guard let value = segment else {
            return nil
        }

        return self.barSegmentPaintCallback?((ps, index, total, value.barValue))

    }
    public override func hook_intersects(pointInViewCoordinates point: Point2D, in chart: ChartLayer) -> IntersectionResult? {

        var result: IntersectionResult?   = nil
        var i                               = 0
        let n                               = self.segments.count
        let w                               = chart.xAxis.length / max(1, CGFloat(n))
        let bottom                          = chart.transformToViewCoordinate(y: chart.yAxis.origin)
        let adjusted_point                  = CGPoint(x: point.x, y: chart.bounds.height - point.y)

        while i < n && result == nil {
            if
                let segment = self.segments[i]
            {
                let left        = chart.transformToViewCoordinate(x: chart.xAxis.origin + w * CGFloat(i))
                let right       = chart.transformToViewCoordinate(x: chart.xAxis.origin + w * CGFloat(i + 1))
                let vw          = right - left
                let top         = chart.transformToViewCoordinate(y: segment.barValue)
                let left_inset  = self.barSegmentInsets?.left ?? 0
                let right_inset = self.barSegmentInsets?.right ?? 0
                let rect        = CGRect(x: left + left_inset, y: bottom, width: vw - left_inset - right_inset, height: top - bottom)

                if rect.contains(adjusted_point) {
                    result  = IntersectionResult(index: i, data: segment)
                }
            }
            i += 1
        }

        return result

    }

}

extension Double: BarPlotSegmentConvertible {
    public var barValue: BarPlotSegment {
        return CGFloat(self)
    }
}

extension Float: BarPlotSegmentConvertible {
    public var barValue: BarPlotSegment {
        return CGFloat(self)
    }
}

extension CGFloat: BarPlotSegmentConvertible {
    public var barValue: BarPlotSegment {
        return self
    }
}

extension Int: BarPlotSegmentConvertible {
    public var barValue: BarPlotSegment {
        return CGFloat(self)
    }
}
