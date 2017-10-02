//
//  OpaqueImage.swift
//  ContactSheetz
//
//  Created by James Hicklin on 2016-10-27.
//  Copyright © 2016 James Hicklin. All rights reserved.
//

import Cocoa


class OpaqueImageView: NSImageView {
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // Drawing code here.
    }

    override func awakeFromNib() {
        self.wantsLayer = true
        self.unregisterDraggedTypes()
    }
    
    override var wantsUpdateLayer: Bool  {
        return true
    }
    
    override func updateLayer() {
        self.alphaValue = 0.2
    }

}
