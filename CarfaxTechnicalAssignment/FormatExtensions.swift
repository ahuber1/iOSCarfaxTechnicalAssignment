//
//  FormatExtensions.swift
//  CarfaxTechnicalAssignment
//
//  Created by Andrew Huber on 6/6/21.
//

import Foundation

// Taken from: https://stackoverflow.com/questions/29999024/adding-thousand-separator-to-int-in-swift
extension Formatter {
    static let withSeparator: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter
    }()
}

extension Int {
    var coercedAtLeastZero: Int {
        get {
            return self < 0 ? 0 : self
        }
    }
    
    var withThousandsSeparator: String {
        get {
            return withThousandsSeparator(fallbackValue: "0")
        }
    }
    
    func withThousandsSeparator(fallbackValue: String) -> String {
        return Formatter.withSeparator.string(for: self) ?? fallbackValue
    }
}
