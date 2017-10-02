//
//  AdjustorViewTextField.swift
//  ContactSheetz
//
//  Created by James Hicklin on 2016-11-01.
//  Copyright © 2016 James Hicklin. All rights reserved.
//

import Cocoa

protocol AdjustorViewTextFieldDelegate {
    func textDidChangeInTextField(textField: AdjustorViewTextField, value: String?)
}

class AdjustorViewTextField: NSTextField  {
    
    var lastValidValue: String? = ""
    var adjustorViewDelegate: AdjustorViewTextFieldDelegate!

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    override func textShouldBeginEditing(_ textObject: NSText) -> Bool {
        lastValidValue = textObject.string
        return true
    }
    
    func notifyDelegate(newString: String?) {
        if newString != lastValidValue && self.adjustorViewDelegate != nil {
            self.adjustorViewDelegate.textDidChangeInTextField(textField: self, value: newString)
        }
    }
 
}
