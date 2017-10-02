//
//  TooltipImageView.swift
//  ContactSheetz
//
//  Created by James Hicklin on 2016-12-23.
//  Copyright © 2016 James Hicklin. All rights reserved.
//

import Cocoa

class TooltipImageView: NSImageView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    func setTooltipValue(value: String) {
        self.toolTip = value
    }
    
}
