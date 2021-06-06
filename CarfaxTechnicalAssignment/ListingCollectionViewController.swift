//
//  ListingCollectionViewController.swift
//  CarfaxTechnicalAssignment
//
//  Created by Andrew Huber on 6/5/21.
//

import UIKit

class ListingCollectionViewController: UICollectionViewController {
    private let client = UCLSearchClient()
    private var listings: [Listing] = []
    
    private let reuseIdentifier = "ListingCell"
    private let cellCornerRadius: CGFloat = 6
    
    private let minimumSpacing: CGFloat = 8
    private let requestedSpacing: CGFloat = 16
    
    private let requestedCellSize = CGSize(width: 358, height: 368)
    private var cachedCellSize: CGSize?
    private var cachedFrameSize: CGSize?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.delaysContentTouches = false
        updateNavigationTitle()
        
        let indicator = UIActivityIndicatorView(style: .large)
        self.view.addSubview(indicator)
        indicator.frame = self.view.bounds
        indicator.startAnimating()
        
        client.pullListings { result in
            DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                DispatchQueue.main.sync {
                    indicator.stopAnimating()
                    indicator.removeFromSuperview()
                    
                    switch result {
                    case .success(let response):
                        self.listings = response.listings
                        self.collectionView.reloadData()
                        
                    case .failure(let error):
                        print(error) // TODO: Show alert instead of printing error to console
                    }
                    
                    self.updateNavigationTitle()
                }
            }
        }
    }
    
    private func updateNavigationTitle() {
        let title: String
        switch listings.count {
        case 0:
            title = "Listings Near You"
        case 1:
            title = "1 Listing Near You"
        default:
            title = "\(listings.count.withThousandsSeparator) Listings Near You"
        }
        
        self.navigationItem.title = title
    }
}

// MARK: UICollectionViewController
extension ListingCollectionViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listings.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Get cell and apply a corner radius
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ListingCell
        cell.applyCornerRadius(of: cellCornerRadius)
        
        // Update cell's data
        let listing = listings[indexPath.row]
        cell.ymmtLabel.text = listing.ymmt
        cell.priceLabel.text = listing.priceString
        cell.mileageLabel.text = listing.mileageString
        cell.dealerNameLabel.text = listing.dealer.name
        cell.dealerStreetLabel.text = listing.dealer.address
        cell.dealerAddressLabel.text = listing.dealer.cityStateZip
        
        // Update cell's image
        let image = listing.images.firstPhoto.uiImage
        cell.imageView.image = image
        cell.imageView.isHidden = image == nil
        cell.imageOverlay.isHidden = image != nil
        cell.photoPlaceholderImageView.isHidden = image != nil
        cell.imageNotAvailableLabel.isHidden = image != nil
        
        // Setup callback for clicking "Call Dealer" button
        if listing.dealer.phone.isEmpty {
            cell.callDealerButton.isEnabled = false
            cell.onCallDealerButtonClicked = nil
        } else {
            cell.onCallDealerButtonClicked = {
                let callAction = UIAlertAction(title: "Call \(listing.dealer.phone)", style: .default) { action in
                    print("Calling \(listing.dealer.phone)")
                }
                let cancelAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
                
                let dealerName = listing.dealer.name.isEmpty ? "this dealer" : listing.dealer.name
                let alertController = UIAlertController(title: "Would you like to call \(dealerName)?", message: nil, preferredStyle: .actionSheet)
                alertController.addAction(callAction)
                alertController.addAction(cancelAction)
                
                self.present(alertController, animated: true, completion: nil)
            }
        }
        
        // Return configured cell
        return cell
    }
}

extension ListingCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return getSizes().cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let (cellSize, frameSize) = getSizes()
        let spacing = calculateSpacing()
        let remainingWidth = frameSize.with(insets: UIEdgeInsets(uniformInset: spacing)).width
        let numCellsPerRow = floor(remainingWidth / cellSize.width)
        let extraSpace = remainingWidth - (cellSize.width * numCellsPerRow)
        return UIEdgeInsets(top: spacing, left: extraSpace / 2, bottom: spacing, right: extraSpace / 2)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return calculateSpacing()
    }
    
    fileprivate func getSizes() -> (cellSize: CGSize, frameSize: CGSize) {
        let frameSize = view.frame.size
        
        // If we have
        if let recordedFrameSize = cachedFrameSize, let recordedCellSize = cachedCellSize {
            if recordedFrameSize == frameSize {
                return (recordedCellSize, recordedFrameSize)
            }
        }
        
        let remainingWidth = frameSize.with(insets: UIEdgeInsets(uniformInset: minimumSpacing)).width
        
        // Calculate the width of the cell
        var cellWidth: CGFloat
        
        if remainingWidth >= requestedCellSize.width {
            cellWidth = requestedCellSize.width // use the requested width if there is space to accomodate a cell with that width
        } else {
            cellWidth = remainingWidth // set the cell's width to the width of the frame with padding deducted from it
        }
        
        let cellSize = CGSize(width: cellWidth, height: requestedCellSize.height)
        
        // Cache the frame size and cell size we just calculated so we do not have to recompute cell size
        cachedFrameSize = frameSize
        cachedCellSize = cellSize
        
        return (cellSize, frameSize)
    }
    
    fileprivate func calculateSpacing() -> CGFloat {
        let (cellSize, frameSize) = getSizes()
        
        if frameSize.with(insets: UIEdgeInsets(uniformInset: requestedSpacing)).width >= cellSize.width {
            return requestedSpacing
        }
        
        return minimumSpacing
    }
}

private extension UIEdgeInsets {
    init(uniformInset inset: CGFloat) {
        self.init(top: inset, left: inset, bottom: inset, right: inset)
    }
}

private extension CGSize {
    func with(insets: UIEdgeInsets) -> CGSize {
        return CGSize(width: self.width - insets.left - insets.right, height: self.height - insets.top - insets.bottom)
    }
}
