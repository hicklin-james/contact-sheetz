//
//  ImageCollectionViewClip.swift
//  ContactSheetz
//
//  Created by James Hicklin on 2016-11-08.
//  Copyright © 2016 James Hicklin. All rights reserved.
//

import Cocoa

class ImageCollectionViewClip: NSClipView {
    
    var color: NSColor = Constants.DefaultValuesForParameters.BackgroundColor

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        color.setFill()
        dirtyRect.fill()
        // Drawing code here.
    }
    
}
