//
//  AppDelegate.swift
//  ContactSheetz
//
//  Created by James Hicklin on 2016-10-01.
//  Copyright (c) 2016 James Hicklin. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        MagickWandGenesis()
        av_register_all()
        
        //let fontFamilyNames = NSFontManager.shared().availableFontFamilies
        //print("available fonts is \(fontFamilyNames)")
        
        UserDefaults.standard.set(true, forKey: "NSConstraintBasedLayoutVisualizeMutuallyExclusiveConstraints")
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        MagickWandTerminus()
    }
    
    @IBAction func PreferencesButtonPushed(_ sender: Any) {
        let sb = NSStoryboard(name: "Main", bundle: nil)
        let preferencesView = sb.instantiateController(withIdentifier: "PreferencesView") as? NSViewController
        if let _prefsView = preferencesView {
            NSApp.keyWindow?.contentViewController?.presentViewControllerAsModalWindow(_prefsView)
        }
    }

    override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        if menuItem.title == "Preferences…" {
            return true
        }
        return false
    }
    
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        //let windows = sender.windows
        if let window = sender.windows.first {
            if flag {
                let openWindows = NSApplication.shared().windows
                if let _previewWindow = openWindows.first(where: { $0.identifier == "PreviewWindow" }) {
                    _previewWindow.orderFront(nil)
                } else {
                    window.orderFront(nil)
                }
            } else {
                window.makeKeyAndOrderFront(nil)
            }
            //if let vc = window.contentViewController
        }
        return true
    }


}

