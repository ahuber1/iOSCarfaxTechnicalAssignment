//
//  FilledButton.swift
//  CarfaxTechnicalAssignment
//
//  Created by Andrew Huber on 6/6/21.
//

import UIKit

/// FilledButton is a `UIButton` with a background that changes depending on whether the
/// button is highlighted or not.
@IBDesignable class FilledButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        doInitialSetup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        doInitialSetup()
    }

    /// The background color to use when the button is not highlighted.
    @IBInspectable var fillColor: UIColor = .systemBackground {
        didSet {
            updateBackgroundColor()
        }
    }
    
    /// The background color to use when the button is highlighted.
    @IBInspectable var highlightedColor: UIColor = .systemBackground {
        didSet {
            updateBackgroundColor()
        }
    }

    override var isHighlighted: Bool {
        didSet {
            updateBackgroundColor()
        }
    }
    
    override func prepareForInterfaceBuilder() {
        doInitialSetup()
    }
    
    private func doInitialSetup() {
        adjustsImageWhenHighlighted = false
        updateBackgroundColor()
    }
    
    private func updateBackgroundColor() {
        backgroundColor = isHighlighted ? highlightedColor : fillColor
    }
}
