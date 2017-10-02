//
//  SettingsController.swift
//  ContactSheetz
//
//  Created by James Hicklin on 2016-11-07.
//  Copyright © 2016 James Hicklin. All rights reserved.
//

import Cocoa

class SettingsController: NSViewController, ParameterAdjustorViewDelegate, NSWindowDelegate {
    
    @IBOutlet weak var parameterAdjustorView: BatchSettingsView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        parameterAdjustorView.delegate = self
        self.view.window?.delegate = self
    }
    
    override func viewWillAppear() {
        self.view.window?.title = "Preferences"
    }
    
    func valueForField(field: AnyObject?) -> AnyObject? {
        if let _field = field as? AdjustorViewTextField {
            return _field.stringValue as AnyObject
        }
        else if let _field = field as? NSPopUpButton {
            return _field.titleOfSelectedItem as AnyObject
        }
        else if let _field = field as? NSButton {
            return (_field.state == NSOnState ? true : false) as AnyObject
        }
        else if let _field = field as? NSColorWell {
            return _field.color.hexValue() as AnyObject
        }
        return nil
    }
    
    func keyForField(field: AnyObject?) -> String? {
        if let _field = field as? AdjustorViewTextField {
            switch _field {
            case parameterAdjustorView.horizontalPaddingField:
                return Constants.SettingsKeys.HorizontalPadding
            case parameterAdjustorView.verticalPaddingField:
                return Constants.SettingsKeys.VerticalPadding
            case parameterAdjustorView.columnsField:
                return Constants.SettingsKeys.NumberOfColumns
            case parameterAdjustorView.widthField:
                return Constants.SettingsKeys.ImageWidth
            case parameterAdjustorView.heightField:
                return Constants.SettingsKeys.ImageHeight
            default:
                return nil
            }
        }
        else if let _field = field as? NSPopUpButton {
            switch _field {
            case parameterAdjustorView.headerFontField:
                return Constants.SettingsKeys.HeaderFont
            case parameterAdjustorView.outputFormatSelector:
                return Constants.SettingsKeys.OutputFormat
            default:
                return nil
            }
        }
        else if let _field = field as? NSButton {
            switch _field {
            case parameterAdjustorView.headerTitleButton:
                return Constants.SettingsKeys.IncludeTitle
            case parameterAdjustorView.headerDurationButton:
                return Constants.SettingsKeys.IncludeDuration
            case parameterAdjustorView.headerCodecButton:
                return Constants.SettingsKeys.IncludeCodec
            case parameterAdjustorView.headerResolutionButton:
                return Constants.SettingsKeys.IncludeResolution
            case parameterAdjustorView.headerBitrateButton:
                return Constants.SettingsKeys.IncludeBitrate
            case parameterAdjustorView.headerSizeButton:
                return Constants.SettingsKeys.IncludeSize
            case parameterAdjustorView.keepTimestampsField:
                return Constants.SettingsKeys.IncludeTimestamps
            case parameterAdjustorView.maintainAspectRatioField:
                return Constants.SettingsKeys.MaintainAR
            default:
                return nil
            }
        }
        else if let _field = field as? NSColorWell {
            switch _field {
            case parameterAdjustorView.backgroundColorField:
                return Constants.SettingsKeys.BackgroundColor
            case parameterAdjustorView.headerTextColorField:
                return Constants.SettingsKeys.HeaderTextColor
            default:
                return nil
            }
        }
        return nil
    }
    
    func saveDefaults() {
        //NSLog("Saving the defaults")
        let inputs: [AnyObject] = [
             parameterAdjustorView.horizontalPaddingField,
             parameterAdjustorView.verticalPaddingField,
             parameterAdjustorView.columnsField,
             parameterAdjustorView.maintainAspectRatioField,
             parameterAdjustorView.widthField,
             parameterAdjustorView.heightField,
             parameterAdjustorView.keepTimestampsField,
             parameterAdjustorView.backgroundColorField,
             parameterAdjustorView.headerTextColorField,
             parameterAdjustorView.headerTitleButton,
             parameterAdjustorView.headerDurationButton,
             parameterAdjustorView.headerCodecButton,
             parameterAdjustorView.headerResolutionButton,
             parameterAdjustorView.headerBitrateButton,
             parameterAdjustorView.headerSizeButton,
             parameterAdjustorView.headerFontField,
             parameterAdjustorView.outputFormatSelector
        ]
        
        for field in inputs {
            guard let key = keyForField(field: field) else {
                continue
            }
            let value = valueForField(field: field)
            let defaults = UserDefaults.standard
            if let _v = value {
                defaults.setValue(_v, forKey: key)
            }
            else {
                defaults.removeObject(forKey: key)
            }
            
        }
        
    }
    
    func windowWillClose(_ notification: Notification) {
        saveDefaults()
    }
    
    func generatePushed() {}
    func inputButtonClicked(enabled: Bool, button: NSButton) {
        if button == parameterAdjustorView.maintainAspectRatioField {
            if (button.state == NSOnState) {
                parameterAdjustorView.heightField.isEnabled = false
            }
            else {
                parameterAdjustorView.heightField.isEnabled = true
            }
        }
    }
    
    func colorChanged(well: NSColorWell) {}
    func savePushed() {}
    
}
