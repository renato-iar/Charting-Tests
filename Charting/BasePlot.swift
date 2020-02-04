//
//  BasePlot.swift
//  Charting
//
//  Created by Renato Ribeiro on 12/12/2019.
//  Copyright © 2019 Elphucorp, Lda. All rights reserved.
//

import Foundation
import CoreGraphics

open class BasePlot {

    internal func hook_intersects(pointInViewCoordinates point: Point2D, in chart: ChartLayer) -> IntersectionResult? {
        return nil
    }
    internal func hook_draw(in context: CGContext, transform m: UnsafePointer<CGAffineTransform>, for chart: ChartLayer, parameters: [String: Any]?) -> () {
    }
    internal func hook_Invalidate() -> () {

    }

    public internal(set) final var chart: ChartLayer? = nil

    public final func invalidate() -> () {
        self.hook_Invalidate()
        self.chart?.setNeedsDisplay()
    }
    public final func intersects(pointInViewCoordinates point: Point2D, in chart: ChartLayer) -> IntersectionResult? {
        return self.hook_intersects(pointInViewCoordinates: point, in: chart)
    }

    public required init() {
    }

}

