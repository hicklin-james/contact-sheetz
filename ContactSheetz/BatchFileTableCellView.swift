//
//  GreyTableCellView.swift
//  ContactSheetz
//
//  Created by James Hicklin on 2016-11-21.
//  Copyright © 2016 James Hicklin. All rights reserved.
//

import Cocoa

protocol BatchFileTableCellDelegate {
    func removeCellRequested(from: BatchFileTableCellView)
}

class BatchFileTableCellView: NSTableCellView {
    
    @IBOutlet weak var statusLabel: NSTextField!
    @IBOutlet weak var completionProgressBar: NSProgressIndicator!
    var isGrey: Bool = false
    @IBOutlet weak var removeItemButton: NSButton!
    
    var delegate: BatchFileTableCellDelegate!

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        if isGrey {
            //NSColor.lightGray.setFill()
//            NSColor.init(red: 0.9686, green: 0.9686, blue: 0.9686, alpha: 1).setFill()
            NSColor.gray.setFill()
        } else {
            NSColor.lightGray.setFill()
        }
        dirtyRect.fill()
        
        // Drawing code here.
    }
    
    @IBAction func removeFromTable(_ sender: Any) {
        delegate.removeCellRequested(from: self)
    }
    
    func initializeCompletionBar(maxLength: Double) {
        self.completionProgressBar.maxValue = maxLength
        self.completionProgressBar.doubleValue = 0.0
    }
    
    func incrementProgressBar(increment: Double) {
        self.completionProgressBar.increment(by: increment)
    }
    
    func resetCell() {
        self.completionProgressBar.doubleValue = 0.0
        self.statusLabel.isHidden = true
    }
}
