//
//  PositiveIntegerTextField.swift
//  ContactSheetz
//
//  Created by James Hicklin on 2016-11-01.
//  Copyright © 2016 James Hicklin. All rights reserved.
//

import Cocoa

class PositiveIntegerTextField: AdjustorViewTextField {
    
    override func textShouldEndEditing(_ textObject: NSText) -> Bool {
        if let _str = textObject.string {
            if _str == "" {
                textObject.string = self.lastValidValue
                return false
            }
            
            let badCharacters = NSCharacterSet.decimalDigits.inverted
            
            if _str.rangeOfCharacter(from: badCharacters) != nil {
                NSBeep()
                textObject.string = self.lastValidValue
                return false
            }
            
            let intValue = Int(_str)
            if intValue != nil && intValue! <= 0 {
                NSBeep()
                textObject.string = self.lastValidValue
                return false
            }
            
            self.notifyDelegate(newString: textObject.string)
            self.lastValidValue = textObject.string
            return true
        }
        else {
            textObject.string = self.lastValidValue
            return false
        }
    }
    
    
}
