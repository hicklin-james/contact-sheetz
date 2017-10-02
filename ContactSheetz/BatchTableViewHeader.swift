//
//  BatchTableViewHeader.swift
//  ContactSheetz
//
//  Created by James Hicklin on 2016-11-22.
//  Copyright © 2016 James Hicklin. All rights reserved.
//

import Cocoa

protocol BatchTableViewHeaderDelegate {
    func clearFilesButtonPushed()
    func addButtonPushed()
}

class BatchTableViewHeader: NSTableHeaderView {

    @IBOutlet weak var clearAllButton: NSButton!
    
    var delegate: BatchTableViewHeaderDelegate!
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        NSColor.white.setFill()
        NSRectFill(dirtyRect)
        // Drawing code here.
    }
    
    @IBAction func clearAllButtonClicked(_ sender: Any) {
        delegate.clearFilesButtonPushed()
    }
    
    @IBAction func AddButtonPushed(_ sender: Any) {
        delegate.addButtonPushed()
    }
    
}
