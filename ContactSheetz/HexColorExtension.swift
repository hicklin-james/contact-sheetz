//
//  HexColorExtension.swift
//  ContactSheetz
//
//  Created by James Hicklin on 2016-11-08.
//  Copyright © 2016 James Hicklin. All rights reserved.
//

import Foundation
import Cocoa

extension NSColor {
    func hexValue() -> String? {
        var redFloat:CGFloat=0, greenFloat:CGFloat=0, blueFloat:CGFloat=0
        var redInt:Int, greenInt:Int, blueInt:Int
        var redHex:String, greenHex:String, blueHex:String
        
        let rgbSpaceColor = self.usingColorSpaceName(NSColorSpaceName.calibratedRGB)
        
        if let _rgbSpaceColor = rgbSpaceColor {
            _rgbSpaceColor.getRed(&redFloat, green: &greenFloat, blue: &blueFloat, alpha: nil)
            
            redInt = Int(redFloat * 255.99999)
            greenInt = Int(greenFloat * 255.99999)
            blueInt = Int(blueFloat * 255.99999)
            
            redHex = String.init(format: "%02x", redInt)
            greenHex = String.init(format: "%02x", greenInt)
            blueHex = String.init(format: "%02x", blueInt)
            
            return String.init(format: "#%@%@%@", redHex, greenHex, blueHex)
        }
        return nil
    }
    
    static func colorFromHexString(hexString: String) -> NSColor? {
        var cString:String = hexString.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

         if (cString.hasPrefix("#")) {
             cString.remove(at: cString.startIndex)
         }

         if ((cString.count) != 6) {
             return NSColor.gray
         }

         var rgbValue:UInt32 = 0
         Scanner(string: cString).scanHexInt32(&rgbValue)

         return NSColor(
             red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
             green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
             blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
             alpha: CGFloat(1.0)
         )
    }
}
