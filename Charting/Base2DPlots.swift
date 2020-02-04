//
//  Base2DPlots.swift
//  Charting
//
//  Created by Renato Ribeiro on 13/12/2019.
//  Copyright © 2019 Elphucorp, Lda. All rights reserved.
//

import Foundation
import CoreGraphics

open class Plot2D: BasePlot {
    open func hook_DrawPath(transform m: UnsafePointer<CGAffineTransform>, for chart: ChartLayer, parameters: [String: Any]?) -> CGPath {
        fatalError("\(type(of: self)).\(#function) must be implemented by concrete classes")
    }

    override func hook_draw(in context: CGContext, transform m: UnsafePointer<CGAffineTransform>, for chart: ChartLayer, parameters: [String : Any]?) -> () {
        super.hook_draw(in: context, transform: m, for: chart, parameters: parameters)

        let path    = self.hook_DrawPath(transform: m, for: chart, parameters: parameters)

        context.addPath(path)
        for paint in self.paint {
            paint.apply(to: path, inContext: context)
        }
    }

    public final var paint: [Paint]   = [] {
        didSet {
            self.chart?.setNeedsDisplay()
        }
    }
}

open class XYPlot2D: Plot2D {

    public final var points: [CGPoint]  = [] {
        didSet {
            self.chart?.setNeedsDisplay()
        }
    }
}

open class SegmentedPlot2D<SegmentType>: BasePlot {

    private struct SegmentDataCache {
        public let path: CGPath
        public let paint: [Paint]

        public init(with path: CGPath, paint: [Paint]) {
            self.path   = path
            self.paint  = paint
        }
    }
    private var segment_data_cache: [Int: SegmentedPlot2D.SegmentDataCache]   = [:]

    open func hook_SegmentsDidChange(from: [SegmentType], to: [SegmentType]) -> () {

    }

    open func hook_DrawPath(for segment: SegmentType, at index: Int, of total: Int, transform m: UnsafePointer<CGAffineTransform>, for chart: ChartLayer, parameters ps: [String: Any]?) -> CGPath? {
        return nil
    }
    open func hook_PathPaint(for segment: SegmentType, at index: Int, of total: Int, for chart: ChartLayer, parameters ps: [String: Any]?) -> [Paint]? {
        return nil
    }

    public typealias SegmentsWillChangeCallbackInput                                        = (from: [SegmentType], to: [SegmentType])
    public typealias SegmentsDidChangeCallbackInput                                         = (from: [SegmentType], to: [SegmentType])

    public final var segmentsWillChangeCallback: ((SegmentsWillChangeCallbackInput) -> Void)?   = nil
    public final var segmentsDidChangeCallback: ((SegmentsDidChangeCallbackInput) -> Void)?     = nil
    public final var segments: [SegmentType]                                                    = [] {
        didSet {
            self.segment_data_cache = [:]
            self.hook_SegmentsDidChange(from: oldValue, to: self.segments)

            self.segmentsWillChangeCallback?((from: oldValue, to: self.segments))
            self.chart?.setNeedsDisplay()
            self.segmentsDidChangeCallback?((from: oldValue, to: self.segments))
        }
    }

    override func hook_Invalidate() -> () {
        self.segment_data_cache = [:]
        super.hook_Invalidate()
    }
    override final func hook_draw(in context: CGContext, transform m: UnsafePointer<CGAffineTransform>, for chart: ChartLayer, parameters: [String : Any]?) -> () {
        super.hook_draw(in: context, transform: m, for: chart, parameters: parameters)

        let n   = self.segments.count
        for i in 0 ..< n {
            let segment = self.segments[i]
            let path: CGPath
            let paint: [Paint]

            if let cached   = self.segment_data_cache[i] {
                path    = cached.path
                paint   = cached.paint
            }
            else if
                let new_path    = self.hook_DrawPath(for: segment, at: i, of: n, transform: m, for: chart, parameters: parameters),
                let new_paint   = self.hook_PathPaint(for: segment, at: i, of: n, for: chart, parameters: parameters)
            {
                path                        = new_path
                paint                       = new_paint
                self.segment_data_cache[i]  = SegmentedPlot2D.SegmentDataCache(with: path, paint: paint)
            }
            else {
                continue
            }

            context.addPath(path)
            for p in paint {
                p.apply(to: path, inContext: context)
            }
        }
    }

}
