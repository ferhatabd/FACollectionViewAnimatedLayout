//
//  File.swift
//  
//
//  Created by Ferhat Abdullahoglu on 23.02.2020.
//

import UIKit

/// An animator that zoom in/out cells when you scroll.
public struct ZoomInOutAnimator: LayoutAnimator {
    /// The scaleRate decides the maximum scale rate where 0 means no scale and
    /// 1 means the cell will disappear at min. 0.2 by default.
    public var scaleRate: CGFloat
    
    public init(scaleRate: CGFloat = 0.2) {
        self.scaleRate = scaleRate
    }
    
    public func animate(collectionView: UICollectionView, attributes: AnimatedLayoutAttributes) {
        let position = attributes.middleOffset
        
        if position <= 0 && position > -1 {
            let scaleFactor = scaleRate * position + 1.0
            attributes.transform = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
        } else if position > 0 && position <= 1 { 
            let scaleFactor = -scaleRate * position + 1.0
            attributes.transform = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
        } else {
            attributes.transform = .identity
        }
    }
}
