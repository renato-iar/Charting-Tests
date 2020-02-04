//
//  ViewController.swift
//  Charting Tests
//
//  Created by Renato Ribeiro on 02/02/2020.
//  Copyright © 2020 Renato Ribeiro. All rights reserved.
//

import UIKit
import Combine
import Charting
import Observables

class ViewControllerModel: NSObject, ObservableObject {

    private var bar_data_request: Cancelable?                       = nil {
        willSet {
            self.bar_data_request?.cancel()
        }
        didSet {
            self.is_reloading_bar_data.writable = self.bar_data_request != nil
        }
    }
    private var pie_data_request: Cancelable?                       = nil {
        willSet {
            self.pie_data_request?.cancel()
        }
        didSet {
            self.is_reloading_pie_data.writable = self.pie_data_request != nil
        }
    }

    private lazy var is_reloading_bar_data: MutableObservableBool   = MutableObservableBool()
    private lazy var is_reloading_pie_data: MutableObservableBool   = MutableObservableBool()

    private lazy var bar_data: MutableObservable<[Int]>             = MutableObservable(with: [])
    private lazy var pie_data: MutableObservable<[Int]>             = MutableObservable(with: [])

    private static func generate_random_bar_data() -> [Int] {
        let n       = Int.random(in: 5 ... 20)
        var points  = [Int]()

        for _ in 0 ..< n {
            points.append(Int.random(in: 1 ... 20))
        }

        return points
    }
    private static func generate_random_pie_data() -> [Int] {
        let n       = Int.random(in: 5 ... 20)
        var points  = [Int]()

        for _ in 0 ..< n {
            points.append(Int.random(in: 1 ... 20))
        }

        return points
    }

    public final var isReloadingBarData: ObservableBool { return self.is_reloading_bar_data }
    public final var isReloadingPieData: ObservableBool { return self.is_reloading_pie_data }

    public final var barData: Observable<[Int]> { return self.bar_data }
    public final var pieData: Observable<[Int]> { return self.pie_data }

    public final func reloadBarData() -> () {
        self.bar_data_request   = DummyRequest(interval: 2.5) {
            [weak self] in
            self?.bar_data.writable = ViewControllerModel.generate_random_bar_data()
            self?.bar_data_request  = nil
        }
    }
    public final func reloadPieData() -> () {
        self.pie_data_request   = DummyRequest(interval: 2.5) {
            [weak self] in
            self?.pie_data.writable = ViewControllerModel.generate_random_pie_data()
            self?.pie_data_request  = nil
        }
    }

}

class ViewController: UIViewController {

    private var is_reloading_bar_data_observer_key: ObserverKey?    = nil {
        willSet {
            self.model.isReloadingBarData.unregister(willChangeObserverWith: self.is_reloading_bar_data_observer_key)
        }
    }
    private var is_reloading_pie_data_observer_key: ObserverKey?    = nil {
        willSet {
            self.model.isReloadingPieData.unregister(didChangeObserverWith: self.is_reloading_pie_data_observer_key)
        }
    }
    private var bar_data_observer_key: ObserverKey?                 = nil {
        willSet {
            self.model.barData.unregister(didChangeObserverWith: self.bar_data_observer_key)
        }
    }
    private var pie_data_observer_key: ObserverKey?                 = nil {
        willSet {
            self.model.pieData.unregister(didChangeObserverWith: self.pie_data_observer_key)
        }
    }

