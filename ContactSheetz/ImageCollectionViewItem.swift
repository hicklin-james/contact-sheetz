//
//  ImageCollectionViewItem.swift
//  ContactSheetz
//
//  Created by James Hicklin on 2016-10-04.
//  Copyright © 2016 James Hicklin. All rights reserved.
//

import Cocoa

class ImageCollectionViewItem: NSCollectionViewItem {

    @IBOutlet weak var customImageView: NSImageView!
    @IBOutlet weak var timestampLabel: NSTextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        customImageView.imageScaling = NSImageScaling.scaleProportionallyUpOrDown
        //timestampLabel.translatesAutoresizingMaskIntoConstraints = true
        // Do view setup here.
    }
}
