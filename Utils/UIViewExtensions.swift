//
//  UIViewExtensions.swift
//  Utils
//
//  Created by Renato Ribeiro on 04/02/2020.
//  Copyright © 2020 Renato Ribeiro. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics

public protocol UIShadow {

    var color: UIColor? { get set }
    var offset: CGSize { get set }
    var opacity: Float { get set }
    var radius: CGFloat { get set }
    var path: CGPath? { get set }

}

public protocol UIBorder {

    var width: CGFloat { get set }
    var color: UIColor? { get set }

}

private final class UIViewShadowProxy: UIShadow {

    private weak var view: UIView!

    fileprivate init(with view: UIView) {
        self.view   = view
    }

    public var color: UIColor? {
        get { return self.view?.shadowColor }
        set { self.view?.shadowColor = newValue }
    }
    public var offset: CGSize {
        get { return self.view?.shadowOffset ?? CGSize.zero }
        set { self.view?.shadowOffset = newValue }
    }
    public var opacity: Float {
        get { return self.view?.shadowOpacity ?? 0 }
        set { self.view?.shadowOpacity = newValue }
    }
    public var radius: CGFloat {
        get { return self.view?.shadowRadius ?? 0 }
        set { self.view?.shadowRadius = newValue }
    }
    public var path: CGPath? {
        get { return self.view?.shadowPath }
        set { self.view?.shadowPath = newValue }
    }

}

private final class UIViewBorderProxy: UIBorder {

    private weak var view: UIView!

    fileprivate init(with view: UIView) {
        self.view   = view
    }

    public var width: CGFloat {
        get { return self.view?.borderWidth ?? 0 }
        set { self.view?.borderWidth = newValue }
    }
    public var color: UIColor? {
        get { return self.view?.borderColor }
        set { self.view?.borderColor = newValue }
    }

}

extension UIView {

    public struct Shadow: UIShadow {
        public var color: UIColor?
        public var offset: CGSize
        public var opacity: Float
        public var radius: CGFloat
        public var path: CGPath?
    }

    public struct Border: UIBorder {
        public var width: CGFloat
        public var color: UIColor?
    }

    @IBInspectable public final var cornerRadius: CGFloat {
        get { return self.layer.cornerRadius }
        set { self.layer.cornerRadius = newValue }
    }

    @IBInspectable public final var borderWidth: CGFloat {
        get { return self.layer.borderWidth }
        set { self.layer.borderWidth = newValue }
    }

    @IBInspectable public final var borderColor: UIColor? {
        get { return self.layer.borderColor.flatMap(UIColor.init(cgColor:)) }
        set { self.layer.borderColor = newValue?.cgColor }
    }

    @IBInspectable public final var shadowColor: UIColor? {
        get { self.layer.shadowColor.flatMap(UIColor.init(cgColor:)) }
        set { self.layer.shadowColor = newValue?.cgColor }
    }

    @IBInspectable public final var shadowOffset: CGSize {
        get { return self.layer.shadowOffset }
        set { self.layer.shadowOffset = newValue }
    }

    @IBInspectable public final var shadowOpacity: Float {
        get { return self.layer.shadowOpacity }
        set { self.layer.shadowOpacity = newValue }
    }

    @IBInspectable public final var shadowRadius: CGFloat {
        get { return self.layer.shadowRadius }
        set { self.layer.shadowRadius = newValue }
    }

    public final var shadowPath: CGPath? {
        get { return self.layer.shadowPath }
        set { self.layer.shadowPath = newValue }
    }

    public final var shadow: UIView.Shadow {
        get {
            return Shadow(color: self.shadowColor, offset: self.shadowOffset, opacity: self.shadowOpacity, radius: self.shadowRadius, path: self.shadowPath)
        }
        set {
            self.shadowColor    = newValue.color
            self.shadowOffset   = newValue.offset
            self.shadowOpacity  = newValue.opacity
            self.shadowRadius   = newValue.radius
            self.shadowPath     = newValue.path
        }
    }
    public final var shadowProxy: UIShadow {
        return UIViewShadowProxy(with: self)
    }

    public final var border: UIView.Border {
        get {
            return Border(width: self.borderWidth, color: self.borderColor)
        }
        set {
            self.borderWidth    = newValue.width
            self.borderColor    = newValue.color
        }
    }
    public final var borderProxy: UIBorder {
        return UIViewBorderProxy(with: self)
    }

}
