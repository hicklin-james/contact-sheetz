//
//  greyBorderView.swift
//  ContactSheetz
//
//  Created by James Hicklin on 2016-11-22.
//  Copyright © 2016 James Hicklin. All rights reserved.
//

import Cocoa

class greyBorderView: NSView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        NSColor.lightGray.setFill()
        dirtyRect.fill()
        // Drawing code here.
    }
    
}
