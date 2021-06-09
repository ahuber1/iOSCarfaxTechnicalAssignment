//
//  ListingCellImageView.swift
//  CarfaxTechnicalAssignment
//
//  Created by Andrew Huber on 6/9/21.
//

import UIKit

@IBDesignable class ListingCellImageView: UIImageView {
    @IBInspectable var cornerRadius: CGFloat = 6 {
        didSet {
            if cornerRadius != oldValue {
                applyCornerRadius()
            }
        }
    }
    
    @IBInspectable var roundedCorners: UIRectCorner = [.topLeft, .topRight] {
        didSet {
            if roundedCorners != oldValue {
                applyCornerRadius()
            }
        }
    }
    
    override var bounds: CGRect {
        didSet {
            if bounds != oldValue {
                applyCornerRadius()
            }
        }
    }
    
    override func prepareForInterfaceBuilder() {
        applyCornerRadius()
    }
    
    private func applyCornerRadius() {
        applyCornerRadius(of: cornerRadius, to: roundedCorners)
    }
    
}
