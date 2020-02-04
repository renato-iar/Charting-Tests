//
//  LinePlot.swift
//  Charting
//
//  Created by Renato Ribeiro on 13/12/2019.
//  Copyright © 2019 Elphucorp, Lda. All rights reserved.
//

import Foundation
import CoreGraphics

public final class LinePlot: XYPlot2D {

    // MARK: - private
    // MARK: instance methods
    private func draw_smooth_closed_path(_ path: CGMutablePath, transform t: CGAffineTransform, chart: ChartLayer, parameters ps: [String: Any]?) -> () {

        let n           = self.points.count

        guard n > 1 else {
            return
        }

        let origin      = chart.transformToViewCoordinates(point: chart.axisOrigin).cgPoint
        var p0          = chart.transformToViewCoordinates(point: self.points[0]).cgPoint

        path.move(to: origin, transform: t)
        path.addLine(to: p0, transform: t)

        for i in 1 ..< n {
            let transformed = chart.transformToViewCoordinates(point: self.points[i]).cgPoint
            let cpx0        = p0.x + (transformed.x-p0.x)*0.50
            let cpy0        = p0.y
            let cpx1        = cpx0
            let cpy1        = transformed.y
            let c1          = CGPoint(x: cpx0, y: cpy0)
            let c2          = CGPoint(x: cpx1, y: cpy1)

            path.addCurve(to: transformed, control1: c1, control2: c2, transform: t)
            p0      = transformed
        }

        let terminal    = chart.transformToViewCoordinates(point: CGPoint(x: self.points[n-1].x, y: chart.yAxis.origin)).cgPoint
        path.addLine(to: terminal, transform: t)
        path.closeSubpath()

    }
    private func draw_smooth_open_path(_ path: CGMutablePath, transform t: CGAffineTransform, chart: ChartLayer, parameters ps: [String: Any]?) -> () {

        let n           = self.points.count

        guard n > 1 else {
            return
        }

        var p0          = chart.transformToViewCoordinates(point: self.points[0]).cgPoint

        path.move(to: p0, transform: t)

        for i in 1 ..< n {
            let transformed = chart.transformToViewCoordinates(point: self.points[i]).cgPoint
            let cpx0        = p0.x + (transformed.x-p0.x)*0.50
            let cpy0        = p0.y
            let cpx1        = cpx0
            let cpy1        = transformed.y
            let c1          = CGPoint(x: cpx0, y: cpy0)
            let c2          = CGPoint(x: cpx1, y: cpy1)

            path.addCurve(to: transformed, control1: c1, control2: c2, transform: t)
            p0      = transformed
        }
    }
    private func draw_straight_closed_path(_ path: CGMutablePath, transform t: CGAffineTransform, chart: ChartLayer, parameters ps: [String: Any]?) -> () {

        guard !self.points.isEmpty else {
            return
        }

        let n           = self.points.count
        let origin      = chart.transformToViewCoordinates(point: chart.axisOrigin).cgPoint
        path.move(to: origin, transform: t)

        for i in 0 ..< n {
            let p   = chart.transformToViewCoordinates(point: self.points[i]).cgPoint
            path.addLine(to: p, transform: t)
        }

        let last = self.points[n - 1]
        let terminal    = chart.transformToViewCoordinates(point: CGPoint(x: last.x, y: chart.yAxis.origin)).cgPoint
        path.addLine(to: terminal, transform: t)
        path.closeSubpath()

    }
    private func draw_straight_open_path(_ path: CGMutablePath, transform t: CGAffineTransform, chart: ChartLayer, parameters ps: [String: Any]?) -> () {

        let n           = self.points.count

        guard n > 1 else {
            return
        }

        let origin      = chart.transformToViewCoordinates(point: self.points[0]).cgPoint
        path.move(to: origin, transform: t)

        for i in 1 ..< n {
            let p   = chart.transformToViewCoordinates(point: self.points[i]).cgPoint
            path.addLine(to: p, transform: t)
        }
    }

    // MARK: - public
    // MARK: instance variables
    public final var smooth: Bool       = true {
        didSet {
            self.chart?.setNeedsDisplay()
        }
    }
    public final var closed: Bool       = true {
        didSet {
            self.chart?.setNeedsDisplay()
        }
    }

    // MARK: instance methods
    public final var open: Bool {
        get { return !self.closed }
        set { self.closed   = !newValue }
    }
    public final var isClosed: Bool {
        get { return self.closed }
        set { self.closed = newValue }
    }
    public final var isOpen: Bool {
        get { return self.open }
        set { self.open = newValue }
    }
    public final var isSmooth: Bool {
        get { return self.smooth }
        set { self.smooth = newValue }
    }

    // MARK: - overrides
    // MARK: EC2DPlot
    /*
    // intersection in line plots doesn't seem to make sense
    override func hook_intersects(pointInViewCoordinates point: EC2DPoint, in chart: ECChartLayer) -> ECIntersectionResult? {
        return nil
    }
    */
    public override func hook_DrawPath(transform m: UnsafePointer<CGAffineTransform>, for chart: ChartLayer, parameters: [String : Any]?) -> CGPath {
        let path    = CGMutablePath()
        let t = m.pointee

        if self.isSmooth {
            if self.isOpen {
                self.draw_smooth_open_path(path, transform: t, chart: chart, parameters: parameters)
            }
            else {
                self.draw_smooth_closed_path(path, transform: t, chart: chart, parameters: parameters)
            }
        }
        else {
            if self.isOpen {
                self.draw_straight_open_path(path, transform: t, chart: chart, parameters: parameters)
            }
            else {
                self.draw_straight_closed_path(path, transform: t, chart: chart, parameters: parameters)
            }
        }

        return path
    }

}

