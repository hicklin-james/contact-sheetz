//
//  MainTabbedViewController.swift
//  ContactSheetz
//
//  Created by James Hicklin on 2016-11-21.
//  Copyright © 2016 James Hicklin. All rights reserved.
//

import Cocoa

class MainTabbedViewController: NSTabViewController {
    
    var viewEnabled: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    func setViewEnabled(enabled: Bool) {
        viewEnabled = enabled
        setViewEnabledHelper(enabled: enabled, theView: self.view)
        let closeButton = self.view.window?.standardWindowButton(NSWindowButton.closeButton)
        let zoomButton = self.view.window?.standardWindowButton(NSWindowButton.zoomButton)
        let miniButton = self.view.window?.standardWindowButton(NSWindowButton.miniaturizeButton)
        if let _cb = closeButton {
            _cb.isEnabled = enabled
        }
        if let _zb = zoomButton {
            _zb.isEnabled = enabled
        }
        if let _mb = miniButton {
            _mb.isEnabled = enabled
        }
        
        /**
        setViewEnabledHelper(enabled: enabled, theView: self.tabView)
        
        for item in self.tabView.tabViewItems {
            if let _view = item.view {
                //setViewEnabledHelper(enabled: enabled, theView: _view)
                
                //_view.backgroundFilters = [CIFilt]
            }
        }
        **/
        
        //self.view.enabled = enabled
        //self.view.setNeedsDisplay(mainView.frame)
    }
    
    func setViewEnabledHelper(enabled: Bool, theView: NSView) {
        for v in theView.subviews {
            if let _view = v as? NSButton {
                _view.isEnabled = enabled
            }
            if let _view = v as? NSTextField {
                _view.isEnabled = enabled
            }
            setViewEnabledHelper(enabled: enabled, theView: v)
        }
    }
    
    // DELEGATE METHODS
    override func tabView(_ tabView: NSTabView, shouldSelect tabViewItem: NSTabViewItem?) -> Bool {
        return viewEnabled
    }
    
}
