//
//  ImageCollectionViewHeader.swift
//  ContactSheetz
//
//  Created by James Hicklin on 2016-11-03.
//  Copyright © 2016 James Hicklin. All rights reserved.
//

import Cocoa

class ImageCollectionViewHeader: NSView {
    
    var color: NSColor = Constants.DefaultValuesForParameters.BackgroundColor

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        color.setFill()
        NSRectFill(dirtyRect)
        
        // Drawing code here.
    }
    
    override func layout() {
        super.layout()
    }
    
}
