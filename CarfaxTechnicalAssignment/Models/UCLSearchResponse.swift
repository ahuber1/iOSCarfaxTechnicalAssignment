//
//  Listing.swift
//  CarfaxTechnicalAssignment
//
//  Created by Andrew Huber on 6/5/21.
//

import UIKit

class UCLSearchResponse: Decodable {
    var listings: [Listing] = []
}

class Listing: Decodable {
    var currentPrice = 0
    var dealer = DealerInfo()
    var images = Images()
    var make = ""
    var mileage = 0
    var model = ""
    var trim = ""
    var year = 0
    
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

class DealerInfo: Decodable {
    var address = ""
    var city = ""
    var name = ""
    var phone = ""
    var state = ""
    var zip = ""
    
    var cityStateZip: String {
        get {
            return city.isEmpty || state.isEmpty || zip.isEmpty ? "" : "\(city), \(state) \(zip)"
        }
    }
}

class Images: Decodable {
    var firstPhoto = FirstPhotos()
}

class FirstPhotos: Decodable {
    var large = ""
    var medium = ""
    var small = ""
    
    var uiImage: UIImage? {
        get {
            guard let url = URL(string: large) else { return nil }
            guard let data = try? Data(contentsOf: url) else { return nil }
            return data.count > 0 ? UIImage(data: data) : nil
        }
    }
}
