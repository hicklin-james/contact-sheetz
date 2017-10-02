//
//  ParameterAdjustorView.swift
//  ContactSheetz
//
//  Created by James Hicklin on 2016-10-07.
//  Copyright © 2016 James Hicklin. All rights reserved.
//

import Cocoa

class BatchSettingsView: ParameterAdjustorView {

    @IBOutlet weak var outputFormatSelector: NSPopUpButton!
    
    /**
     override var wantsUpdateLayer: Bool  {
     return true
     }
     **/
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        NSColor.white.setFill()
        NSRectFill(dirtyRect)
    }
    
    override func initializeDefaultsValues() {
        super.initializeDefaultsValues()
        // set output format value here
        let defaults = UserDefaults.standard
        if let value = defaults.value(forKey: Constants.SettingsKeys.OutputFormat) as? String {
            outputFormatSelector.setTitle(value)
        }
        else {
            outputFormatSelector.setTitle(String(Constants.DefaultValuesForParameters.OutputFormat))
        }
    }
    
    /**
     override func hitTest(_ point: NSPoint) -> NSView? {
     if (!allowMouseEvents) {
     return nil
     }
     else {
     return super.hitTest(point)
     }
     }
     **/
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
