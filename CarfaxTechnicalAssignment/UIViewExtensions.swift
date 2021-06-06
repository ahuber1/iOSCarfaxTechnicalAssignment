//
//  UIViewExtensions.swift
//  CarfaxTechnicalAssignment
//
//  Created by Andrew Huber on 6/5/21.
//

import Foundation
import UIKit

extension UIView {
    func applyCornerRadius(of cornerRadius: CGFloat) {
        self.layer.cornerRadius = cornerRadius
        self.clipsToBounds = true
    }
}
