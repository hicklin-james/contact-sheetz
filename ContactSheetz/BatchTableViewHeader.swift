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
    @IBOutlet weak var addNewButton: NSButton!
    
    var delegate: BatchTableViewHeaderDelegate!
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.center
        
        clearAllButton.attributedTitle = NSAttributedString(string: "Clear all", attributes: [ NSAttributedStringKey.foregroundColor : NSColor.white, NSAttributedStringKey.paragraphStyle : style ])
        
        addNewButton.attributedTitle = NSAttributedString(string: "+", attributes: [ NSAttributedStringKey.foregroundColor : NSColor.white, NSAttributedStringKey.paragraphStyle : style ])
        
        NSColor.init(red: 0.188, green: 0.196, blue: 0.204, alpha: 1).setFill() //.white.setFill()
        dirtyRect.fill()
        // Drawing code here.
    }
    
    @IBAction func clearAllButtonClicked(_ sender: Any) {
        delegate.clearFilesButtonPushed()
    }
    
    @IBAction func AddButtonPushed(_ sender: Any) {
        delegate.addButtonPushed()
    }
    
}
