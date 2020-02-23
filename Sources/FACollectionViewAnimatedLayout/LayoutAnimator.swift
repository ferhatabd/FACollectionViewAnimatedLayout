//
//  File.swift
//  
//
//  Created by Ferhat Abdullahoglu on 23.02.2020.
//

import UIKit

public protocol LayoutAnimator {
    func animate(collectionView: UICollectionView, attributes: AnimatedLayoutAttributes)
}
