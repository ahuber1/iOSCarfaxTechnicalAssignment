//
//  FormatExtensions.swift
//  CarfaxTechnicalAssignment
//
//  Created by Andrew Huber on 6/6/21.
//

import Foundation

// Taken from: https://stackoverflow.com/questions/29999024/adding-thousand-separator-to-int-in-swift
extension Formatter {
    // A `NumberFormatter` that formats numbers with a comma thousands separator.
    static let withSeparator: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter
    }()
}

extension Int {
    
    /// Returns 0 if this `Int` is less than zero or this `Int` value otherwise.
    var coercedAtLeastZero: Int {
        get {
            return self < 0 ? 0 : self
        }
    }
    
    /// Returns this `Int` formatted with a comma thousands separator.
    var withThousandsSeparator: String {
        get {
            return Formatter.withSeparator.string(for: self) ?? "0"
        }
    }
}
