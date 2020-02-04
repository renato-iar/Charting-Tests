//
//  Chart.swift
//  Charting
//
//  Created by Renato Ribeiro on 11/12/2019.
//  Copyright © 2019 Elphucorp, Lda. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics

public struct IntersectionResult {
    public let index: Int
    public let data: Any?

    public init(index: Int, data: Any? = nil) {
        self.index  = index
        self.data   = data
    }
}

public class ChartLayer: CALayer {

    // MARK: - private
    // MARK: instance variables
    private var batch_updates_count: Int    = 0 {
        didSet {
            if oldValue > 0 && self.batch_updates_count == 0 {
                self.reset_graphic_state()
            }
        }
    }

    private var x_axis_scale: CGFloat       = 1.0
    private var y_axis_scale: CGFloat       = 1.0

    // MARK: instance methods
    private func reset_axis_scale() -> () {
        let sz              = self.bounds.size
        self.x_axis_scale   = (sz.width - self.insets.left - self.insets.right) / self.xAxis.length
        self.y_axis_scale   = (sz.height - self.insets.top - self.insets.bottom) / self.yAxis.length
    }
    private func reset_draw() -> () {
        self.setNeedsDisplay()
    }
    private func reset_graphic_state() -> () {
        guard !self.isPerformingBatchUpdates else {
            return
        }

        for plot in self.plots {
            plot.invalidate()
        }
        self.reset_axis_scale()
        self.reset_draw()
    }

    // MARK: - open
    // MARK: hooks
    open func hook_DrawParameters(for plot: BasePlot, at index: Int) -> [String: Any]? {
        return nil
    }

    // MARK: - public
    // MARK: instance variables
    public final var plots: [BasePlot]    = [] {
        willSet {
            for plot in self.plots {
                plot.chart  = nil
            }
        }
        didSet {
            for plot in self.plots {
                plot.chart  = self
            }
            self.reset_draw()
        }
    }
    public final var xAxis: ChartAxis     = ChartAxis(origin: 0, length: 1) {
        didSet {
            self.reset_graphic_state()
        }
    }
    public final var yAxis: ChartAxis     = ChartAxis(origin: 0, length: 1) {
        didSet {
            self.reset_graphic_state()
        }
    }
    public final var insets: UIEdgeInsets   = UIEdgeInsets.zero {
        didSet {
            self.reset_graphic_state()
        }
    }

    // MARK: instance methods
    public final var axisCenter: CGPoint {
        return CGPoint(x: self.xAxis.origin + self.xAxis.length*0.5, y: self.yAxis.origin + self.yAxis.length*0.5)
    }
    public final var axisOrigin: CGPoint { return CGPoint(x: self.xAxis.origin, y: self.yAxis.origin) }
    public final var isPerformingBatchUpdates: Bool { return self.batch_updates_count > 0 }

    public final func performBatchUpdates(_ updates: () -> Void) -> () {
        self.batch_updates_count    += 1
        updates()
        self.batch_updates_count    -= 1
    }
    public final func transformToViewCoordinates(point p: Point2D) -> Point2D {
        return type(of: p).init(x: self.transformToViewCoordinate(x: p.x), y: self.transformToViewCoordinate(y: p.y))
    }
    public final func transformToViewCoordinate(x: CGFloat) -> CGFloat {
        return (x - self.xAxis.origin) * self.x_axis_scale + self.insets.left
    }
    public final func transformToViewCoordinate(y: CGFloat) -> CGFloat {
        return (y - self.yAxis.origin) * self.y_axis_scale + self.insets.top
    }

    // MARK: - overrides
    // MARK: CALayer
    public override func draw(in ctx: CGContext) -> () {

        super.draw(in: ctx)

        var m = CGAffineTransform.identity

        for i in 0 ..< self.plots.count {
            let plot    = self.plots[i]
            let params  = self.hook_DrawParameters(for: plot, at: i)

            ctx.saveGState()
            ctx.translateBy(x: 0.0, y: self.bounds.height)
            ctx.scaleBy(x: 1, y: -1)

            plot.hook_draw(in: ctx, transform: &m, for: self, parameters: params)

            ctx.restoreGState()
        }

    }

    public override var frame: CGRect {
        get { return super.frame }
        set(f) {
            super.frame = f
            self.reset_graphic_state()
        }
    }
    public override var bounds: CGRect {
        get { return super.bounds }
        set(b) {
            super.bounds = b
            self.reset_graphic_state()
        }
    }

    override init() {
        super.init()
        self.contentsScale  = UIScreen.main.scale
    }
    override init(layer: Any) {
        super.init(layer: layer)
        self.contentsScale  = UIScreen.main.scale
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.contentsScale  = UIScreen.main.scale
    }

}

open class ChartView: UIView {

    public final var chartLayer: ChartLayer { return self.layer as! ChartLayer }

    open override class var layerClass: AnyClass {
        return ChartLayer.classForCoder()
    }

}
