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
    private var cachedSpacing: CGFloat?
    
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.delaysContentTouches = false
        performRefresh()
    }
    
    
    override func viewWillLayoutSubviews() {
        if let recordedFrameSize = cachedFrameSize {
            if recordedFrameSize != view.frame.size {
                collectionView.collectionViewLayout.invalidateLayout()
            }
        }
    }
    
    @IBAction func onRefreshButtonClicked(_ sender: UIBarButtonItem) {
        performRefresh()
    }
    
    fileprivate func performRefresh() {
        listings.removeAll()
        collectionView.reloadData()
        
        updateNavigationTitle()
        refreshButton.isEnabled = false
        
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
                        let alertController = UIAlertController(title: "Unable to load listings", message: error.localizedDescription, preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alertController, animated: true, completion: nil)
                    }
                    
                    self.updateNavigationTitle()
                    self.refreshButton.isEnabled = true
                }
            }
        }
    }
    
    fileprivate func updateNavigationTitle() {
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
        cell.cellOverlay.applyCornerRadius(of: cellCornerRadius)
        
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
        cell.imageView.applyCornerRadius(of: cellCornerRadius)
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
                
                if let popoverController = alertController.popoverPresentationController {
                    popoverController.sourceView = cell.callDealerButton
                }
                
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
        return UIEdgeInsets(uniformInset: getSizes().spacing)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return getSizes().spacing
    }
    
    fileprivate func getSizes() -> (cellSize: CGSize, frameSize: CGSize, spacing: CGFloat) {
        let frameSize = view.frame.size
        
        // If we have
        if let recordedFrameSize = cachedFrameSize, let recordedCellSize = cachedCellSize, let recordedSpacing = cachedSpacing {
            if recordedFrameSize == frameSize {
                return (recordedCellSize, recordedFrameSize, recordedSpacing)
            }
        }
        
        let spacing: CGFloat
        let cellSize: CGSize
        
        let aspectRatio = requestedCellSize.aspectRatio
        var cellCount = numberOfCellsInRow(inFrameWithWidth: frameSize.width, withSpacing: requestedSpacing, andWithAMinimumCellWidthOf: requestedCellSize.width)
        
        if cellCount > 0 {
            // If we can fit at least one cell with the requested spacing, calculate the cell width and maintain the same aspect ratio as the requested cell size
            spacing = requestedSpacing
            let cellWidth = widthOfCellInRow(inFrameWithWidth: frameSize.width, withSpacing: requestedSpacing, andWithACellCountPerRowOf: cellCount)
            cellSize = CGSize(withAspectRatio: aspectRatio, andWidth: cellWidth)
        } else {
            spacing = minimumSpacing
            cellCount = numberOfCellsInRow(inFrameWithWidth: frameSize.width, withSpacing: minimumSpacing, andWithAMinimumCellWidthOf: requestedCellSize.width)
            if cellCount > 0 {
                // If we can fit at least once cell with the minimum spacing, calculate the cell width and maintain the same aspect ratio as the requested cell size
                let cellWidth = widthOfCellInRow(inFrameWithWidth: frameSize.width, withSpacing: minimumSpacing, andWithACellCountPerRowOf: cellCount)
                cellSize = CGSize(withAspectRatio: aspectRatio, andWidth: cellWidth)
            } else {
                // If we cannot fit at least once cell, shrink the cell widthwise so there is minimumSpacing spacing on the left and right side, and set the cell
                // height so it is the same as the requested cell height
                let cellWidth = frameSize.width - (minimumSpacing * 2)
                cellSize = CGSize(width: cellWidth, height: requestedCellSize.height)
            }
        }
        
        // Cache results
        cachedFrameSize = frameSize
        cachedCellSize = cellSize
        cachedSpacing = spacing
        
        return (cellSize, frameSize, spacing)
    }
    
    fileprivate func numberOfCellsInRow(inFrameWithWidth frameWidth: CGFloat, withSpacing spacing: CGFloat, andWithAMinimumCellWidthOf minimumCellWidth: CGFloat) -> Int {
        return Int(floor((frameWidth - spacing) / (minimumCellWidth + spacing)))
    }
    
    fileprivate func widthOfCellInRow(inFrameWithWidth frameWidth: CGFloat, withSpacing spacing: CGFloat, andWithACellCountPerRowOf cellCount: Int) -> CGFloat {
        return (frameWidth - (spacing * (CGFloat(cellCount) + 1))) / CGFloat(cellCount)
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
