//
//  ContactSheetCreator.swift
//  ContactSheetz
//
//  Created by James Hicklin on 2016-10-26.
//  Copyright © 2016 James Hicklin. All rights reserved.
//

import Cocoa

class ContactSheetCreator: NSObject {
    
    enum ContactSheetGenerationError: Error {
        case badImageConversion
        case couldntReadImageBlob
        case montageWandError
    }
    
    let fontPointSize: Double
    let horizontalPadding: CGFloat
    let verticalPadding: CGFloat
    let rows: Int
    let cols: Int
    let images: [FrameWrapper]
    let width: CGFloat
    let height: CGFloat
    let file: URL?
    let videoInfo: [String : AnyObject?]?
    let headerInformation: [String : Bool]
    let includeTimestamps: Bool
    let backgroundColor: String
    let headerFont: String
    let headerTextColor: String
    
    let possibleHeaderItems: [String] = ["includeDuration", "includeCodec", "includeResolution", "includeBitrate", "includeSize"]
    
    var mainWand: OpaquePointer?

    init?(_horizontalPadding: CGFloat, _verticalPadding: CGFloat, _rows: Int, _cols: Int, _images: [FrameWrapper], _width: Int, _height: Int, _filePath: String, _videoInfo: [String : AnyObject?]?, _headerInformation: [String : Bool], _includeTimestamps: Bool, _backgroundColor: NSColor, _headerFont: String, _headerTextColor: NSColor) {
        horizontalPadding = _horizontalPadding
        verticalPadding = _verticalPadding
        rows = _rows
        cols = _cols
        images = _images
        width = CGFloat(_width)
        height = CGFloat(_height)
        fontPointSize = Double(width) / 20
        file = URL.init(fileURLWithPath: _filePath)
        videoInfo = _videoInfo
        headerInformation = _headerInformation
        includeTimestamps = _includeTimestamps
        headerFont = _headerFont
        if let bc = _backgroundColor.hexValue() {
            backgroundColor = bc
        }
        else {
            backgroundColor = Constants.DefaultValuesForParameters.BackgroundColor.hexValue()!
        }
        
        if let color = _headerTextColor.hexValue() {
            headerTextColor = color
        }
        else {
            headerTextColor = Constants.DefaultValuesForParameters.HeaderTextColor.hexValue()!
        }
        //NSLog("Initializing")
        mainWand = NewMagickWand()
    }
    
    deinit {
        DestroyMagickWand(mainWand)
        //NSLog("Deinitializing")
    }
    
    func generateContactSheet() -> NSImage? {
        
        do {
            let drawingWand = createDrawingWand()
            let mainPixelWand = NewPixelWand()
            try getImageInfo()
            let geometryString = String(cols) + "x" + String(rows) + "+0+0"
            let sizeString = createSizeString()
            let frameString = "0x0+0+0"
            let contactSheetWand = NewMagickWand()
            var montageWand: OpaquePointer?
            
            //throw ContactSheetGenerationError.couldntReadImageBlob
            
            // defer will only do this after leaving scope
            defer {
                DestroyDrawingWand(drawingWand)
                DestroyMagickWand(montageWand)
                DestroyPixelWand(mainPixelWand)
                DestroyMagickWand(contactSheetWand)
                //for var item in imageInfo {
                //    DestroyImageInfo(item)
                //}
            }
            
            PixelSetColor(mainPixelWand, backgroundColor)
            MagickSetBackgroundColor(mainWand, mainPixelWand)
            
            //NSLog("First slowdown")
            montageWand = MagickMontageImage(mainWand, drawingWand, geometryString, sizeString, UnframeMode, frameString)
            //NSLog("Finished first slowdown")
            NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NotificationKeys.ContactSheetProgress), object: self, userInfo: nil)
            
            if (checkMagickWandError(wand: mainWand) != UndefinedException || checkMagickWandError(wand: montageWand) != UndefinedException) {
                throw ContactSheetGenerationError.montageWandError
            }
            
