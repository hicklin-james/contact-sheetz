//
//  Constants.swift
//  ContactSheetz
//
//  Created by James Hicklin on 2016-11-08.
//  Copyright © 2016 James Hicklin. All rights reserved.
//

import Foundation
import Cocoa

struct Constants {
    struct NotificationKeys {
        static let VideoFrameGenerated = "com.contactsheetz.imageGeneratedNotificationKey"
        static let ContactSheetProgress = "com.contactsheets.contactSheetProgressKey"
    }
    
    static let AcceptedFileTypes = ["mkv", "mp4", "avi", "wmv", "flv", "mov", "asf", "qt", "swf", "mpg", "mpeg", "ogv", "m4v", "webm", "3gp"]
    
    struct SettingsKeys {
        static let HorizontalPadding = "horizontalPadding"
        static let VerticalPadding = "verticalPadding"
        static let NumberOfColumns = "numberOfCols"
        static let ImageWidth = "imageWidth"
        static let ImageHeight = "imageHeight"
        static let MaintainAR = "maintainAR"
        static let IncludeTimestamps = "includeTimestamps"
        static let BackgroundColor = "backgroundColor"
        static let IncludeTitle = "includeTitle"
        static let IncludeResolution = "includeResolution"
        static let IncludeCodec = "includeCodec"
        static let IncludeSize = "includeSize"
        static let IncludeBitrate = "includeBitrate"
        static let IncludeDuration = "includeDuration"
        static let HeaderFont = "headerFont"
        static let HeaderTextColor = "headerTextColor"
        static let OutputFormat = "outputFormat"
    }
    
    struct DefaultValuesForParameters {
        static let ImageWidth = 300
        static let MaintainAR = NSControl.StateValue.on
        static let HorizontalPadding = 2
        static let VerticalPadding = 2
        static let IncludeTimestamps = NSControl.StateValue.on
        static let IncludeTitle = NSControl.StateValue.on
        static let IncludeResolution = NSControl.StateValue.on
        static let IncludeCodec = NSControl.StateValue.on
        static let IncludeSize = NSControl.StateValue.on
        static let IncludeBitrate = NSControl.StateValue.on
        static let IncludeDuration = NSControl.StateValue.on
        static let NumberOfColumns = 3
        static let BackgroundColor = NSColor.white
        static let HeaderFont = "Arial"
        static let HeaderTextColor = NSColor.black
        static let OutputFormat = "PNG (*.png)"
    }
}
