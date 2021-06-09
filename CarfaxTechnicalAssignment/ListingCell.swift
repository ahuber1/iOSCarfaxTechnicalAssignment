//
//  ListingCell.swift
//  CarfaxTechnicalAssignment
//
//  Created by Andrew Huber on 6/5/21.
//

import UIKit

class ListingCell: UICollectionViewCell {
    // This overlay is inset 1 pixel from the left, top, and right edges of the cell, which has a
    // gray background, giving the illusion that there partial border around the cell that runs
    // from the top left of the Call Dealer button all the way around the top of the cell and
    // down to the top right of the Call Dealer button.
    @IBOutlet weak var cellOverlay: UIView!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var ymmtLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var mileageLabel: UILabel!
    @IBOutlet weak var dealerNameLabel: UILabel!
    @IBOutlet weak var dealerStreetLabel: UILabel!
    @IBOutlet weak var dealerAddressLabel: UILabel!
    @IBOutlet weak var callDealerButton: FilledButton!
    
    // Views for the "Image Not Available" placeholder
    @IBOutlet weak var placeholderBackground: UIView!
    @IBOutlet weak var photoPlaceholderImageView: UIImageView!
    @IBOutlet weak var imageNotAvailableLabel: UILabel!
    
    var onCallDealerButtonClicked: (() -> Void)?
    
    @IBAction func callDealerButtonClicked(_ sender: UIButton) {
        if let action = onCallDealerButtonClicked {
            action()
        }
    }
}
