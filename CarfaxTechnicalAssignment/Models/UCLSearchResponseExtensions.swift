//
//  UCLSearchResponseExtensions.swift
//  CarfaxTechnicalAssignment
//
//  Created by Andrew Huber on 6/9/21.
//

import UIKit

extension DealerInfo {
    var cityStateZip: String {
        get {
            return city.isEmpty || state.isEmpty || zip.isEmpty ? "" : "\(city), \(state) \(zip)"
        }
    }
}

extension Listing {
    var mileageString: String {
        get {
            return "\(mileage.coercedAtLeastZero.withThousandsSeparator) mi"
        }
    }
    
    var priceString: String {
        get {
            return "$\(currentPrice.coercedAtLeastZero.withThousandsSeparator)"
        }
    }
    
    var ymmt: String {
        get {
            let yearString = year <= 0 ? "" : String(year)
            let parts = [yearString, make, model, trim].filter { !$0.isEmpty }
            return parts.joined(separator: " ")
        }
    }
}
