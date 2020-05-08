//
//  FileDropView.swift
//  ContactSheetz
//
//  Created by James Hicklin on 2016-10-27.
//  Copyright © 2016 James Hicklin. All rights reserved.
//

import Cocoa

protocol FileDropViewDelegate {
    func validFileDropped(withPath path: String)
    func fileDragged(withValidity valid: FileDropView.FileValidity)
    func hasValidFile() -> Bool
}

class FileDropView: NSView {
    
    var drawingAnimated: Bool = false
    var currentIncrement = 0
    var dragTimer =  Cocoa.Timer()
    
    //var successfulInput = false
    //let successColor: (CGFloat, CGFloat, CGFloat) = (0.710, 1.000, 0.890)
    let noColor: (CGFloat, CGFloat, CGFloat) = (0.961, 0.961, 0.961)
    
    enum FileValidity {
        case Unknown
        case Valid
        case Invalid
    }
    
    var delegate: FileDropViewDelegate!
    // should probably be using codec instead of file extension but whatevs
    //let acceptedFileExtensions = ["mkv", "mp4", "avi", "mwv", "flv", "mov", "asf", "qt", "swf", "mpg", "mpeg", "ogv"]

    override func draw(_ dirtyRect: NSRect) {
        //if (successfulInput) {
        //    NSColor.init(red: successColor.0, green: successColor.1, blue: successColor.2, alpha: 1).setFill()
        //}
        //else {
        NSColor.init(red: noColor.0, green: noColor.1, blue: noColor.2, alpha: 1).setFill()
        //}
        
        dirtyRect.fill()
        super.draw(dirtyRect)
        drawBorder(rect: dirtyRect)
        // Drawing code here.
    }
    
    func animateBackgroundColor() {
        
    }
    
    func drawBorder(rect: NSRect) {
        let frame = self.bounds
        
        NSColor.init(red: 0.341, green: 0.573, blue: 1, alpha: 1.0).set()
        
        if (rect.size.height < frame.size.height) {
            return
        }
        let newRect = NSRect.init(x: rect.origin.x + 2, y: rect.origin.y + 2, width: rect.size.width - 3, height: rect.size.height - 3)
        let dashLength = rect.size.width / 15.0
        let dashSpace = dashLength / 5.0
        let numDashes = ((rect.size.width * 2) + (rect.size.height * 2)) / 20
        var borderDashes: [CGFloat] = []
        for _ in 1...Int(numDashes) {
            borderDashes.append(dashLength)
            borderDashes.append(dashSpace)
        }
        let border = NSBezierPath.init(roundedRect: newRect, xRadius: 0, yRadius: 0)
        if self.drawingAnimated {
            border.setLineDash(borderDashes, count: borderDashes.count, phase: CGFloat(currentIncrement))
            currentIncrement += 1
        }
        else {
            border.setLineDash(borderDashes, count: borderDashes.count, phase: 0)
        }
        border.lineWidth = 3
        
        border.stroke()
        
    }
    
    @objc func drawAnimatedBorder(timer: Cocoa.Timer) {
        //NSLog("Drawing animated border!")
        //DispatchQueue.main.async( execute: {
        self.display()
        //})
//        if let frame = timer.userInfo as? NSRect {
//            NSLog("Redrawing border!")
//            drawBorder(rect: frame, incrementBorder: true)
//        }
    }
    
    override func awakeFromNib() {
        self.registerForDraggedTypes([NSPasteboard.PasteboardType.fileURL])
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        delegate.fileDragged(withValidity: FileDropView.FileValidity.Unknown)
        //var userinfo: [String:AnyObject] = Dictionary.init()
        //userinfo["frame"] = self.view.frame as AnyObject
        self.drawingAnimated = true
        dragTimer = Cocoa.Timer.scheduledTimer(timeInterval: 0.005, target: self, selector: #selector(self.drawAnimatedBorder), userInfo: self.frame, repeats: true)
        return NSDragOperation.copy
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {
        dragTimer.invalidate()
        //self.currentIncrement = 0
        self.drawingAnimated = false
        if (delegate.hasValidFile()) {
            delegate.fileDragged(withValidity: FileDropView.FileValidity.Valid)
            //successfulInput = true
        }
        else {
            delegate.fileDragged(withValidity: FileDropView.FileValidity.Unknown)
            //successfulInput = false
        }
        //self.display()
    }
    
    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        return NSDragOperation.copy
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        dragTimer.invalidate()
        //self.currentIncrement = 0
        self.drawingAnimated = false
        let pasteBoard = sender.draggingPasteboard()
        let fileNames = pasteBoard.propertyList(forType: NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")) as? NSArray
        if let _files = fileNames as? [String] {
            if (_files.count == 1) {
                let file = URL.init(fileURLWithPath: _files[0])
                if Constants.AcceptedFileTypes.contains(file.pathExtension) {
                    // call delegate function
                    //successfulInput = true
                    //self.display()
                    delegate.validFileDropped(withPath: file.path)
                    delegate.fileDragged(withValidity: FileDropView.FileValidity.Valid)
                    //successfulInput = true
                    return true
                }
                
            }
        }
        //successfulInput = false
        //self.display()
        delegate.fileDragged(withValidity: FileDropView.FileValidity.Invalid)
        return false
    }
    
}
