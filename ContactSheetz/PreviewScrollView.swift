//
//  PreviewScrollView.swift
//  ContactSheetz
//
//  Created by James Hicklin on 2016-11-14.
//  Copyright © 2016 James Hicklin. All rights reserved.
//

import Cocoa

class PreviewScrollView: NSScrollView, NSWindowDelegate {
    
    var imageView: NSImageView!
    var initialWidth: CGFloat!
    var initialHeight: CGFloat!

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        // Drawing code here.
        let viewFrame = self.frame
        resizeScrollview(rect: viewFrame)
    }
    
    override func viewDidEndLiveResize() {
        let viewFrame = self.frame
        resizeScrollview(rect: viewFrame)
    }
    
    func resizeScrollview(rect: NSRect) {
        if initialHeight != nil && initialWidth != nil {
            let myWidth = rect.width
            let ar = initialHeight / initialWidth
            let height = myWidth * ar
            let newSize = NSSize(width: myWidth, height: height)
            if let _image = self.imageView.image {
                _image.size = newSize
            }
            self.documentView!.bounds.size = newSize
            //self.documentView!.frame.origin.y = -self.imageView.bounds.size.height
            self.needsDisplay = true
        }
    }

    
}
