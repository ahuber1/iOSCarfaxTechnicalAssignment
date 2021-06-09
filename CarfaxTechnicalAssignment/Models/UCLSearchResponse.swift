//
//  UCLSearchResponse.swift
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
}

class DealerInfo: Decodable {
    var address = ""
    var city = ""
    var name = ""
    var phone = ""
    var state = ""
    var zip = ""
}

class Images: Decodable {
    var firstPhoto = FirstPhotos()
}

class FirstPhotos: Decodable {
    var large = ""
    var medium = ""
    var small = ""
}
