//
//  TabbedPreviewViewController.swift
//  ContactSheetz
//
//  Created by James Hicklin on 2016-10-06.
//  Copyright © 2016 James Hicklin. All rights reserved.
//

import Cocoa

class TabbedPreviewViewController: NSTabViewController, NSWindowDelegate {
    
    var vfe: VideoFrameExtractor? = nil
    var filePath: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
}
