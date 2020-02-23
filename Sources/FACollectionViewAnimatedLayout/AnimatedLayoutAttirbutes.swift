//
//  File.swift
//  
//
//  Created by Ferhat Abdullahoglu on 23.02.2020.
//

import UIKit

/// A custom layout attributes that contains extra information.
open class AnimatedLayoutAttributes: UICollectionViewLayoutAttributes {
    public var contentView: UIView?
    public var scrollDirection: UICollectionView.ScrollDirection = .vertical
    
    /// The ratio of the distance between the start of the cell and the start of the collectionView and the height/width of the cell depending on the scrollDirection. It's 0 when the start of the cell aligns the start of the collectionView. It gets positive when the cell moves towards the scrolling direction (right/down) while getting negative when moves opposite.
    public var startOffset: CGFloat = 0
    
    /// The ratio of the distance between the center of the cell and the center of the collectionView and the height/width of the cell depending on the scrollDirection. It's 0 when the center of the cell aligns the center of the collectionView. It gets positive when the cell moves towards the scrolling direction (right/down) while getting negative when moves opposite.
    public var middleOffset: CGFloat = 0
    
    /// The ratio of the distance between the **start** of the cell and the end of the collectionView and the height/width of the cell depending on the scrollDirection. It's 0 when the **start** of the cell aligns the end of the collectionView. It gets positive when the cell moves towards the scrolling direction (right/down) while getting negative when moves opposite.
    public var endOffset: CGFloat = 0
    
    open override func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! AnimatedLayoutAttributes
        copy.contentView = contentView
        copy.scrollDirection = scrollDirection
        copy.startOffset = startOffset
        copy.middleOffset = middleOffset
        copy.endOffset = endOffset
        return copy
    }
    
    open override func isEqual(_ object: Any?) -> Bool {
        guard let o = object as? AnimatedLayoutAttributes else { return false }
        
        return super.isEqual(o)
            && o.contentView == contentView
            && o.scrollDirection == scrollDirection
            && o.startOffset == startOffset
            && o.middleOffset == middleOffset
            && o.endOffset == endOffset
    }
}