            // THIS IS IMPORTANT - CRASHES OTHERWISE
            MagickSetFormat(contactSheetWand, "tiff")
            MagickAddImage(contactSheetWand, montageWand)
            MagickSetImageFormat(contactSheetWand, "RGB")
            MagickSetImageDepth(contactSheetWand, 8)
            
            if self.includeTimestamps {
                self.drawLabels(magickWand: contactSheetWand)
            }
            
            self.drawHeaderInfo(magickWand: contactSheetWand)
//            if self.includeHeader {
//                self.drawTitle(magickWand: contactSheetWand)
//            }
            
            //MagickSetImageColor(contactSheetWand, mainPixelWand)
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NotificationKeys.ContactSheetProgress), object: self, userInfo: nil)
            
            var contactSheetInt = 0
            //NSLog("Or is it here?")
            //MagickQuantizeImages(contactSheetWand, 256, RGBColorspace, 4, NoDitherMethod, MagickFalse)
            //MagickSetImageFormat(contactSheetWand, "png")
            //NSLog("Second slowdown")
            let contactSheetImageBlob = MagickGetImageBlob(contactSheetWand, &contactSheetInt)
            //NSLog("Finished second slowdown")
            NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NotificationKeys.ContactSheetProgress), object: self, userInfo: nil)
            
            //NSLog("Third slowdown")
            let contactSheet = NSImage.init(data: Data.init(bytes: contactSheetImageBlob!, count: contactSheetInt))
            //NSLog("Finished third slowdown")
            NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NotificationKeys.ContactSheetProgress), object: self, userInfo: nil)
            
            MagickRelinquishMemory(contactSheetImageBlob)
            
            return contactSheet
            
        } catch ContactSheetGenerationError.badImageConversion {
            NSLog("Bad image conversion")
            fatalError("Bad image conversion")
            //NSLog("Bad image conversion")
        } catch ContactSheetGenerationError.couldntReadImageBlob {
            NSLog("Couldnt read image blob")
            fatalError("Couldnt read image blob")
            //NSLog("Couldnt read image blob")
        } catch ContactSheetGenerationError.montageWandError {
            NSLog("Montage wand error")
            fatalError("Montage wand error")
            //NSLog("Montage wand error")
        } catch {
            NSLog("An unknown error occured")
            fatalError("An unknown error occured")
            //NSLog("An unknown error occured")
        }
        
        return nil
    }
    
    func getPathFromFontName(name: String) -> String? {
        let fontRef: CTFontDescriptor = CTFontDescriptorCreateWithNameAndSize(name as CFString, 12.0)
        let url = CTFontDescriptorCopyAttribute(fontRef, kCTFontURLAttribute) as! CFURL
        let fontPath = (url as NSURL).path
        return fontPath
        
        //return nil
    }
    
    func drawHeaderInfo(magickWand: OpaquePointer?) {
        var xPos: Double = 0.0
        var yPos: Double = 0.0
        
        let pw = NewPixelWand()
        let wand = createDrawingWand()
        
        var spliceHeight = 0.0
        
        PixelSetColor(pw, headerTextColor)
        DrawSetFillColor(wand, pw)
        
        let titleFontSize = fontPointSize * 1.5
        
        var r: (Int, String) = (0, "")
        
        if let fontPath = getPathFromFontName(name: headerFont) {
            DrawSetFont(wand, fontPath)
        }
        
        if let b = headerInformation["includeTitle"] {
            if (b) {
                DrawSetFontSize(wand, titleFontSize)
                DrawSetTextAlignment(wand, CenterAlign)
                
                let titlemetrics = MagickQueryFontMetrics(magickWand, wand, "test string")
                let titleLineHeight = titlemetrics!.advanced(by: 5).pointee
                
                xPos = ((Double(width) * Double(cols)) + (Double(cols) * Double(horizontalPadding))) / 2.0
                yPos = titleFontSize
                if let _file = self.file {
                    let fileName = _file.lastPathComponent
                    r = adjustTextForWidth(wand: magickWand, drawingWand: wand, text: fileName)
                    DrawAnnotation(wand, xPos, yPos, r.1)
                    yPos = yPos + (titleLineHeight * Double(r.0))
                }

            }
        }
        DrawSetFontSize(wand, fontPointSize)
        DrawSetTextAlignment(wand, LeftAlign)
        
        let textmetrics = MagickQueryFontMetrics(magickWand, wand, "test string")
        let textHeight = textmetrics!.advanced(by: 5).pointee
        
        if (yPos == 0.0) {
            yPos = yPos + textHeight
        }
        xPos = Double(width) / 60.0
        
        for headerItemKey in possibleHeaderItems {
            if let b = headerInformation[headerItemKey] {
                if (b) {
                    let infoKey = headerItemKey.replace(target: "include", withString: "")
                    if let info = videoInfo, let str = info[infoKey.lowercased()] as? String {
                        //spliceHeight = spliceHeight + Double(textHeight)
                        //NSLog("Drawing - " + str)
                        DrawAnnotation(wand, xPos, yPos, infoKey + ": " + str)
                        yPos = yPos + textHeight                
                    }
                }
            }
        }
        
        spliceHeight = yPos - (textHeight / 2)
        /**
        if let info = videoInfo {
            if let res = info["resolution"] as? String {
                DrawAnnotation(wand, xPos, yPos, "Resolution: " + res)
                yPos = yPos + titleFontSize
            }
            if let codec = info["codec"] as? String {
                DrawAnnotation(wand, xPos, yPos, "Codec: " + codec)
                yPos = yPos + titleFontSize
            }
            if let dur = info["duration"] as? String {
                DrawAnnotation(wand, xPos, yPos, "Duration: " + dur)
                yPos = yPos + titleFontSize
            }
            if let fs = info["size"] as? String {
                DrawAnnotation(wand, xPos, yPos, "Size: " + fs)
            }
            if let br = info["bitrate"] as? String {
                DrawAnnotation(wand, xPos, yPos, "Bitrate: " + br)
            }
        }
        **/
        
        MagickSpliceImage(magickWand, 0, Int(spliceHeight), 0, 0)
        MagickDrawImage(magickWand, wand)
        
        DestroyPixelWand(pw)
        DestroyDrawingWand(wand)
    }
    
    func adjustTextForWidth(wand: OpaquePointer?, drawingWand: OpaquePointer?, text: String) -> (Int, String) {
        var textCopy = text
        var currTextWidth: Double = 0
        var totalLines = 1
        let totalwidth = ((Double(width) * Double(cols)) + (Double(cols) * Double(horizontalPadding)))
        let padding = totalwidth / 20
        var i = 0
        while i < textCopy.characters.count {
            let char = textCopy[textCopy.index(textCopy.startIndex, offsetBy: i)]
            //NSLog("Character: " + String(describing: char))
            let metrics = MagickQueryFontMetrics(wand, drawingWand, String(describing: char))
            if let _metrics = metrics {
                let characterWidth = _metrics.advanced(by: 4).pointee
                currTextWidth = currTextWidth + characterWidth
                if currTextWidth > (totalwidth - padding) {
                    // go back to the start of the word
                    var s = 0
                    var backChar = String(textCopy[textCopy.index(textCopy.startIndex, offsetBy: s)])
                    while i - s > 0 && backChar != " " {
                        backChar = String(textCopy[textCopy.index(textCopy.startIndex, offsetBy: i - s)])
                        //NSLog("Back Char: " + String(describing: backChar))
                        s = s + 1
                    }
                    
                    if i - s == 0 {
                        textCopy.insert("\n", at: textCopy.index(textCopy.startIndex, offsetBy: i))
                    }
                    else {
                        let insertIndex = i - s + 1
                        textCopy.insert("\n", at: textCopy.index(textCopy.startIndex, offsetBy: insertIndex))
                        i = i - s
                    }
                    currTextWidth = 0
                    totalLines = totalLines + 1
                }
            }
            i = i + 1
        }

        return (totalLines, textCopy)
    }
    
    func drawLabels(magickWand: OpaquePointer?) {
        let pw = NewPixelWand()
        let wand = createDrawingWand()
        
        DrawSetFontSize(wand, fontPointSize)
        DrawSetTextAlignment(wand, CenterAlign)
        
        PixelSetColor(pw, "white")
        DrawSetFillColor(wand, pw)
        
        for i in 0..<images.count {
            let img = images[i]
            let row = i / cols
            let col = i % cols
            let yOrigin = (Double(row) * Double(height)) + (Double(row) * Double(verticalPadding)) + Double(verticalPadding / CGFloat(2))
            let xOrigin = (Double(col) * Double(width)) + (Double(col) * Double(horizontalPadding)) + Double(horizontalPadding / CGFloat(2))
            
            let xPos = xOrigin + (Double(width) / 2)
            let yPos = yOrigin + Double(height) - (fontPointSize * 1.5)
            
            DrawAnnotation(wand, xPos, yPos, img.timestamp)
        }
        
        MagickDrawImage(magickWand, wand)
        
        DestroyDrawingWand(wand)
        DestroyPixelWand(pw)
    }
    
    func createDrawingWand() -> OpaquePointer? {
        let drawingWand = NewDrawingWand()
        let fontString = "/Library/Fonts/Arial Black.ttf"
        DrawSetFont(drawingWand, fontString)
        
        return drawingWand
    }
    
    func createSizeString() -> String {
        var size = String(Int(width)) + "x" + String(Int(height)) + "!+"
        size = size + String(Int(horizontalPadding / 2)) + "+" + String(Int(verticalPadding / 2))
        return size
    }
    
    func getImageInfo() throws {
        //var imageInfoArr: [UnsafeMutablePointer<ImageInfo>?] = []
        for i in 0..<images.count {
            guard let byteifiedImage = getPngByteDataFromImage(image: images[i].image) else {
                throw ContactSheetGenerationError.badImageConversion
            }
            
            let imageBytes = byteifiedImage.withUnsafeBytes {
                [Int8](UnsafeBufferPointer(start: $0, count: byteifiedImage.count))
            }
            let status = MagickReadImageBlob(mainWand, imageBytes, byteifiedImage.count)
            
            if (status == MagickFalse) {
                throw ContactSheetGenerationError.couldntReadImageBlob
            }
            MagickScaleImage(mainWand, Int(width), Int(height))
            MagickSetLastIterator(mainWand)
            //let imageInfo = AcquireImageInfo()
            //imageInfoArr.append(imageInfo)
            NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NotificationKeys.ContactSheetProgress), object: self, userInfo: nil)
        }
        //MagickSetFirstIterator(mainWand)
        //MagickQuantizeImages(mainWand, 256, RGBColorspace, 4, NoDitherMethod, MagickFalse)
        //return imageInfoArr
    }
    
    private
    
    func checkMagickWandError(wand: OpaquePointer?) -> ExceptionType {
        var et: ExceptionType = UndefinedException
        let cStr = MagickGetException(wand, &et)
        if let _cStr = cStr {
            let string = String.init(cString: _cStr)
            NSLog(string)
        } else {
            NSLog("cStr was nil!")
        }
        MagickClearException(wand)
        MagickRelinquishMemory(cStr)
        return et
    }
    
    func getPngByteDataFromImage(image: NSImage) -> Data? {
        let reps = image.representations
        let compressionFactor = 1
        let imageProps = NSDictionary.init(object: compressionFactor, forKey: NSImageCompressionFactor as NSCopying)
        return NSBitmapImageRep.representationOfImageReps(in: reps, using: NSPNGFileType, properties: imageProps as! [String : Any])
    }
    
}
