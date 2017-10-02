//
//  ViewController.swift
//  ContactSheetz
//
//  Created by James Hicklin on 2016-10-01.
//  Copyright (c) 2016 James Hicklin. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController, FileDropViewDelegate {
    
    @IBOutlet weak var fileUploadButton: NSButton!
   
    @IBOutlet weak var fileNameLabel: NSTextField!
    @IBOutlet weak var fileDropView: FileDropView!
    @IBOutlet weak var nextButton: NSButton!
    @IBOutlet weak var numFrames: PositiveIntegerTextField!
    var currentFileName: String = ""
    
    var previewWindow: NSWindowController?
    var question_mark_image: NSImage?
    var checkmark_image: NSImage?
    var cross_image: NSImage?

    @IBOutlet weak var mainView: MainWindowView!
    //@IBOutlet weak var dragViewImage: NSImageView!
    
    @IBOutlet weak var numFramesTooltipView:
    TooltipImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        //dragViewImage.image = NSImage.init(named: "question_mark.png")!
        numFramesTooltipView.setTooltipValue(value: "The number of individual frames to use in the contact sheet")
        fileDropView.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear() {
        // nextButton.enabled = false
        //self.previewWindow?.window?.makeFirstResponder(nil)
        //NSApplication.shared().keyWindow?.makeFirstResponder(nil)
        //self.view.window?.makeFirstResponder(nil)
    }
    
    
    @IBAction func openFileDialog(_ sender: AnyObject) {
        let dialog = NSOpenPanel()
        dialog.title = "Choose a video file"
        dialog.allowedFileTypes = Constants.AcceptedFileTypes
        if (dialog.runModal() == NSModalResponseOK) {
            let result = dialog.url
            if let path = result?.path {
                currentFileName = path
                let url = URL.init(fileURLWithPath: currentFileName)
                fileNameLabel.stringValue = url.lastPathComponent
                fileDragged(withValidity: FileDropView.FileValidity.Valid)
                return
                //sleep(4)
            }
            fileDragged(withValidity: FileDropView.FileValidity.Invalid)
            return
        }
    }
    
    @IBAction func openPreview(_ sender: AnyObject) {
        if currentFileName != "" {
            // initialize the frame extractor and pass it into the preview view controller
            let sb = NSStoryboard(name: "Main", bundle: nil)
            if let _numFrames = Int(numFrames.stringValue), let vfe = VideoFrameExtractor(filePath: currentFileName, _numFrames: _numFrames), let vc = sb.instantiateController(withIdentifier: "ContactSheetViewController") as? ContactSheetViewController {
                
                if _numFrames <= 0 {
                    displayAlert(message: "You must specify more than 1 frame.", alertStyle: NSAlertStyle.critical)
                }
                else {
                    vc.vfe = vfe
                    vc.filePath = currentFileName
                    
                    var styleMask = NSWindowStyleMask.init(rawValue: NSWindowStyleMask.closable.rawValue)
                    styleMask.insert(.resizable)
                    styleMask.insert(.miniaturizable)
                    styleMask.insert(.titled)
                    
                    let window = NSWindow.init(contentRect: self.view.frame, styleMask: styleMask, backing: NSBackingStoreType.buffered, defer: true)
                    window.identifier = "PreviewWindow"
                    //window.delegate = vc
                    window.title = "Preview"
                    window.setFrameOrigin(NSPoint(x: self.view.window!.frame.origin.x, y: self.view.window!.frame.origin.y + 40))
                    //window.frame.origin.y = self.view.window!.frame.origin.y + 40
                    let windowController = NSWindowController.init(window: window)
                    
                    NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.closeModalRequest), name: NSNotification.Name.NSWindowWillClose, object: window)

                    windowController.contentViewController = vc
                    //tabbedController.contentViewController = pvc
                    previewWindow = windowController
                    previewWindow!.showWindow(self)
                    //window.makeKeyAndOrderFront(nil)
                    //window.level = Int(CGWindowLevelForKey(CGWindowLevelKey.modalPanelWindow))
                    if let parentVc = self.parent as? MainTabbedViewController {
                        parentVc.setViewEnabled(enabled: false)
                    }
                }
                
            }
            else {
                displayAlert(message: "An unknown error occured", alertStyle: NSAlertStyle.critical)
                return
            }
        } else {
            displayAlert(message: "You must select a file", alertStyle: NSAlertStyle.critical)
        }
            
    }
    
    
    func validFileDropped(withPath path: String) {
        currentFileName = path
        let url = URL.init(fileURLWithPath: currentFileName)
        //cell.textField?.stringValue = url.lastPathComponent
        fileNameLabel.stringValue = url.lastPathComponent
    }
    
    func fileDragged(withValidity valid: FileDropView.FileValidity) {
        if (valid == FileDropView.FileValidity.Unknown) {
            //dragViewImage.s
            //dragViewImage.image = NSImage.init(named: "question_mark.png")
        }
        else if (valid == FileDropView.FileValidity.Valid) {
            //dragViewImage.image = NSImage.init(named: "checkmark.png")
        }
        else if (valid == FileDropView.FileValidity.Invalid) {
            currentFileName = ""
            fileNameLabel.stringValue = currentFileName
            //dragViewImage.image = NSImage.init(named: "cross.png")
            displayAlert(message: "Only video files are allowed", alertStyle: NSAlertStyle.critical)
        }
    }
    
    func hasValidFile() -> Bool {
        return (currentFileName != "")
    }
    
    func closeModalRequest() {
        self.previewWindow = nil
        if let parentVc = self.parent as? MainTabbedViewController {
            parentVc.setViewEnabled(enabled: true)
        }
    }
    
    
    private
    
    func displayAlert(message: String, alertStyle: NSAlertStyle) {
        let alertSheet = NSAlert.init()
        alertSheet.alertStyle = alertStyle
        alertSheet.messageText = message
        alertSheet.beginSheetModal(for: self.view.window!)
    }
}

