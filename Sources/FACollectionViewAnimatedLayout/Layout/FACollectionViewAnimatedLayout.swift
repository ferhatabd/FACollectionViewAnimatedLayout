

import UIKit

open class FACollectionViewAnimatedLayout: UICollectionViewFlowLayout {
    
    
    // MARK: - Properties
    //
    
    
    // MARK: - Private properties
    
    
    
    // MARK: - Public properties
    
    
    /// The animator that would actually handle the transitions.
    open var animator: LayoutAnimator?
    
    /// Overrided so that we can store extra information in the layout attributes.
    open override class var layoutAttributesClass: AnyClass { return AnimatedLayoutAttributes.self }
    
    /// Pagination
    open var isPaginationEnabled = false
    
    
    // MARK: - Initialization
    //
    public init(withAnimator animator: LayoutAnimator) {
        super.init()
        self.animator = animator
    }
    
    public override init() {
        super.init()
    }
    
    public required init?(coder: NSCoder) {
        preconditionFailure("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Methods
    //
    
    
    
    // MARK: - Private methods
    
    private func transformLayoutAttributes(_ attributes: AnimatedLayoutAttributes) -> UICollectionViewLayoutAttributes {
        
        guard let collectionView = self.collectionView else { return attributes }
        
        let a = attributes
        
        /**
         The position for each cell is defined as the ratio of the distance between
         the center of the cell and the center of the collectionView and the collectionView width/height
         depending on the scroll direction. It can be negative if the cell is, for instance,
         on the left of the screen if you're scrolling horizontally.
         */
        
        let distance: CGFloat
        let itemOffset: CGFloat
        
        if scrollDirection == .horizontal {
            distance = collectionView.frame.width
            itemOffset = a.center.x - collectionView.contentOffset.x
            a.startOffset = (a.frame.origin.x - collectionView.contentOffset.x) / a.frame.width
            a.endOffset = (a.frame.origin.x - collectionView.contentOffset.x - collectionView.frame.width) / a.frame.width
        } else {
            distance = collectionView.frame.height
            itemOffset = a.center.y - collectionView.contentOffset.y
            a.startOffset = (a.frame.origin.y - collectionView.contentOffset.y) / a.frame.height
            a.endOffset = (a.frame.origin.y - collectionView.contentOffset.y - collectionView.frame.height) / a.frame.height
        }
        
        a.scrollDirection = scrollDirection
        a.middleOffset = itemOffset / distance - 0.5
        
        // Cache the contentView since we're going to use it a lot.
        if a.contentView == nil,
            let c = collectionView.cellForItem(at: attributes.indexPath)?.contentView {
            a.contentView = c
        }
        
        animator?.animate(collectionView: collectionView, attributes: a)
        
        return a
    }
    
    
    // MARK: - Public methods
    
    
    open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElements(in: rect) else { return nil }
        return attributes.compactMap { $0.copy() as? AnimatedLayoutAttributes }.map { self.transformLayoutAttributes($0) }
    }
    
    open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        // We have to return true here so that the layout attributes would be recalculated
        // everytime we scroll the collection view.
        return true
    }
}


extension FACollectionViewAnimatedLayout {
    
    open override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        
        if isPaginationEnabled {
            guard let collectionView = collectionView else {
                return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
            }
            
            // Identify the layoutAttributes of cells in the vicinity of where the scroll view will come to rest
            let targetRect = CGRect(origin: proposedContentOffset, size: collectionView.bounds.size)
            let visibleCellsLayoutAttributes = layoutAttributesForElements(in: targetRect)
            
            // Translate those cell layoutAttributes into potential (candidate) scrollView offsets
            let candidateOffsets: [CGFloat]? = visibleCellsLayoutAttributes?.map({ cellLayoutAttributes in
                if #available(iOS 11.0, *) {
                    if scrollDirection == .horizontal {
                        return cellLayoutAttributes.frame.origin.x - collectionView.contentInset.left - collectionView.safeAreaInsets.left - sectionInset.left
                    } else  {
                        return cellLayoutAttributes.frame.origin.y - collectionView.contentInset.top - collectionView.safeAreaInsets.top - sectionInset.top
                    }
                } else {
                    if scrollDirection == .horizontal {
                        return cellLayoutAttributes.frame.origin.x - collectionView.contentInset.left - sectionInset.left
                    } else {
                        return cellLayoutAttributes.frame.origin.y - collectionView.contentInset.top - sectionInset.top
                    }
                }
            })
            
            // Now we need to work out which one of the candidate offsets is the best one
            let bestCandidateOffset: CGFloat
            
