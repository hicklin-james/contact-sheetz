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

    func application(_ application: NSApplication) -> Bool {
        // Insert code here to initialize your application
        if IsMagickWandInstantiated().rawValue == 0 {
            MagickWandGenesis()
        }
        
        UserDefaults.standard.set(true, forKey: "NSConstraintBasedLayoutVisualizeMutuallyExclusiveConstraints")
        
        return true
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        MagickWandTerminus()
    }
    
    @IBAction func PreferencesButtonPushed(_ sender: Any) {
        let sb = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
        let preferencesView = sb.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "PreferencesView")) as? NSViewController
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
                let openWindows = NSApplication.shared.windows
                if let _previewWindow = openWindows.first(where: { $0.identifier?.rawValue == "PreviewWindow" }) {
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

