//
//  ListingCollectionViewController.swift
//  CarfaxTechnicalAssignment
//
//  Created by Andrew Huber on 6/5/21.
//

import UIKit

class ListingCollectionViewController: UICollectionViewController {
    private let client = UCLSearchClient()
    private let imageCache = ImageCache()
    private var listings: [Listing] = []
    private var randomize = false
    
    private let reuseIdentifier = "ListingCell"
    private let cellCornerRadius: CGFloat = 6
    
    private let minimumSpacing: CGFloat = 8
    private let requestedSpacing: CGFloat = 16
    
    private let requestedCellSize = CGSize(width: 358, height: 368)
    private var cachedCellSize: CGSize?
    private var cachedFrameSize: CGSize?
    private var cachedSpacing: CGFloat?
    
    private let refreshControl = UIRefreshControl()
    private var displayedRandomizePrompt = false
    @IBOutlet weak var randomizeBarButton: UIBarButtonItem!
    
    private var frameSize: CGSize {
        get {
            return view.frame.size.with(insets: view.safeAreaInsets)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.delaysContentTouches = false
        (self.collectionViewLayout as! UICollectionViewFlowLayout).sectionInsetReference = .fromSafeArea
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: #selector(self.performRefresh), for: .valueChanged)
        self.collectionView.addSubview(refreshControl)
        self.collectionView.alwaysBounceVertical = true
        performRefresh()
    }
    
    override func viewWillLayoutSubviews() {
        if let recordedFrameSize = cachedFrameSize {
            if recordedFrameSize != frameSize {
                collectionView.collectionViewLayout.invalidateLayout()
            }
        }
    }
    
    @IBAction func onRandomizeButtonTapped(_ sender: UIBarButtonItem) {
        if displayedRandomizePrompt {
            toggleRandomization()
            return
        }
        
        displayedRandomizePrompt = true
        let yesAction = UIAlertAction(title: "Yes", style: .default) { _ in self.toggleRandomization() }
        let noAction = UIAlertAction(title: "No", style: .cancel) { _ in self.displayedRandomizePrompt = false}
        
        let alertController = UIAlertController(
            title: "Are you sure you would like to shuffle the listings?",
            message: "Shuffling the listings makes the pull to refresh functionality easier to see.",
            preferredStyle: .actionSheet
        )
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.barButtonItem = sender
        }
        
        self.present(alertController, animated: true)
    }
    
    fileprivate func toggleRandomization() {
        randomize = !randomize
        randomizeBarButton.image = randomize ? UIImage(systemName: "shuffle.circle.fill") : UIImage(systemName: "shuffle.circle")
        refreshControl.beginRefreshing()
        
        // Set offset so refresh indiator is visible
        collectionView.setContentOffset(CGPoint.zero, animated: true)
        performRefresh()
    }
    
    @objc func performRefresh() {
        randomizeBarButton.isEnabled = false
        
        let attributedTitle = refreshControl.attributedTitle
        refreshControl.attributedTitle = nil
        
        listings.removeAll()
        collectionView.reloadData()
        
        client.pullListings { result in
            DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                DispatchQueue.main.sync {
                    switch result {
                    case .success(let response):
                        self.listings = self.randomize ? response.listings.shuffled() : response.listings
                        self.collectionView.reloadData()
                    case .failure(let error):
                        let alertController = UIAlertController(title: "Unable to load listings", message: error.localizedDescription, preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alertController, animated: true, completion: nil)
                    }
                    
                    self.updateNavigationTitle()
                    self.refreshControl.endRefreshing()
                    self.randomizeBarButton.isEnabled = true
                    self.refreshControl.attributedTitle = attributedTitle
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
        let image = imageCache[listing.images.firstPhoto]
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
                let cleanedPhoneNumber = listing.dealer.phone.filter { $0.isNumber }
                if let url = URL(string: "tel://\(cleanedPhoneNumber)") {
                    UIApplication.shared.open(url, options: [:]) { success in
                        if success {
                            return
                        }
                        
                        let alertController = UIAlertController(title: "Unable to call \(listing.dealer.phone)", message: nil, preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(alertController, animated: true)
                    }
                }
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
        if let recordedFrameSize = cachedFrameSize, let recordedCellSize = cachedCellSize, let recordedSpacing = cachedSpacing {
            if recordedFrameSize == frameSize {
                return (recordedCellSize, recordedFrameSize, recordedSpacing)
            }
        }
        
        // This block of code finds the spacing that will be to the left of the leftmost cell in a row, to the right of the rightmost cell in a row, and between cells in the same row.
        // First, we create an array of possible spacing values.
        let possibleSpacings = [minimumSpacing, requestedSpacing]
        
        // Then, we calculate the number of cells that can appear in a row with each spacing value. We discard results where no cells can appear in a row.
        let spacingCellCountPairs = possibleSpacings.compactMap { (spacing: CGFloat) -> (spacing: CGFloat, cellCount: Int)? in
            let count = numberOfCellsInRow(inFrameWithWidth: frameSize.width, withSpacing: spacing, andWithAMinimumCellWidthOf: requestedCellSize.width)
            return count > 0 ? (spacing, count) : nil
        }
        
        // We then sort the pairs first by their cell count in descending order followed by their spacing in descending order.
        // This prioritizes cell count (greater counts are preferred) over spacing (greater spacing is preferred).
        let sortedSpacingCellCountPairs = spacingCellCountPairs.sorted(by: { (left: (spacing: CGFloat, cellCount: Int), right: (spacing: CGFloat, cellCount: Int)) -> Bool in
            return left.cellCount == right.cellCount ? left.spacing > right.spacing : left.cellCount > right.cellCount
        })
        
        let cellSize: CGSize
        let spacing: CGFloat
        if let first = sortedSpacingCellCountPairs.first {
            // If we can use one of the preferred spacing/cell count pairs, use the spacing and cell count values to calculate the cell size.
            spacing = first.spacing
            let cellWidth = widthOfCellInRow(inFrameWithWidth: frameSize.width, withSpacing: spacing, andWithACellCountPerRowOf: first.cellCount)
            cellSize = CGSize(withAspectRatio: requestedCellSize.aspectRatio, andWidth: cellWidth)
        } else {
            // Otherwise, we're on a very small display where we have to make the cells narrower than we'd like. We can still make them as tall as we'd like, though,
            // so use the width that we have with minimumSpacing padding on the left and right, and a height of requestedCellSize.height.
            spacing = minimumSpacing
            let cellWidth = frameSize.width - (spacing * 2)
            cellSize = CGSize(width: cellWidth, height: requestedCellSize.height)
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
