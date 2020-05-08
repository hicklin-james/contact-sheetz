//
//  BatchFileTableView.swift
//  ContactSheetz
//
//  Created by James Hicklin on 2016-11-22.
//  Copyright © 2016 James Hicklin. All rights reserved.
//

import Cocoa

protocol BatchFileTableViewDelegate {
    func addedFiles(files: [String])
}

class BatchFileTableView: NSTableView {
    
    var batchFileDelegate: BatchFileTableViewDelegate!

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        NSColor.init(red: 0.188, green: 0.196, blue: 0.204, alpha: 1).setFill()
        dirtyRect.fill()

        // Drawing code here.
    }
    
    override func awakeFromNib() {
        self.registerForDraggedTypes([NSPasteboard.PasteboardType.fileURL])
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        return NSDragOperation.copy
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {

    }
    
    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        return NSDragOperation.copy
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let pasteBoard = sender.draggingPasteboard()
        let fileNames = pasteBoard.propertyList(forType: NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")) as? NSArray
        var newFiles: [String] = []
        if let _files = fileNames as? [String] {
            //if (_files.count == 1) {
            for file in _files {
                let fileObj = URL.init(fileURLWithPath: file)
                if Constants.AcceptedFileTypes.contains(fileObj.pathExtension) {
                    // verify that file can be opened with ffmpeg
                    if VideoFrameExtractor.checkVideoFile(filePath: file) {
                        newFiles.append(file)
                    }
                }
            }
            batchFileDelegate.addedFiles(files: newFiles)
        }
        return false
    }

    
    
    
}
