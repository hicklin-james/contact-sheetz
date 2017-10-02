//
//  PreviewViewController.swift
//  ContactSheetz
//
//  Created by James Hicklin on 2016-10-04.
//  Copyright © 2016 James Hicklin. All rights reserved.
//

import Cocoa

@available(OSX 10.11, *)
class ContactSheetViewController: NSViewController, NSTextFieldDelegate, ParameterAdjustorViewDelegate, AdjustorViewTextFieldDelegate, NSDrawerDelegate {
    
    @IBOutlet weak var overlayFrameLabel: NSTextField!
    @IBOutlet weak var loadingOverlay: OverlayView!
    
    var vfe: VideoFrameExtractor!
    var selectedFileExt = "png"
    
    @IBOutlet weak var previewImage: NSImageView!
    @IBOutlet weak var scrollView: PreviewScrollView!
    
    var fileWidth: Int = 0
    var fileHeight: Int = 1
    var filePath: String!
    
    var videoInformation: [String : AnyObject?]?
    
    @IBOutlet weak var loadingBar: NSProgressIndicator!
    
    @IBOutlet weak var spinner: NSProgressIndicator!
    var imageSet: [FrameWrapper] = []
    
    var includeTimestamps = true
    //var includeHeader = true
    var headerItems: [String:Bool] = ["includeTitle": true,
                                      "includeCodec": true,
                                      "includeResolution": true,
                                      "includeSize": true,
                                      "includeDuration": true,
                                      "includeBitrate": true
                                      ]
    @IBOutlet weak var adjustorViewWrapper: NSView!
    var adjustorView: ParameterAdjustorView!
    
    @IBOutlet weak var settingsViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var settingsViewWidthConstraint: NSLayoutConstraint!
    var hiddenSettings: Bool = false
    @IBOutlet weak var previewPanelDisclosureButton: NSButton!
    @IBOutlet weak var settingsPanelDisclosureButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //previewImageWrapper.translatesAutoresizingMaskIntoConstraints = false
        scrollView.imageView = previewImage
        //scrollView.documentView = previewImageWrapper
        loadingOverlay.isHidden = true
        loadingOverlay.layer?.zPosition = 100
        loadingBar.controlTint = NSControlTint.clearControlTint
        
        self.setupNotificatioms()
        self.setupSettingsView()
        
        //if let parentVC = parent as? TabbedPreviewViewController, let _vfe = parentVC.vfe {
            
        //self.filePath = parentVC.filePath
        
