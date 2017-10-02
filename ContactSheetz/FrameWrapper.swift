//
//  FrameWrapper.swift
//  ContactSheetz
//
//  Created by James Hicklin on 2016-11-02.
//  Copyright © 2016 James Hicklin. All rights reserved.
//

import Cocoa

class FrameWrapper {
    let image: NSImage
    let timestamp: String
    
    init(_image: NSImage, _timestamp: String) {
        image = _image
        timestamp = _timestamp
    }
}
