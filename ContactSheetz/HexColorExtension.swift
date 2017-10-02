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
        
        let rgbSpaceColor = self.usingColorSpaceName(NSCalibratedRGBColorSpace)
        
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
        var result: NSColor? = nil
        var colorCode: UInt32 = 0
        var redByte, greenByte, blueByte : UInt8
        
        //let stringWithoutHash = hexString.
        let index1 = hexString.index(hexString.startIndex, offsetBy: 1)
        let substring1 = hexString.substring(from: index1)
        
        let scanner = Scanner.init(string: substring1)
        let success = scanner.scanHexInt32(&colorCode)
        
        if success {
            redByte = UInt8.init(truncatingBitPattern: (colorCode >> 16))
            greenByte = UInt8.init(truncatingBitPattern: (colorCode >> 8))
            blueByte = UInt8.init(truncatingBitPattern: colorCode)
            
            result = NSColor(calibratedRed: CGFloat(redByte) / 0xff, green: CGFloat(greenByte) / 0xff, blue: CGFloat(blueByte) / 0xff, alpha: 1.0)
        }
        return result
    }
}