        showLoadingOverlay(maxLoadingBarValue: vfe.numFrames * 2 + 4, label: "Generating Frames")
        startExtractingFrames(extractor: vfe)
        
    }
    
    func setupNotificatioms() {
        NotificationCenter.default.addObserver(self, selector: #selector(ContactSheetViewController.updateImageCollection), name: NSNotification.Name(rawValue: Constants.NotificationKeys.VideoFrameGenerated), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ContactSheetViewController.updateProgressFromContactSheetGeneration), name: NSNotification.Name(rawValue: Constants.NotificationKeys.ContactSheetProgress), object: nil)
    }
    
    func startExtractingFrames(extractor: VideoFrameExtractor) {
        // generate the frames in a background thread
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            let images = extractor.generateFrames()
            DispatchQueue.main.async {
                if let _images = images {
                    self.imageSet = _images
                }
                self.completedFrameCreation()
            }
        }
    }
    
    func setupSettingsView() {
        
        var nibObjects:NSArray = NSArray()
        Bundle.main.loadNibNamed("ParameterAdjustorView", owner: self, topLevelObjects: &nibObjects)
        for i in 0..<nibObjects.count {
            if let _adjustorView = nibObjects[i] as? ParameterAdjustorView {
                
                _adjustorView.frame = NSRect.init(x: 0, y: adjustorViewWrapper.frame.size.height, width: adjustorViewWrapper.frame.size.width, height: adjustorViewWrapper.frame.size.height)
                _adjustorView.needsDisplay = true
                
                _adjustorView.delegate = self
                
                setAdjustorViewFieldDelegates(av: _adjustorView)
                
                self.adjustorView = _adjustorView
                
                videoInformation = vfe.getVideoInformation()
                if let info = videoInformation {
                    setVideoInfo(info: info)
                    _adjustorView.performInitialDelegateSetters()
                }
                
                adjustorViewWrapper.addSubview(self.adjustorView)
                
                let c1 = NSLayoutConstraint.init(item: adjustorView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: adjustorViewWrapper, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0)
                let c2 = NSLayoutConstraint.init(item: adjustorView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: adjustorViewWrapper, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0)
                let c3 = NSLayoutConstraint.init(item: adjustorView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: adjustorViewWrapper, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0)
                let c4 = NSLayoutConstraint.init(item: adjustorView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: adjustorViewWrapper, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0)
                
                adjustorViewWrapper.addConstraints([c1,c2,c3,c4])
                
                //adjustorViewWrapper.addSubview(self.adjustorView)
                break
            }
        }
    }
    
    func setAdjustorViewFieldDelegates(av: ParameterAdjustorView) {
        av.horizontalPaddingField.adjustorViewDelegate = self
        av.verticalPaddingField.adjustorViewDelegate = self
        av.columnsField.adjustorViewDelegate = self
        av.widthField.adjustorViewDelegate = self
        av.heightField.adjustorViewDelegate = self
    }
    
    override func viewWillAppear() {
        //setupSettingsDrawer()
        //self.settingsDrawer.open()
        self.view.window?.delegate = scrollView
    }
    
    func setupSettingsDrawer() {
        let drawer = NSDrawer.init(contentSize: adjustorView.frame.size, preferredEdge: NSRectEdge.maxX)
        drawer.parentWindow = self.view.window
        drawer.delegate = self
        
        //drawer.contentSize = NSSize.init(width: adjustorView.frame.size.width, height: 380)
        drawer.minContentSize = NSSize.init(width: adjustorView.frame.size.width, height: adjustorView.frame.size.height)
        drawer.maxContentSize = NSSize.init(width: adjustorView.frame.size.width, height: adjustorView.frame.size.height)
        
        
        /**
        let c1 = NSLayoutConstraint.init(item: adjustorView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: drawer, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0)
        let c2 = NSLayoutConstraint.init(item: adjustorView, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: drawer, attribute: NSLayoutAttribute.left, multiplier: 1, constant: 0)
        let c3 = NSLayoutConstraint.init(item: adjustorView, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: drawer, attribute: NSLayoutAttribute.right, multiplier: 1, constant: 0)
        adjustorView.addConstraints([c1,c2,c3])
    **/
        drawer.contentView = adjustorView
        //self.settingsDrawer = drawer
    }
    
    func setVideoInfo(info: [String: AnyObject?]) {
        if let width = info["width"] as? Int {
            self.fileWidth = width
        }
        if let height = info["height"] as? Int {
            self.fileHeight = height
        }
    }
    
    @IBAction func toggleHiddenSettingsView(_ sender: Any) {
        NSAnimationContext.runAnimationGroup({_ in
            NSAnimationContext.current().duration = 0.3
            
            if (hiddenSettings) {
                settingsViewTrailingConstraint.animator().constant = 0
                previewPanelDisclosureButton.state = NSOffState
                previewPanelDisclosureButton.isHidden = true
                settingsPanelDisclosureButton.isHidden = false
            } else {
                settingsViewTrailingConstraint.animator().constant = -settingsViewWidthConstraint.constant
                settingsPanelDisclosureButton.state = NSOnState
                previewPanelDisclosureButton.isHidden = false
                settingsPanelDisclosureButton.isHidden = true
            }
            
            self.view.layout()
        }, completionHandler: {
            self.scrollView.display()
            self.scrollView.resizeScrollview(rect: self.scrollView.frame)
        })
        //self.scrollView.resizeScrollview(rect: self.scrollView.frame)
        hiddenSettings = !hiddenSettings
    }
    
    
    func completedFrameCreation() {
        /**
        DispatchQueue.main.async {
            self.hideLoadingOverlay()
        }
        **/
        self.overlayFrameLabel.stringValue = "Generating Preview"
        generateMontage()
    }
    
    @IBAction func cancelAction(_ sender: AnyObject) {
        self.dismissViewController(self)
    }
    
    
    func updateImageCollection(notification: NSNotification) {
        DispatchQueue.main.async {
            self.loadingBar.increment(by: 1)
        }
    }
    
    func updateProgressFromContactSheetGeneration(notification: NSNotification) {
        DispatchQueue.main.async {
            self.loadingBar.increment(by: 1)
        }
    }
    
    func textDidChangeInTextField(textField: AdjustorViewTextField, value: String?) {
        if let _value = value {
            setChangedParam(editor: textField, newVal: _value)            
        }
    }
    
    func hideLoadingOverlay() {
        self.loadingOverlay.isHidden = true
        self.adjustorView.allowMouseEvents = true
        self.loadingBar.doubleValue = 0
        //self.adjustorView.overlayView.isHidden = true
        self.previewPanelDisclosureButton.isEnabled = true
        self.settingsPanelDisclosureButton.isEnabled = true
        self.spinner.stopAnimation(self)
    }
    
    func showLoadingOverlay(maxLoadingBarValue: Int, label: String) {
        self.overlayFrameLabel.stringValue = label
        self.adjustorView.allowMouseEvents = false
        self.loadingBar.maxValue =  Double(maxLoadingBarValue)
        self.loadingOverlay.isHidden = false
        self.previewPanelDisclosureButton.isEnabled = false
        self.settingsPanelDisclosureButton.isEnabled = false
        //self.adjustorView.overlayView.isHidden = false
        self.spinner.startAnimation(self)
    }
    
    func generateMontage() {
        guard let colsVal = Int(self.adjustorView.columnsField.stringValue) else {
            return
        }
        let rows = imageSet.count / colsVal + ((imageSet.count % colsVal) > 0 ? 1 : 0)
        
        guard let horizontalPadding = Int(self.adjustorView.horizontalPaddingField.stringValue) else {
            return
        }
        
        guard let verticalPadding = Int(self.adjustorView.verticalPaddingField.stringValue) else {
            return
        }
        
        guard let width = Int(self.adjustorView.widthField.stringValue) else {
            return
        }
        guard let height = Int(self.adjustorView.heightField.stringValue) else {
            return
        }
        guard let headerFont = self.adjustorView.headerFontField.titleOfSelectedItem else {
            return
        }
        
        guard let contactSheetCreator = ContactSheetCreator.init(_horizontalPadding: CGFloat(horizontalPadding), _verticalPadding: CGFloat(verticalPadding), _rows: rows, _cols: colsVal, _images: imageSet, _width: width, _height: height, _filePath: self.filePath, _videoInfo: self.videoInformation, _headerInformation: headerItems, _includeTimestamps: includeTimestamps, _backgroundColor: self.adjustorView.backgroundColorField.color, _headerFont: headerFont, _headerTextColor: self.adjustorView.headerTextColorField.color) else {
            
            NSLog("Failed to initialize contact sheet creator")
            return
        }
        // generate contact sheet in background thread
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            guard let contactSheet = contactSheetCreator.generateContactSheet() else {
                NSLog("Failed to generate contact sheet")
                //self.dismissViewController(self)
                return
            }
            DispatchQueue.main.async {
                self.previewImage.image = contactSheet
                self.scrollView.initialWidth = contactSheet.size.width
                self.scrollView.initialHeight = contactSheet.size.height
                self.scrollView.display()
                self.scrollView.resizeScrollview(rect: self.scrollView.frame)

                self.hideLoadingOverlay()
            }
        }
    }
    
    func collectionView(_ collectionView: NSCollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> NSView {
        let a = NSView.init(frame: NSMakeRect(0, 0, 500, 100))
        return a
    }
    
    func getMaintainedARHeight(newWidth: Int) -> Int {
        let ar = Double(self.fileWidth) / Double(self.fileHeight)
        
        let individualHeight = Double(newWidth) / ar
        return Int(individualHeight)
    }
    
    func setChangedParam(editor: AdjustorViewTextField, newVal: String) {
        if editor == adjustorView.widthField {
            if adjustorView.maintainAspectRatioField.state == NSOnState {
                let adjustedHeight = getMaintainedARHeight(newWidth: Int(newVal)!)
                adjustorView.heightField.stringValue = String(adjustedHeight)
            }
        }
    }

    func inputButtonClicked(enabled: Bool, button: NSButton) {
        if button == adjustorView.maintainAspectRatioField {
            if enabled {
                adjustorView.heightField.isEnabled = false
                let h = getMaintainedARHeight(newWidth: Int(adjustorView.widthField.stringValue)!)
                adjustorView.heightField.stringValue = String(h)
            }
            else {
                adjustorView.heightField.isEnabled = true
            }
        }
        else if (String(describing: type(of: button)) == "GroupedHeaderButton") {
            if let id = button.identifier {
                headerItems[id] = (button.state == NSOnState)
            }
        }
//        else if button == adjustorView.keepHeaderField {
//            self.includeHeader = enabled
//        }
        else if button == adjustorView.keepTimestampsField {
            includeTimestamps = (button.state == NSOnState)
        }
    }
    
    func colorChanged(well: NSColorWell) {
        return
    }
    
    internal func savePushed() {
        if let win = self.view.window {
            let saveDialog = NSSavePanel()
            addSaveDialogAccessoryView(savePanel: saveDialog)
            saveDialog.title = "Save your contact sheet"
            saveDialog.allowedFileTypes = ["png", "jpg", "tiff", "bmp"]
            saveDialog.nameFieldStringValue = "Contact Sheet"
            saveDialog.beginSheetModal(for: win) {(result) -> Void in
                if (result == NSFileHandlingPanelOKButton) {
                    guard var r = saveDialog.url else {
                        NSLog("Path invalid")
                        return
                    }
                    r.deletePathExtension()
                    let rWithExt = r.path + "." + self.selectedFileExt
                    let fileUrl = URL.init(fileURLWithPath: rWithExt)
                    if let _image = self.previewImage.image {
                        switch self.selectedFileExt {
                        case "png":
                            ImageHelper.saveAsFormat(image: _image, path: fileUrl, format: NSPNGFileType)
                        case "jpg":
                            ImageHelper.saveAsFormat(image: _image, path: fileUrl, format: NSJPEGFileType)
                        case "tiff":
                            ImageHelper.saveAsFormat(image: _image, path: fileUrl, format: NSTIFFFileType)
                        case "bmp":
                            ImageHelper.saveAsFormat(image: _image, path: fileUrl, format: NSBMPFileType)
                        default:
                            return
                        }
                        
                    }
                }
            }
        }
    }
    
    func addSaveDialogAccessoryView(savePanel: NSSavePanel) {
        let buttonItems = ["PNG (*.png)", "JPEG (*.jpg)", "TIFF (*.tiff)", "BMP (*.bmp)"]
        let accessoryView = NSView.init(frame: NSRect.init(x: 0, y: 0, width: 200, height: 32))
        let label = NSTextField.init(frame: NSRect.init(x: 0, y: 0, width: 60, height: 22))
        label.isEditable = false
        label.stringValue = "Format:"
        label.isBordered = false
        label.isBezeled = false
        label.drawsBackground = false
        
        let popupButton = NSPopUpButton.init(frame: NSRect.init(x: 50, y: 2, width: 140, height: 22))
        popupButton.pullsDown = false
        
        popupButton.addItems(withTitles: buttonItems)
        popupButton.target = self
        popupButton.action = #selector(ContactSheetViewController.setFileFormat)
        
        accessoryView.addSubview(label)
        accessoryView.addSubview(popupButton)
        
        savePanel.accessoryView = accessoryView
    }
    
    func setFileFormat(_ sender: AnyObject) {
        if let button = sender as? NSPopUpButton {
            let selectedItemIndex = button.indexOfSelectedItem
            switch selectedItemIndex {
            case 0:
                self.selectedFileExt = "png"
            case 1:
                self.selectedFileExt = "jpg"
            case 2:
                self.selectedFileExt = "tiff"
            case 3:
                self.selectedFileExt = "bmp"
            default:
                NSLog("Nothing selected! How did that happen?!")
            }
        }
    }
    
    internal func generatePushed() {
        NSApplication.shared().keyWindow?.makeFirstResponder(nil)
        
//        if let textfield = fr as? AdjustorViewTextField {
//            NSLog("Found a text field that needs updating")
//            textfield.adjustorViewDelegate.textDidChangeInTextField(textField: textfield, value: textfield.stringValue)
//        }
        let numFrames = vfe.numFrames
        showLoadingOverlay(maxLoadingBarValue: numFrames + 4, label: "Generating Preview")
        generateMontage()
    }
}
