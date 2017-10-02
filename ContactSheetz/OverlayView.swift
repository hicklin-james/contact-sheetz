//
//  OverlayView.swift
//  ContactSheetz
//
//  Created by James Hicklin on 2016-10-05.
//  Copyright © 2016 James Hicklin. All rights reserved.
//

import Cocoa

class OverlayView: NSView {
    
    override var wantsUpdateLayer: Bool  {
        return true
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    override func awakeFromNib() {
        self.wantsLayer = true
    }
    
    override func updateLayer() {
        self.layer?.backgroundColor = NSColor.init(red: 0.227, green: 0.251, blue: 0.337, alpha: 0.6).cgColor
    }
    
}
