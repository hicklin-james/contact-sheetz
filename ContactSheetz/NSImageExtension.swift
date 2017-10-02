//
//  NSImageExtension.swift
//  ContactSheetz
//
//  Created by James Hicklin on 2017-09-07.
//  Copyright © 2017 James Hicklin. All rights reserved.
//

import Foundation
import Cocoa

extension CGImage {
    var isDark: Bool {
        get {
            guard let imageData = self.dataProvider?.data else { return false }
            guard let ptr = CFDataGetBytePtr(imageData) else { return false }
            let length = CFDataGetLength(imageData)
            let threshold = Int(Double(self.width * self.height) * 0.99)
            var darkPixels = 0
            for i in stride(from: 0, to: length, by: 4) {
                let r = ptr[i]
                let g = ptr[i + 1]
                let b = ptr[i + 2]
                let luminance = (0.299 * Double(r) + 0.587 * Double(g) + 0.114 * Double(b))
                if luminance < 50 {
                    darkPixels += 1
                    if darkPixels > threshold {
                        return true
                    }
                }
            }
            return false
        }
    }
}

extension NSImage {
    var isDark: Bool {
        get {
            var imageRect = NSMakeRect(0, 0, self.size.width, self.size.height)
            if let _cgImage = self.cgImage(forProposedRect: &imageRect, context: nil, hints: nil) {
                return _cgImage.isDark
            }
            return false
        }
    }
}
