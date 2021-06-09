//
//  UIViewExtensions.swift
//  CarfaxTechnicalAssignment
//
//  Created by Andrew Huber on 6/5/21.
//

import UIKit

extension CGSize {
    /// This `CGSize`'s aspect ratio (i.e., its width divided by its height).
    var aspectRatio: CGFloat {
        get {
            return width / height
        }
    }
    
    /// Creates a new `CGSize` with a known aspect ratio and width.
    /// - Parameters:
    ///   - aspectRatio: The known aspect ratio.
    ///   - width: The known height.
    init(withAspectRatio aspectRatio: CGFloat, andWidth width: CGFloat) {
        self.init(width: width, height: width / aspectRatio)
    }
    
    
    /// Creates a new `CGSize` with a known aspect ratio and height.
    /// - Parameters:
    ///   - aspectRatio: The known aspect ratio.
    ///   - height: The known height.
    init(withAspectRatio aspectRatio: CGFloat, andHeight height: CGFloat) {
        self.init(width: height * aspectRatio, height: height)
    }
    
    
    /// Creates and returns a new `CGSize` with width and height increased or decreased by the provided `UIEdgeInsets`.
    /// - Parameter insets: The `UIEdgeInsets` by which to increase or decrease the width and/or height by.
    /// - Returns: A new `CGSize` with width and height increased or decreased by `insets`.
    func with(insets: UIEdgeInsets) -> CGSize {
        return CGSize(width: self.width - insets.left - insets.right, height: self.height - insets.top - insets.bottom)
    }
}

extension UIEdgeInsets {
    
    /// Creates a new `UIEdgeInsets` where the top, left, bottom, and right inset are identical.
    /// - Parameter inset: The value to use as the top, left, bottom, and right inset.
    init(uniformInset inset: CGFloat) {
        self.init(top: inset, left: inset, bottom: inset, right: inset)
    }
}

extension UIImage {
    
    /// A convenience initializer for creating a `UIImage` from a URL.
    ///
    /// This initializer returns `nil` if any of the following occur:
    /// - `urlString` is an invalid URL.
    /// - The contents at the URL cannot be downloaded.
    /// - No data was returned from the URL.
    ///
    /// - Parameter urlString: The URL of the image to display as a String.
    convenience init?(fromURL urlString: String) {
        guard let url = URL(string: urlString) else { return nil }
        guard let data = try? Data(contentsOf: url) else { return nil }
        guard data.count > 0 else { return nil }
        self.init(data: data)
    }
}

extension UIView {
    /// Applies a corner radius on the `UIView`'s `CALayer` and enures subviews are clipped to the bounds of this `UIView`.
    /// - Parameter cornerRadius: The corner radius to apply to this `UIView`.
    func applyCornerRadius(of cornerRadius: CGFloat) {
        self.layer.cornerRadius = cornerRadius
        self.clipsToBounds = true
    }
}
