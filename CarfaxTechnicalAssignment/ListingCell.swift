//
//  ListingCell.swift
//  CarfaxTechnicalAssignment
//
//  Created by Andrew Huber on 6/5/21.
//

import UIKit

class ListingCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var ymmtLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var mileageLabel: UILabel!
    @IBOutlet weak var dealerNameLabel: UILabel!
    @IBOutlet weak var dealerStreetLabel: UILabel!
    @IBOutlet weak var dealerAddressLabel: UILabel!
    
    var onCallDealerButtonClicked: (() -> Void)?
    
    @IBAction func callDealerButtonClicked(_ sender: UIButton) {
        if let action = onCallDealerButtonClicked {
            action()
        }
    }
}
