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

extension CGSize {
    var aspectRatio: CGFloat {
        get {
            return width / height
        }
    }
    
    init(withAspectRatio aspectRatio: CGFloat, andWidth width: CGFloat) {
        self.init(width: width, height: width / aspectRatio)
    }
    
    init(withAspectRatio aspectRatio: CGFloat, andHeight height: CGFloat) {
        self.init(width: height * aspectRatio, height: height)
    }
}

extension UIImage {
    convenience init?(fromURL urlString: String) {
        guard let url = URL(string: urlString) else { return nil }
        guard let data = try? Data(contentsOf: url) else { return nil }
        guard data.count > 0 else { return nil }
        self.init(data: data)
    }
}
