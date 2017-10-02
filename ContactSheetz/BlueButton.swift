//
//  BlueButton.swift
//  ContactSheetz
//
//  Created by James Hicklin on 2017-09-06.
//  Copyright © 2017 James Hicklin. All rights reserved.
//

import Cocoa

class BlueButton: NSButton {
    
    let blueFill: (CGFloat, CGFloat, CGFloat) = (0.435, 0.753, 0.886)
    let darkBlueFill: (CGFloat, CGFloat, CGFloat) = (0.357, 0.616, 0.729)
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // Drawing code here.
    }
    
    override func awakeFromNib() {
        self.wantsLayer = true
    }
    
    override var wantsUpdateLayer: Bool  {
        return true
    }
    
//    override func draw(_ dirtyRect: NSRect) {
//        super.draw(dirtyRect)
//        if (self.cell?.isHighlighted)! {
//            NSColor.init(red: darkBlueFill.0, green: darkBlueFill.1, blue: darkBlueFill.2, alpha: 1).setFill()
//        }
//        else {
//            NSColor.init(red: blueFill.0, green: blueFill.1, blue: blueFill.2, alpha: 1).setFill()
//        }
//        NSRectFill(dirtyRect)
//    }
//    

    override func updateLayer() {
        if (self.cell?.isHighlighted)! {
            if let l = self.layer {
                l.backgroundColor = CGColor.init(red: darkBlueFill.0, green: darkBlueFill.1, blue: darkBlueFill.2, alpha: 1)
                l.cornerRadius = 5
                l.borderWidth = 1.0
                l.borderColor = NSColor.gray.cgColor
                //l.contentsCenter = CGRect.init(x: 0.5, y: 0.5, width: 0, height: 0)
                //let img = NSImage.init(named: "pushed_button.png")
//                if let _img = img {
//                    //_img.capInsets = EdgeInsets.init(top: <#T##CGFloat#>, left: <#T##CGFloat#>, bottom: <#T##CGFloat#>, right: <#T##CGFloat#>)
//                }
                //l.contents = [NSImage.init(named: "pushed_button.png")]
            }
        }
        else {
            if let l = self.layer {
                l.backgroundColor = CGColor.init(red: blueFill.0, green: blueFill.1, blue: blueFill.2, alpha: 1)
                l.cornerRadius = 5
                l.borderWidth = 1.0
                l.borderColor = NSColor.gray.cgColor
                //l.contentsCenter = CGRect.init(x: 0.5, y: 0.5, width: 0, height: 0)
                //l.contents = [NSImage.init(named: "button.png")]
            }
        }
    }
}