            if scrollDirection == .horizontal {
                if velocity.x > 0 {
                    // If the scroll velocity was POSITIVE, then only consider cells/offsets to the RIGHT of the proposedContentOffset.x
                    // Of the cells/offsets to the right, the NEAREST is the `bestCandidate`
                    // If there is no nearestCandidateOffsetToLeft then we default to the RIGHT-MOST (last) of ALL the candidate cells/offsets
                    //      (this handles the scenario where the user has scrolled beyond the last cell)
                    let candidateOffsetsToRight = candidateOffsets?.toRight(ofProposedOffset: proposedContentOffset.x)
                    let nearestCandidateOffsetToRight = candidateOffsetsToRight?.nearest(toProposedOffset: proposedContentOffset.x)
                    bestCandidateOffset = nearestCandidateOffsetToRight ?? candidateOffsets?.last ?? proposedContentOffset.x
                }
                else if velocity.x < 0 {
                    // If the scroll velocity was NEGATIVE, then only consider cells/offsets to the LEFT of the proposedContentOffset.x
                    // Of the cells/offsets to the left, the NEAREST is the `bestCandidate`
                    // If there is no nearestCandidateOffsetToLeft then we default to the LEFT-MOST (first) of ALL the candidate cells/offsets
                    //      (this handles the scenario where the user has scrolled beyond the first cell)
                    let candidateOffsetsToLeft = candidateOffsets?.toLeft(ofProposedOffset: proposedContentOffset.x)
                    let nearestCandidateOffsetToLeft = candidateOffsetsToLeft?.nearest(toProposedOffset: proposedContentOffset.x)
                    bestCandidateOffset = nearestCandidateOffsetToLeft ?? candidateOffsets?.first ?? proposedContentOffset.x
                }
                else {
                    // If the scroll velocity was ZERO we consider all `candidate` cells (regarless of whether they are to the left OR right of the proposedContentOffset.x)
                    // The cell/offset that is the NEAREST is the `bestCandidate`
                    let nearestCandidateOffset = candidateOffsets?.nearest(toProposedOffset: proposedContentOffset.x)
                    bestCandidateOffset = nearestCandidateOffset ??  proposedContentOffset.x
                }
                
                return CGPoint(x: bestCandidateOffset, y: proposedContentOffset.y)
            } else {
                if velocity.y > 0 {
                    // If the scroll velocity was POSITIVE, then only consider cells/offsets to the RIGHT of the proposedContentOffset.x
                    // Of the cells/offsets to the right, the NEAREST is the `bestCandidate`
                    // If there is no nearestCandidateOffsetToLeft then we default to the RIGHT-MOST (last) of ALL the candidate cells/offsets
                    //      (this handles the scenario where the user has scrolled beyond the last cell)
                    let candidateOffsetsToRight = candidateOffsets?.toRight(ofProposedOffset: proposedContentOffset.y)
                    let nearestCandidateOffsetToRight = candidateOffsetsToRight?.nearest(toProposedOffset: proposedContentOffset.y)
                    bestCandidateOffset = nearestCandidateOffsetToRight ?? candidateOffsets?.last ?? proposedContentOffset.y
                }
                else if velocity.y < 0 {
                    // If the scroll velocity was NEGATIVE, then only consider cells/offsets to the LEFT of the proposedContentOffset.x
                    // Of the cells/offsets to the left, the NEAREST is the `bestCandidate`
                    // If there is no nearestCandidateOffsetToLeft then we default to the LEFT-MOST (first) of ALL the candidate cells/offsets
                    //      (this handles the scenario where the user has scrolled beyond the first cell)
                    let candidateOffsetsToLeft = candidateOffsets?.toLeft(ofProposedOffset: proposedContentOffset.y)
                    let nearestCandidateOffsetToLeft = candidateOffsetsToLeft?.nearest(toProposedOffset: proposedContentOffset.y)
                    bestCandidateOffset = nearestCandidateOffsetToLeft ?? candidateOffsets?.first ?? proposedContentOffset.y
                }
                else {
                    // If the scroll velocity was ZERO we consider all `candidate` cells (regarless of whether they are to the left OR right of the proposedContentOffset.x)
                    // The cell/offset that is the NEAREST is the `bestCandidate`
                    let nearestCandidateOffset = candidateOffsets?.nearest(toProposedOffset: proposedContentOffset.y)
                    bestCandidateOffset = nearestCandidateOffset ??  proposedContentOffset.y
                }
                
                return CGPoint(x: proposedContentOffset.x, y: bestCandidateOffset)
            }
        } else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
        }
        
    }
}

fileprivate extension Sequence where Iterator.Element == CGFloat {
    
    func toLeft(ofProposedOffset proposedOffset: CGFloat) -> [CGFloat] {
        
        return filter() { candidateOffset in
            return candidateOffset < proposedOffset
        }
    }
    
    func toRight(ofProposedOffset proposedOffset: CGFloat) -> [CGFloat] {
        
        return filter() { candidateOffset in
            return candidateOffset > proposedOffset
        }
    }
    
    func nearest(toProposedOffset proposedOffset: CGFloat) -> CGFloat? {
        
        guard let firstCandidateOffset = first(where: { _ in true }) else {
            // If there are no elements in the Sequence, return nil
            return nil
        }
        
        return reduce(firstCandidateOffset) { (bestCandidateOffset: CGFloat, candidateOffset: CGFloat) -> CGFloat in
            
            let candidateOffsetDistanceFromProposed = abs(candidateOffset - proposedOffset)
            let bestCandidateOffsetDistancFromProposed = abs(bestCandidateOffset - proposedOffset)
            
            if candidateOffsetDistanceFromProposed < bestCandidateOffsetDistancFromProposed {
                return candidateOffset
            }
            
            return bestCandidateOffset
        }
    }
}

