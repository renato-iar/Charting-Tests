//
//  Paint.swift
//  Charting
//
//  Created by Renato Ribeiro on 12/12/2019.
//  Copyright © 2019 Elphucorp, Lda. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics

public class Gradient: NSObject {

    public var colors: [UIColor]    = []
    public var startPoint: CGPoint  = CGPoint(x: 0.50, y: 0.0)
    public var endPoint: CGPoint    = CGPoint(x: 0.50, y: 1.0)

    public init(colors: [UIColor],
                rotation: CGFloat   = 0.0,
                start: CGPoint      = CGPoint(x: 0.50, y: 0.0),
                end: CGPoint        = CGPoint(x: 0.50, y: 1.0))
    {
        super.init()

        let sp0         = CGPoint(x: 2*startPoint.x - 1, y: 1 - 2*startPoint.y).rotate(rotation)
        let ep0         = CGPoint(x: 2*endPoint.x - 1, y: 1 - 2*endPoint.y).rotate(rotation)
        let sp          = CGPoint(x: 1 - sp0.x, y: 1 - sp0.y)
        let ep          = CGPoint(x: 1 - ep0.x, y: 1 - ep0.y)

        self.colors     = colors
        self.startPoint = sp
        self.endPoint   = ep
    }

    internal func apply(_ context: CGContext, size: CGSize) -> () {

        let s = CGColorSpaceCreateDeviceRGB()

        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        var cls: [CGFloat] = []
        let n = self.colors.count
        let start = CGPoint(x: self.startPoint.x*size.width, y: self.startPoint.y*size.height)
        let end = CGPoint(x: self.endPoint.x*size.width, y: self.endPoint.y*size.height)

        for i in 0 ..< n {
            let cl = self.colors[i]
            cl.getRed(&r, green: &g, blue: &b, alpha: &a)
            cls.append(contentsOf: [r, g, b, a])
        }

        guard let grad = CGGradient(colorSpace: s, colorComponents: &cls, locations: nil, count: n) else { return }

        let o = CGGradientDrawingOptions(rawValue: 0)
        context.drawLinearGradient(grad, start: start, end: end, options: o)

    }

}

open class Paint {

    public var name: String?    = nil

    internal func apply(to shape: CGPath, inContext ctx: CGContext) -> () {
    }

    public init(named name: String? = nil) {
        self.name   = name
    }

}

public class StrokePaint: Paint {

    public var gradient: Gradient?        = nil
    public var lineWidth: CGFloat           = 1.0
    public var lineCap: CGLineCap           = CGLineCap.square
    public var lineJoin: CGLineJoin         = CGLineJoin.miter
    public var strokeColor: UIColor?        = UIColor.black
    public var stipplePattern: [CGFloat]    = []
    public var stipplePatternPhase: CGFloat = 0.0

    internal override func apply(to shape: CGPath, inContext ctx: CGContext) -> () {
        super.apply(to: shape, inContext: ctx)

        ctx.setLineWidth(self.lineWidth)
        ctx.setLineCap(self.lineCap)
        ctx.setLineJoin(self.lineJoin)
        ctx.setStrokeColor((self.strokeColor?.cgColor)!)

        if !self.stipplePattern.isEmpty {
            ctx.setLineDash(phase: self.stipplePatternPhase,
                            lengths: self.stipplePattern)
        }

        if let grad = self.gradient {
            grad.apply(ctx, size: shape.boundingBox.size)
        }

        ctx.addPath(shape)
        ctx.strokePath()
    }

    public init(name: String?,
                gradient: Gradient?,
                lineWidth width: CGFloat,
                lineCap: CGLineCap,
                lineJoin: CGLineJoin,
                strokeColor: UIColor?,
                stipplePattern: [CGFloat],
                stipplePatternPhase: CGFloat) {
        super.init(named: name)

        self.gradient               = gradient
        self.lineWidth              = width
        self.lineCap                = lineCap
        self.lineJoin               = lineJoin
        self.strokeColor            = strokeColor
        self.stipplePattern         = stipplePattern
        self.stipplePatternPhase    = stipplePatternPhase
    }

    public static func gradient(name: String?, colors: [UIColor], startPoint start: CGPoint = CGPoint(x: 0.5, y: 0.0), endPoint end: CGPoint = CGPoint(x: 0.5, y: 1.0), rotation: CGFloat = 0.0) -> StrokePaint {
        let gradient    = Gradient(colors: colors, rotation: rotation, start: start, end: end)
        let paint       = StrokePaint(name: name, gradient: gradient, lineWidth: 0, lineCap: CGLineCap.square, lineJoin: CGLineJoin.miter, strokeColor: nil, stipplePattern: [], stipplePatternPhase: 0)

        return paint
    }
    public static func stroke(name: String?, color: UIColor, width: CGFloat, pattern: [CGFloat] = [], phase: CGFloat = 0.0, lineCap cap: CGLineCap = CGLineCap.round, lineJoin join: CGLineJoin = CGLineJoin.round) -> StrokePaint {
        return StrokePaint(name: name, gradient: nil, lineWidth: width, lineCap: cap, lineJoin: join, strokeColor: color, stipplePattern: pattern, stipplePatternPhase: phase)
    }

}

public class FillPaint: Paint {

    public var fillColor: UIColor   = UIColor.white

    public init(color: UIColor, named name: String? = nil) {
        self.fillColor  = color
        super.init(named: name)
    }

    override func apply(to shape: CGPath, inContext ctx: CGContext) -> () {
        super.apply(to: shape, inContext: ctx)

        guard !shape.isEmpty else { return }

        ctx.saveGState()

        ctx.setFillColor(self.fillColor.cgColor)
        ctx.addPath(shape)
        ctx.fillPath()

        ctx.restoreGState()
    }

}

public class FillGradientPaint: Paint {

    public var gradient: Gradient

    override func apply(to shape: CGPath, inContext ctx: CGContext) -> () {

        super.apply(to: shape, inContext: ctx)

        guard !shape.isEmpty else {
            return
        }

        ctx.saveGState()

        ctx.addPath(shape)
        ctx.clip()
        self.gradient.apply(ctx, size: shape.boundingBox.size)
        ctx.fillPath()

        ctx.restoreGState()

    }

    public init(gradient: Gradient) {
        self.gradient = gradient
    }

}
