//
//  FlippedView.swift
//  ContactSheetz
//
//  Created by James Hicklin on 2016-11-14.
//  Copyright © 2016 James Hicklin. All rights reserved.
//

import Cocoa

class FlippedView: NSView {
    
    override var isFlipped: Bool { return true }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
    
}