    private let model                                               = ViewControllerModel()
    private let bar_plot: BarPlot<Int>                              = {
        let plot                        = BarPlot<Int>()
        plot.barSegmentPaintCallback    = {
            arg in

            let gray    = CGFloat(arg.index) / CGFloat(arg.count)
            return [FillPaint(color: UIColor(red: gray, green: gray, blue: gray, alpha: 1.0)),
                    StrokePaint(name: nil, gradient: nil, lineWidth: 2.0, lineCap: CGLineCap.round, lineJoin: CGLineJoin.round, strokeColor: UIColor.lightGray, stipplePattern: [], stipplePatternPhase: 0.0)]
            //return [FillGradientPaint(gradient: Gradient(colors: [UIColor.white, UIColor.black]))]
        }
        plot.barSegmentInsets           = (left: 0.05, right: 0.05)

        return plot
    }()
    private let pie_plot: PiePlot<Int>                              = {
        let plot                        = PiePlot<Int>()
        plot.pieSlicePropertiesCallback = {
            arg in

            let gray    = CGFloat(arg.value) / CGFloat(arg.max)
            let color   = UIColor(red: gray, green: gray, blue: gray, alpha: 1.0)
            let fill    = FillPaint(color: color)
            let stroke  = StrokePaint(name: nil, gradient: nil, lineWidth: 2.0, lineCap: CGLineCap.round, lineJoin: CGLineJoin.round, strokeColor: UIColor.lightGray, stipplePattern: [], stipplePatternPhase: 0)

            return PieSliceProperties(paint: [fill, stroke], radius: nil, hole: nil)
        }

        return plot
    }()
    /*
    private let line_plot                           = LinePlot()
    private let scatter_plot                        = BubblePlot<BubblePlotSegment>()
    */

    private func bar_data_did_change(_ change: Observable<[Int]>.ObserverCallbackArgument) -> () {
        self.bar_chartView?.chartLayer.xAxis.origin = 0
        self.bar_chartView?.chartLayer.xAxis.length = CGFloat(change.to.count)
        self.bar_chartView?.chartLayer.yAxis.origin = 0
        self.bar_chartView?.chartLayer.yAxis.length = CGFloat(change.to.reduce(0, Swift.max))

        let segments: [Int?]    = change.to.map { $0 }
        self.bar_plot.segments  = segments
    }
    private func pie_data_did_change(_ change: Observable<[Int]>.ObserverCallbackArgument) -> () {
        self.pie_plot.segments  = change.to
    }

    private func is_reloading_bar_data_changed(_ change: ObservableBool.ObserverCallbackArgument) -> () {
        switch (change.from, change.to) {
        case (false, true): self.bar_chartView_activityIndicator?.startAnimating()
        case (true, false): self.bar_chartView_activityIndicator?.stopAnimating()

        default: break
        }
    }
    private func is_reloading_pie_data_changed(_ change: ObservableBool.ObserverCallbackArgument) -> () {
        switch (change.from, change.to) {
        case (false, true): self.pie_chartView_activityIndicator?.startAnimating()
        case (true, false): self.pie_chartView_activityIndicator?.stopAnimating()

        default: break
        }
    }

    @IBOutlet public final weak var bar_chartView: ChartView!
    @IBOutlet public final weak var bar_chartView_activityIndicator: UIActivityIndicatorView!
    @IBOutlet public final weak var pie_chartView: ChartView!
    @IBOutlet public final weak var pie_chartView_activityIndicator: UIActivityIndicatorView!
    @IBOutlet public final weak var line_scatter_chartView: ChartView!

    @IBAction public final func onReloadChartsAction() -> () {
        self.model.reloadBarData()
        self.model.reloadPieData()
    }

    override func viewDidLoad() -> () {
        super.viewDidLoad()

        self.bar_data_observer_key  = self.model.barData.register(didChange: {
            [weak self] change in
            self?.bar_data_did_change(change)
        })
        self.pie_data_observer_key  = self.model.pieData.register(didChange: {
            [weak self] change in
            self?.pie_data_did_change(change)
        })
        self.is_reloading_bar_data_observer_key = self.model.isReloadingBarData.register(didChange: {
            [weak self] change in
            self?.is_reloading_bar_data_changed(change)
        })
        self.is_reloading_pie_data_observer_key = self.model.isReloadingPieData.register(didChange: {
            [weak self] change in
            self?.is_reloading_pie_data_changed(change)
        })

        self.bar_chartView?.chartLayer.plots    = [self.bar_plot]
        self.pie_chartView?.chartLayer.plots    = [self.pie_plot]
    }
    override func viewDidAppear(_ animated: Bool) -> () {
        super.viewDidAppear(animated)

        self.model.reloadBarData()
        self.model.reloadPieData()
    }

    deinit {
        self.is_reloading_bar_data_observer_key = nil
        self.is_reloading_pie_data_observer_key = nil
        self.bar_data_observer_key              = nil
        self.pie_data_observer_key              = nil
    }

}

