//
//  ParameterAdjustorView.swift
//  ContactSheetz
//
//  Created by James Hicklin on 2016-10-07.
//  Copyright © 2016 James Hicklin. All rights reserved.
//

import Cocoa

protocol ParameterAdjustorViewDelegate {
    func generatePushed()
    func inputButtonClicked(enabled: Bool, button: NSButton)
    func colorChanged(well: NSColorWell)
    func savePushed()
}

class ParameterAdjustorView: NSView {
    
    @IBOutlet weak var draggerView: ParameterAdjustorDraggerView!
    
    // input fields
    @IBOutlet weak var horizontalPaddingField: AdjustorViewTextField!
    @IBOutlet weak var saveButton: NSButton!
    @IBOutlet weak var verticalPaddingField: AdjustorViewTextField!
    @IBOutlet weak var columnsField: AdjustorViewTextField!
    @IBOutlet weak var maintainAspectRatioField: NSButton!
    @IBOutlet weak var widthField: AdjustorViewTextField!
    @IBOutlet weak var heightField: AdjustorViewTextField!
    @IBOutlet weak var backgroundColorField: NSColorWell!
    //@IBOutlet weak var videoLengthLabel: NSTextField!
    @IBOutlet weak var headerFontField: NSPopUpButton!
    @IBOutlet weak var keepTimestampsField: NSButton!
    @IBOutlet weak var headerTextColorField: NSColorWell!
    
    // Tooltips
    @IBOutlet weak var horizontalPaddingTooltipView: TooltipImageView!
    @IBOutlet weak var verticalPaddingTooltipView: TooltipImageView!
    @IBOutlet weak var columnsTooltipView: TooltipImageView!
    @IBOutlet weak var backgroundColorTooltipView: TooltipImageView!
    @IBOutlet weak var headerFieldsTooltipView: TooltipImageView!
    @IBOutlet weak var timestampsTooltipView: TooltipImageView!
    @IBOutlet weak var headerFontTooltipView: TooltipImageView!
    @IBOutlet weak var headerTextColorTooltipView: TooltipImageView!
    @IBOutlet weak var heightPerImageTooltipView: TooltipImageView!
    @IBOutlet weak var widthPerImageTooltipView: TooltipImageView!
    @IBOutlet weak var aspectRatioTooltipView: TooltipImageView!
    
    // Header view buttons
    @IBOutlet weak var headerTitleButton: GroupedHeaderButton!
    @IBOutlet weak var headerDurationButton: GroupedHeaderButton!
    @IBOutlet weak var headerCodecButton: GroupedHeaderButton!
    @IBOutlet weak var headerResolutionButton: GroupedHeaderButton!
    @IBOutlet weak var headerBitrateButton: GroupedHeaderButton!
    @IBOutlet weak var headerSizeButton: GroupedHeaderButton!
    
    
    var allowMouseEvents: Bool = true
    
    var delegate: ParameterAdjustorViewDelegate!
    
    /**
    override var wantsUpdateLayer: Bool  {
        return true
    }
 **/
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        NSColor.darkGray.setFill()
        dirtyRect.fill()
        //NSColor.gray.set()
        //let path = NSBezierPath.init(rect: dirtyRect)
        //path.lineWidth = 1.0
        //path.stroke()
    }
    
    override func hitTest(_ point: NSPoint) -> NSView? {
        if (!allowMouseEvents) {
            return nil
        }
        else {
            return super.hitTest(point)
        }
    }
    
    override func awakeFromNib() {
        self.translatesAutoresizingMaskIntoConstraints = false
        initializeDropdowns()
        initializeDefaultsValues()
        setupTooltips()
    }
    
