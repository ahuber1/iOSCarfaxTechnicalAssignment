//
//  ListingCollectionViewController.swift
//  CarfaxTechnicalAssignment
//
//  Created by Andrew Huber on 6/5/21.
//

import UIKit

class ListingCollectionViewController: UICollectionViewController {
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
        self.navigationItem.title = "Listings Near You"
        
        listings = [Listing](repeating: Listing(), count: 100) // TODO: Remove; only added for testing purposes
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        
        
        cell.backgroundColor = .black
        cell.applyCornerRadius(of: cellCornerRadius)
        
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
