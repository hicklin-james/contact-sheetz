//
//  ImageHelper.swift
//  ContactSheetz
//
//  Created by James Hicklin on 2016-11-23.
//  Copyright © 2016 James Hicklin. All rights reserved.
//

import Cocoa

class ImageHelper: NSObject {
    
    static func saveAsFormat(image: NSImage, path: URL, format: NSBitmapImageFileType) {
        let reps = image.representations
        let compressionFactor = 1
        let imageProps = NSDictionary.init(object: compressionFactor, forKey: NSImageCompressionFactor as NSCopying)
        guard let bitmapData = NSBitmapImageRep.representationOfImageReps(in: reps, using: format, properties: imageProps as! [String : Any]) else {
            return
        }
        do {
            try bitmapData.write(to: path)
        } catch {
            NSLog("Couldn't save file")
        }
    }
}