//    func toggleOverlay() {
//        self.overlayView.isHidden = !self.overlayView.isHidden
//    }
    
    func initializeDropdowns() {
        headerFontField.addItems(withTitles: NSFontManager.shared.availableFontFamilies)
    }
    
    func performInitialDelegateSetters() {
        horizontalPaddingField.adjustorViewDelegate.textDidChangeInTextField(textField: horizontalPaddingField, value: horizontalPaddingField.stringValue)
        verticalPaddingField.adjustorViewDelegate.textDidChangeInTextField(textField: verticalPaddingField, value: verticalPaddingField.stringValue)
        columnsField.adjustorViewDelegate.textDidChangeInTextField(textField: columnsField, value: columnsField.stringValue)
        widthField.adjustorViewDelegate.textDidChangeInTextField(textField: widthField, value: widthField.stringValue)
        
        // header buttons
        delegate.inputButtonClicked(enabled: (headerTitleButton.state == NSControl.StateValue.on ? true : false), button: headerTitleButton)
        delegate.inputButtonClicked(enabled: (headerDurationButton.state == NSControl.StateValue.on ? true : false), button: headerDurationButton)
        delegate.inputButtonClicked(enabled: (headerCodecButton.state == NSControl.StateValue.on ? true : false), button: headerCodecButton)
        delegate.inputButtonClicked(enabled: (headerResolutionButton.state == NSControl.StateValue.on ? true : false), button: headerResolutionButton)
        delegate.inputButtonClicked(enabled: (headerBitrateButton.state == NSControl.StateValue.on ? true : false), button: headerBitrateButton)
        delegate.inputButtonClicked(enabled: (headerSizeButton.state == NSControl.StateValue.on ? true : false), button: headerSizeButton)
        
        delegate.inputButtonClicked(enabled: (keepTimestampsField.state == NSControl.StateValue.on ? true : false), button: keepTimestampsField)
        delegate.inputButtonClicked(enabled: (maintainAspectRatioField.state == NSControl.StateValue.on ? true : false), button: maintainAspectRatioField)
        delegate.colorChanged(well: backgroundColorField)
        delegate.colorChanged(well: headerTextColorField)
        
        if maintainAspectRatioField.state == NSControl.StateValue.off {
            heightField.adjustorViewDelegate.textDidChangeInTextField(textField: heightField, value: heightField.stringValue)
        }
        
        
    }
    
    // Sets values from UserDefaults or system defaults depending on which is available
    func initializeDefaultsValues() {
        let defaults = UserDefaults.standard
        if let value = defaults.value(forKey: Constants.SettingsKeys.HorizontalPadding) as? String {
            horizontalPaddingField.stringValue = value
        }
        else {
            horizontalPaddingField.stringValue = String(Constants.DefaultValuesForParameters.HorizontalPadding)
        }
        
        if let value = defaults.value(forKey: Constants.SettingsKeys.VerticalPadding) as? String {
            verticalPaddingField.stringValue = value
        }
        else {
            verticalPaddingField.stringValue = String(Constants.DefaultValuesForParameters.VerticalPadding)
        }
        
        if let value = defaults.value(forKey: Constants.SettingsKeys.NumberOfColumns) as? String {
            columnsField.stringValue = value
        }
        else {
            columnsField.stringValue = String(Constants.DefaultValuesForParameters.NumberOfColumns)
        }
        
        if let value = defaults.value(forKey: Constants.SettingsKeys.ImageWidth) as? String {
            widthField.stringValue = value
        }
        else {
            widthField.stringValue = String(Constants.DefaultValuesForParameters.ImageWidth)
        }
        
        if let value = defaults.value(forKey: Constants.SettingsKeys.ImageHeight) as? String {
            heightField.stringValue = value
        }
        
//        if let value = defaults.value(forKey: Constants.SettingsKeys.IncludeHeader) as? Bool {
//            keepHeaderField.state = (value == true ? NSOnState : NSOffState)
//        }
//        else {
//            keepHeaderField.state = Constants.DefaultValuesForParameters.IncludeHeader
//        }
        
        if let value = defaults.value(forKey: Constants.SettingsKeys.HeaderFont) as? String {
            headerFontField.setTitle(value)
        }
        else {
            headerFontField.setTitle(String(Constants.DefaultValuesForParameters.HeaderFont))
        }
        
        if let value = defaults.value(forKey: Constants.SettingsKeys.IncludeTimestamps) as? Bool {
            keepTimestampsField.state = (value == true ? NSControl.StateValue.on : NSControl.StateValue.off)
        }
        else {
            keepTimestampsField.state = Constants.DefaultValuesForParameters.IncludeTimestamps
        }
        
        if let value = defaults.value(forKey: Constants.SettingsKeys.IncludeTitle) as? Bool {
            headerTitleButton.state = (value == true ? NSControl.StateValue.on : NSControl.StateValue.off)
        }
        else {
            headerTitleButton.state = Constants.DefaultValuesForParameters.IncludeTitle
        }
        
        if let value = defaults.value(forKey: Constants.SettingsKeys.IncludeDuration) as? Bool {
            headerDurationButton.state = (value == true ? NSControl.StateValue.on : NSControl.StateValue.off)
        }
        else {
            headerDurationButton.state = Constants.DefaultValuesForParameters.IncludeDuration
        }
        
        if let value = defaults.value(forKey: Constants.SettingsKeys.IncludeResolution) as? Bool {
            headerResolutionButton.state = (value == true ? NSControl.StateValue.on : NSControl.StateValue.off)
        }
        else {
            headerResolutionButton.state = Constants.DefaultValuesForParameters.IncludeResolution
        }
        
        if let value = defaults.value(forKey: Constants.SettingsKeys.IncludeCodec) as? Bool {
            headerCodecButton.state = (value == true ? NSControl.StateValue.on : NSControl.StateValue.off)
        }
        else {
            headerCodecButton.state = Constants.DefaultValuesForParameters.IncludeCodec
        }
        
        if let value = defaults.value(forKey: Constants.SettingsKeys.IncludeBitrate) as? Bool {
            headerBitrateButton.state = (value == true ? NSControl.StateValue.on : NSControl.StateValue.off)
        }
        else {
            headerBitrateButton.state = Constants.DefaultValuesForParameters.IncludeBitrate
        }
        
        if let value = defaults.value(forKey: Constants.SettingsKeys.IncludeSize) as? Bool {
            headerSizeButton.state = (value == true ? NSControl.StateValue.on : NSControl.StateValue.off)
        }
        else {
            headerSizeButton.state = Constants.DefaultValuesForParameters.IncludeSize
        }
        
        if let value = defaults.value(forKey: Constants.SettingsKeys.MaintainAR) as? Bool {
            maintainAspectRatioField.state = (value == true ? NSControl.StateValue.on : NSControl.StateValue.off)
            heightField.isEnabled = !value
        }
        else {
            maintainAspectRatioField.state = Constants.DefaultValuesForParameters.MaintainAR
            heightField.isEnabled = false
        }
        
        if let value = defaults.value(forKey: Constants.SettingsKeys.BackgroundColor) as? String {
            if let color = NSColor.colorFromHexString(hexString: value) {
                backgroundColorField.color = color
            }
            else {
                backgroundColorField.color = Constants.DefaultValuesForParameters.BackgroundColor
            }
        }
        else {
            backgroundColorField.color = Constants.DefaultValuesForParameters.BackgroundColor
        }
        
        if let value = defaults.value(forKey: Constants.SettingsKeys.HeaderTextColor) as? String {
            if let color = NSColor.colorFromHexString(hexString: value) {
                headerTextColorField.color = color
            }
            else {
                headerTextColorField.color = Constants.DefaultValuesForParameters.HeaderTextColor
            }
        }
        else {
            headerTextColorField.color = Constants.DefaultValuesForParameters.HeaderTextColor
        }
    }
    
    func setupTooltips() {
        horizontalPaddingTooltipView.setTooltipValue(value: "The amount of horizontal padding (in pixels) between each image in your contact sheet")
        verticalPaddingTooltipView.setTooltipValue(value: "The amount of vertical padding (in pixels) between each image in your contact sheet")
        columnsTooltipView.setTooltipValue(value: "The number of columns in your contact sheet")
        backgroundColorTooltipView.setTooltipValue(value: "The background color of your contact sheet")
        headerFieldsTooltipView.setTooltipValue(value: "Which fields you would like to include in the header of your contact sheet")
        timestampsTooltipView.setTooltipValue(value: "Include timestamps on individual frames in your contact sheet")
        headerFontTooltipView.setTooltipValue(value: "The font style of the text in the header of your contact sheet")
        headerTextColorTooltipView.setTooltipValue(value: "The color of the text in the header of your contact sheet")
        aspectRatioTooltipView.setTooltipValue(value: "Keep the aspect ratio of the input frames in your contact sheet")
        widthPerImageTooltipView.setTooltipValue(value: "The width of each individual frame in your contact sheet")
        heightPerImageTooltipView.setTooltipValue(value: "The height of each individual frame in your contact sheet")
    }

    @IBAction func generateCoverSheet(_ sender: AnyObject) {
        delegate.generatePushed()
    }
    
    @IBAction func aspectRatioButtonPushed(_ sender: AnyObject) {
        if let _button = sender as? NSButton {
            if maintainAspectRatioField.state == NSControl.StateValue.on {
                delegate.inputButtonClicked(enabled: true, button: _button)
            }
            else {
                delegate.inputButtonClicked(enabled: false, button: _button)
            }
        }
    }
    
    
    @IBAction func dropdownChanged(_ sender: Any) {
        NSLog("Dropdown value changed!")
    }
    
    @IBAction func saveImage(_ sender: Any) {
        delegate.savePushed()
    }
    
    @IBAction func includeTimestampsButtonPushed(_ sender: AnyObject) {
        if let _button = sender as? NSButton {
            if _button.state == NSControl.StateValue.on {
                delegate.inputButtonClicked(enabled: true, button: _button)
            }
            else {
                delegate.inputButtonClicked(enabled: false, button: _button)
            }
        }
    }
    
    @IBAction func headerItemButtonPushed(_ sender: AnyObject) {
        if let _button = sender as? NSButton {
            if _button.state == NSControl.StateValue.on {
                delegate.inputButtonClicked(enabled: true, button: _button)
            }
            else {
                delegate.inputButtonClicked(enabled: false, button: _button)
            }
        }
    }
    
    @IBAction func colorChanged(_ sender: Any) {
        if let _colorWell = sender as? NSColorWell {
            delegate.colorChanged(well: _colorWell)
        }
    }
    
    
    
}
