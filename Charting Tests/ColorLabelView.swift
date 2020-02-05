//
//  ColorLabelView.swift
//  Charting Tests
//
//  Created by Renato Ribeiro on 05/02/2020.
//  Copyright © 2020 Renato Ribeiro. All rights reserved.
//

import Foundation
import Utils
import UIKit

open class ColorLabelView: UIView {

    private lazy var label_view: UILabel        = {
        let label   = UILabel()

        return label
    }()
    private lazy var color_view: UIView         = {
        let view    = UIView()

        return view
    }()
    private lazy var stack_view: UIStackView    = {
        let sv                                          = UIStackView(arrangedSubviews: [self.label, self.colorView])
        sv.axis                                         = .horizontal
        sv.translatesAutoresizingMaskIntoConstraints    = false
        sv.alignment                                    = .fill
        sv.spacing                                      = 5

        return sv
    }()

    private final var label: UILabel { return self.label_view }
    private final var colorView: UIView { return self.color_view }

    private func setup_ui() -> () {
        self.addSubview(self.stack_view)
        self.stack_view.topAnchor.constraint(equalTo: self.topAnchor).isActive                              = true
        self.stack_view.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive                        = true
        self.stack_view.leftAnchor.constraint(equalTo: self.leftAnchor).isActive                            = true
        self.stack_view.rightAnchor.constraint(equalTo: self.rightAnchor).isActive                          = true
        self.colorView.widthAnchor.constraint(equalTo: self.colorView.heightAnchor, constant: 0.0).isActive = true
    }

    public final var labelText: String? {
        get { return self.label.text }
        set { self.label.text = newValue }
    }
    public final var labelTextColor: UIColor! {
        get { return self.label.textColor }
        set { self.label.textColor = newValue }
    }
    public final var markerColor: UIColor? {
        get { return self.colorView.backgroundColor }
        set { self.colorView.backgroundColor = newValue }
    }

    public final var markerBorderProxy: UIBorder {
        get { return self.colorView.borderProxy }
    }
    public final var markerShadowProxy: UIShadow {
        get { return self.colorView.shadowProxy }
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        self.colorView.cornerRadius = self.colorView.bounds.height * 0.5
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup_ui()
    }
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup_ui()
    }

}
