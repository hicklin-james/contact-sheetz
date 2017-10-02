//
//  ImageCollectionLayout.swift
//  ContactSheetz
//
//  Created by James Hicklin on 2016-10-04.
//  Copyright © 2016 James Hicklin. All rights reserved.
//

import Cocoa

protocol ImageCollectionLayoutDelegate {
    func collectionView(collectionView: NSCollectionView, sizeForPhotoAtIndexPath indexPath: IndexPath) -> NSSize
}

@available(OSX 10.11, *)
class ImageCollectionLayout: NSCollectionViewFlowLayout {
    
    var imDelegate: ImageCollectionLayoutDelegate!
    var width: CGFloat = 0
    var individualHeight: CGFloat = 0
    var height: CGFloat = 0
    var numberOfColumns: Int = 3
    var numberOfRows: Int?
    var horizontalPadding: CGFloat = 2
    var verticalPadding: CGFloat = 2
    var backgroundColor: NSColor = NSColor.black
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /**
    override var minimumLineSpacing: CGFloat {
        get {
            return verticalPadding / 2
        }
        set {
            self.minimumLineSpacing = verticalPadding / 2
        }
    }
    
    override var minimumInteritemSpacing: CGFloat {
        get {
            return horizontalPadding / 2
        }
        set {
            self.minimumInteritemSpacing = horizontalPadding / 2
        }
    }
    
    override var itemSize: NSSize {
        get {
            //NSLog("HERE!")
            let individualWidth = (width / CGFloat(numberOfColumns)) - horizontalPadding
            let individualHeight = (height / CGFloat(numberOfRows!)) - verticalPadding
            return NSSize.init(width: individualWidth, height: individualHeight)
        }
        set {
            let individualWidth = (width / CGFloat(numberOfColumns)) - horizontalPadding
            let individualHeight = (height / CGFloat(numberOfRows!)) - verticalPadding
            self.itemSize = NSSize.init(width: individualWidth, height: individualHeight)
        }
    }
    
    override var scrollDirection: NSCollectionViewScrollDirection {
        get {
            return NSCollectionViewScrollDirection.vertical
        }
        set {
            self.scrollDirection = NSCollectionViewScrollDirection.vertical
        }
    }
    **/
    override var collectionViewContentSize: NSSize {
        if let view = self.collectionView {
            let itemCount = view.numberOfItems(inSection: 0)
            let rows = itemCount / Int(numberOfColumns) + ((itemCount % Int(numberOfColumns)) > 0 ? 1 : 0)
            numberOfRows = rows
            
            if itemCount > 0 {
                let imageSize = imDelegate.collectionView(collectionView: view, sizeForPhotoAtIndexPath: IndexPath.init(item: 0, section: 0))
                let ar = CGFloat(imageSize.width) / CGFloat(imageSize.height)
                let newWidth = (width/CGFloat(numberOfColumns)) - horizontalPadding
                
                individualHeight = newWidth / ar
                height = (CGFloat(individualHeight) + verticalPadding) * CGFloat(rows)
            }
        }
        //NSLog("width: " + String(describing: width) + " height: " + String(describing: height))
        return NSSize.init(width: width, height: height)
    }
    
    override func prepare() {
        //NSLog("We are using the right layout")
        if let view = self.collectionView {
            if let sv = view.superview {
                width = sv.frame.size.width
            }
        }
        //self.sectionInset = NSEdgeInsetsMake(verticalPadding/2, horizontalPadding/2, verticalPadding/2, horizontalPadding/2)
    }
    
    /**
    override func initialLayoutAttributesForAppearingSupplementaryElement(ofKind elementKind: String, at elementIndexPath: IndexPath) -> NSCollectionViewLayoutAttributes? {
        NSLog("Called?!?!")
        return nil
    }
    **/
    
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> NSCollectionViewLayoutAttributes? {
        if let attr = layoutAttributesForItem(at: itemIndexPath) {
            attr.frame = NSRect(x: 0, y: 0, width: attr.frame.width, height: attr.frame.height)
            //attr.alpha = 0
            return attr
        }
        return nil
    }
    
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: NSRect) -> Bool {
        return true //!(newBounds.size.equalTo(self.collectionView!.frame.size))
    }
 
//    override func finalizeAnimatedBoundsChange() {
//        NSLog("Invalidating layout")
//        self.invalidateLayout()
//        self.collectionView!.layout()
//    }
    
    override func layoutAttributesForElements(in rect: NSRect) -> [NSCollectionViewLayoutAttributes] {
        var layoutAttributes = [NSCollectionViewLayoutAttributes]()
        
        if let view = self.collectionView {
            for i in 0..<view.numberOfItems(inSection: 0) {
                let ip = IndexPath.init(item: i, section: 0)
                if let attribute = layoutAttributesForItem(at: ip) {
                    if rect.intersects(attribute.frame) {
                        layoutAttributes.append(attribute)
                    }
                }
            }
        }

        return layoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> NSCollectionViewLayoutAttributes? {
        let row = indexPath.item / Int(numberOfColumns)
        let col = indexPath.item % Int(numberOfColumns)
        
        //let totalHorizontalPaddingSpace = horizontalPadding * CGFloat(numberOfColumns)
        let individualWidth = (width / CGFloat(numberOfColumns)) - horizontalPadding
        let xOffset: CGFloat = (CGFloat(col) * (width / CGFloat(numberOfColumns))) + (horizontalPadding / 2)
        
        //let totalVerticalPaddingSpace = verticalPadding * CGFloat(numberOfRows!)
        let individualHeight = (height / CGFloat(numberOfRows!)) - verticalPadding
        let yOffset: CGFloat = (CGFloat(row) * (height / CGFloat(numberOfRows!))) + (verticalPadding / 2)
        //NSLog(String(describing: row)
        //NSCollectionViewLayoutAttributes.i
        let attributes = NSCollectionViewLayoutAttributes.init(forItemWith: indexPath)
        
        attributes.frame = NSRect(x: xOffset, y: yOffset, width: individualWidth, height: individualHeight)
        attributes.zIndex = indexPath.item
        
        return attributes
    }
 

}
