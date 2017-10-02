//
//  ParameterAdjustorDraggerView.swift
//  ContactSheetz
//
//  Created by James Hicklin on 2016-10-07.
//  Copyright © 2016 James Hicklin. All rights reserved.
//

import Cocoa

class ParameterAdjustorDraggerView: NSView {
    
    var startPoint: NSPoint?
    
    //dragStartPoint
    
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
        //self.layer?.backgroundColor = NSColor.init(red: 255, green: 255, blue: 255, alpha: 0.8).cgColor
        //self.layer?.borderWidth = 2
        //self.layer?.borderColor = NSColor.black.cgColor
    }
    
    /**
    override func mouseDown(with event: NSEvent) {
        startPoint = self.convert(event.locationInWindow, from: nil)
    }
    
    override func mouseDragged(with event: NSEvent) {
        let trackingPoint = self.convert(event.locationInWindow, from: nil)
        if let start = startPoint, let parentView = self.superview as? ParameterAdjustorView, let superView = parentView.superview {
            // Get delta x and delta y
            let dx: CGFloat = start.x - trackingPoint.x
            let dy: CGFloat = start.y - trackingPoint.y
            // calculate position of new point
            var newPoint = NSPoint.init(x: parentView.frame.origin.x - dx, y: parentView.frame.origin.y - dy)
            
            // check that new position is within bounds of superview
            if (newPoint.x + parentView.frame.size.width) > superView.frame.size.width {
                newPoint.x =  superView.frame.size.width - parentView.frame.size.width
            }
            else if (newPoint.x < 0) {
                newPoint.x = 0
            }
            
            if (newPoint.y + parentView.frame.size.height) > superView.frame.size.height  {
                newPoint.y = superView.frame.size.height - parentView.frame.size.height
            }
            else if (newPoint.y < 0) {
                newPoint.y = 0
            }
            
            // set the new position and ask for redraw
            let newParentFrame = CGRect.init(origin: newPoint, size: parentView.frame.size)
            parentView.frame = newParentFrame
            parentView.setNeedsDisplay(parentView.frame)
        }
    }
    **/
}
