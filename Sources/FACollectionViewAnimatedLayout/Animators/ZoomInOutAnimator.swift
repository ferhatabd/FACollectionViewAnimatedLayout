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
    
    /// Alpha value offset for the cells outside the center
    public var alphaOffset: CGFloat
    
    private var finalAlpha: CGFloat
    
    public init(scaleRate: CGFloat = 0.2, alphaOffset: CGFloat = 0.5) {
        self.scaleRate = scaleRate
        self.alphaOffset = alphaOffset
        self.finalAlpha = 1 - self.alphaOffset
    }
    
    public func animate(collectionView: UICollectionView, attributes: AnimatedLayoutAttributes) {
        let position = attributes.middleOffset
        
        let alpha: CGFloat = 1 - min(abs(position), finalAlpha)
        attributes.alpha = alpha
        
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
