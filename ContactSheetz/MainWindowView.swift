//
//  MainWindowView.swift
//  ContactSheetz
//
//  Created by James Hicklin on 2016-10-27.
//  Copyright © 2016 James Hicklin. All rights reserved.
//

import Cocoa

class MainWindowView: NSClipView {
    
    var enabled: Bool = true

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        if enabled {
            NSColor.white.setFill()
            dirtyRect.fill()
        }
        else {
            let color = NSColor.init(red: 0.804, green: 0.788, blue: 0.788, alpha: 0.5)
            color.setFill()
            dirtyRect.fill()
        }

        // Drawing code here.
    }
    
}
