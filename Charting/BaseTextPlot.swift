//
//  BaseTextPlot.swift
//  Charting
//
//  Created by Renato Ribeiro on 27/12/2019.
//  Copyright © 2019 Elphucorp, Lda. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit

public protocol TextPlotEntryValue {
    var plotEntryText: NSAttributedString { get }
}

public protocol TextEntryHeight {
    var plotEntryY: CGFloat { get }
}

public protocol TextEntryPosition {
    var plotEntryPoint: CGPoint { get }
}

public struct TextEntryProperties {
    public enum Alignment: Int {
        case left   = 1
        case right  = 2
        case center = 3

        public var isLeft: Bool { return self == .left }
        public var isRight: Bool { return self == .right }
        public var isCenter: Bool { return self == .center }
    }
    public let alignment: Alignment

    public enum VerticalAlignment: Int {
        case top    = 1
        case bottom = 2
        case center = 3

        public var isTop: Bool { return self == .top }
        public var isBottom: Bool { return self == .bottom }
        public var isCenter: Bool { return self == .center }
    }
    public let verticalAlignment: VerticalAlignment
    public let leftInset: CGFloat
    public let rightInset: CGFloat
    public let hidden: Bool

    public init(hidden h: Bool = false, leftInset li: CGFloat = 0.0, rightInset ri: CGFloat = 0.0, alignment ha: Alignment = .left, verticalAlignment va: VerticalAlignment = .center) {
        self.alignment          = ha
        self.verticalAlignment  = va
        self.leftInset          = li
        self.rightInset         = ri
        self.hidden             = h
    }
}

open class BaseTextPlot<EntryType: TextPlotEntryValue>: BasePlot {

    // MARK: - open
    // MARK: hooks
    open func hook_EntriesDidChange(from: [EntryType], to: [EntryType]) -> () {

    }

    /**
     Called to draw a single text entry in the current graphics context.
     - note: The graphics context will be wrapped in a push/pop, so state changes may be safelly performed
     - parameters:
        - entry:        the entry being drawn
        - context:      the current graphics context
        - m:            the transformation matrix being applied to the context
        - chart:        the chart where the plot is being drawn
        - parameters:   optional draw parameters
     */
    open func hook_DrawEntry(_ entry: EntryType, at position: CGPoint, with textProperties: TextEntryProperties?, in context: CGContext, transform m: UnsafePointer<CGAffineTransform>, for chart: ChartLayer, parameters: [String: Any]?) -> () {

        if textProperties?.hidden ?? false {
            // Hide the entry
            return
        }

        context.translateBy(x: position.x, y: position.y)
        context.scaleBy(x: 1.0, y: -1.0)

        entry.plotEntryText.draw(at: CGPoint.zero)

        context.scaleBy(x: 1.0, y: -1.0)
        context.translateBy(x: -position.x, y: -position.y)
    }

    /**
     Determines the position for the entry, in chart view coordinates (i.e. button-up)

     - parameters:
        - entry:        the entry being considered
        - index:        the index of the entry in the current data set
        - count:        the total number of entries in the current data set
        - chart:        the chart where the plot is being drawn
        - parameters:   optional draw parameters
     */
    open func hook_EntryPositionInViewCoordinates(for entry: EntryType, with textProperties: TextEntryProperties?, at index: Int, of count: Int, for chart: ChartLayer, parameters ps: [String: Any]?) -> CGPoint {
        fatalError("\(type(of: self)).\(#function) must be implemented by concrete subtypes")
    }

    // MARK: - public
    // MARK: types
    public typealias TextEntryPropertiesCallbackInputType                       = (entry: EntryType, index: Int, count: Int)
    public typealias TextEntryPropertiesCallbackType                            = (TextEntryPropertiesCallbackInputType) -> TextEntryProperties?

    // MARK: instance variables
    public final var entryPropertiesCallback: TextEntryPropertiesCallbackType?  = nil {
        didSet {
            self.invalidate()
        }
    }
    public final var entries: [EntryType]                                       = [] {
        didSet {
            self.hook_EntriesDidChange(from: oldValue, to: self.entries)
            self.invalidate()
        }
    }

    // MARK: - overrides
    override func hook_draw(in context: CGContext, transform m: UnsafePointer<CGAffineTransform>, for chart: ChartLayer, parameters: [String : Any]?) -> () {
        super.hook_draw(in: context, transform: m, for: chart, parameters: parameters)

        let n   = self.entries.count
        for i in 0 ..< n {
            let entry   = self.entries[i]
            let props   = self.entryPropertiesCallback?((entry, i, n))
            let pt      = self.hook_EntryPositionInViewCoordinates(for: entry, with: props, at: i, of: n, for: chart, parameters: parameters)

            UIGraphicsPushContext(context)
            self.hook_DrawEntry(entry, at: pt, with: props, in: context, transform: m, for: chart, parameters: parameters)
            UIGraphicsPopContext()
        }
    }

}

/**
 Draws text across an horizontally-even-split dimension, varying the height at which the text is placed
 - note: See also TextPlot2D
 */
public final class TextPlot1D<EntryType: TextPlotEntryValue & TextEntryHeight>: BaseTextPlot<EntryType> {

    override public func hook_EntryPositionInViewCoordinates(for entry: EntryType, with textProperties: TextEntryProperties?, at index: Int, of count: Int, for chart: ChartLayer, parameters ps: [String: Any]?) -> CGPoint {
        let w           = chart.xAxis.length / max(1, CGFloat(count))
        let x           = chart.transformToViewCoordinate(x: w * CGFloat(index))
        let y           = chart.transformToViewCoordinate(y: entry.plotEntryY)
        let li          = textProperties?.leftInset ?? 0.0
        let alignment   = textProperties?.alignment
        let xoff: CGFloat

        switch alignment {
        case .center?:
            let tw  = entry.plotEntryText.boundingRect(with: chart.bounds.size,
                                                       options: .usesFontLeading,
                                                       context: nil).width
            xoff    = (x / CGFloat(max(1, count))) * 0.5 - tw * 0.5

        case .right?:
            let tw  = entry.plotEntryText.boundingRect(with: chart.bounds.size,
                                                       options: .usesFontLeading,
                                                       context: nil).width
            xoff    = -tw

        default:
            xoff = 0.0
        }

        return CGPoint(x: li + x + xoff, y: y)
    }

}

public final class TextPlot2D<EntryType: TextPlotEntryValue & TextEntryPosition>: BaseTextPlot<EntryType> {

    override public func hook_EntryPositionInViewCoordinates(for entry: EntryType, with textProperties: TextEntryProperties?, at index: Int, of count: Int, for chart: ChartLayer, parameters ps: [String: Any]?) -> CGPoint {
        let pt_in_chart_coordinates = entry.plotEntryPoint
        let x                       = chart.transformToViewCoordinate(x: pt_in_chart_coordinates.x)
        let y                       = chart.transformToViewCoordinate(y: pt_in_chart_coordinates.y)
        let li                      = textProperties?.leftInset ?? 0.0
        let alignment               = textProperties?.alignment
        let xoff: CGFloat

        switch alignment {
        case .center?:
            let tw  = entry.plotEntryText.boundingRect(with: chart.bounds.size,
                                                       options: .usesFontLeading,
                                                       context: nil).width
            xoff    = tw * -0.5

        case .right?:
            let tw  = entry.plotEntryText.boundingRect(with: chart.bounds.size,
                                                       options: .usesFontLeading,
                                                       context: nil).width
            xoff    = -tw

        default:
            xoff = 0.0
        }


        return CGPoint(x: li + x + xoff, y: y)
    }

}
