//
//  PreviewViewController.swift
//  ContactSheetz
//
//  Created by James Hicklin on 2016-10-04.
//  Copyright © 2016 James Hicklin. All rights reserved.
//

import Cocoa

@available(OSX 10.11, *)
class PreviewViewController: NSViewController, NSCollectionViewDataSource, ImageCollectionLayoutDelegate, NSTextFieldDelegate, ParameterAdjustorViewDelegate, AdjustorViewTextFieldDelegate, NSDrawerDelegate, NSCollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var clipView: ImageCollectionViewClip!
    @IBOutlet weak var imageCollectionView: NSCollectionView!
    @IBOutlet weak var layout: ImageCollectionLayout!
    
    @IBOutlet weak var imageCollectionViewHeader: ImageCollectionViewHeader!
    
    @IBOutlet weak var durationLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var resolutionLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var fileNameTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var codecLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var overlayFrameLabel: NSTextField!
    @IBOutlet weak var loadingOverlay: OverlayView!
    
    @IBOutlet weak var resolutionLabel: NSTextField!
    @IBOutlet weak var fileNameLabel: NSTextField!
    @IBOutlet weak var durationLabel: NSTextField!
    @IBOutlet weak var codecLabel: NSTextField!
    
    var settingsDrawer: NSDrawer!
    
    var fileWidth: Int = 0
    var fileHeight: Int = 1
    var filePath: String = ""
    
    var videoInformation: [String : AnyObject?]?
    
    @IBOutlet weak var loadingBar: NSProgressIndicator!
    var imageSet: [FrameWrapper] = []
    
    var includeTimestamps = true
    var includeHeader = true
    
    var adjustorView: ParameterAdjustorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /**
        loadingOverlay.isHidden = true
        loadingOverlay.layer?.zPosition = 100
        loadingBar.controlTint = NSControlTint.clearControlTint
        
        NSLog("This should never be opened")
        
        layout.imDelegate = self
        
        self.setupNotificatioms()
        self.setupSettingsOverlay()
        
        if let parentVC = parent as? TabbedPreviewViewController, let _vfe = parentVC.vfe {
            
            self.filePath = parentVC.filePath
            let filePathAsUrl = URL.init(fileURLWithPath: self.filePath)
            self.fileNameLabel.stringValue = filePathAsUrl.lastPathComponent
            
            showLoadingOverlay(maxLoadingBarValue: _vfe.numFrames, label: "Generating Frames")
            startExtractingFrames(extractor: _vfe)
        }
        **/
    }
    
    func setupNotificatioms() {
        NotificationCenter.default.addObserver(self, selector: #selector(PreviewViewController.updateImageCollection), name: NSNotification.Name(rawValue: Constants.NotificationKeys.VideoFrameGenerated), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(PreviewViewController.updateProgressFromContactSheetGeneration), name: NSNotification.Name(rawValue: Constants.NotificationKeys.ContactSheetProgress), object: nil)
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
    
    func setupSettingsOverlay() {
        
        var nibObjects:NSArray = NSArray()
        Bundle.main.loadNibNamed("ParameterAdjustorView", owner: self, topLevelObjects: &nibObjects)
        for i in 0..<nibObjects.count {
            if let _adjustorView = nibObjects[i] as? ParameterAdjustorView, let parentVC = parent as? TabbedPreviewViewController, let _vfe = parentVC.vfe {

                _adjustorView.frame = NSRect.init(x: 0, y: self.view.frame.size.height - _adjustorView.frame.size.height, width: _adjustorView.frame.size.width, height: _adjustorView.frame.size.height)
                _adjustorView.setNeedsDisplay(_adjustorView.frame)
                
                _adjustorView.delegate = self
            
                setAdjustorViewFieldDelegates(av: _adjustorView)
                
                self.adjustorView = _adjustorView
                
                videoInformation = _vfe.getVideoInformation()
                if let info = videoInformation {
                    setVideoInfo(info: info)
                    _adjustorView.performInitialDelegateSetters()
                }
                
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
        setupSettingsDrawer()
        self.settingsDrawer.open()
    }
    
    func setupSettingsDrawer() {
        let drawer = NSDrawer.init(contentSize: adjustorView.frame.size, preferredEdge: NSRectEdge.maxX)
        drawer.parentWindow = self.view.window
        drawer.delegate = self
        drawer.minContentSize = NSSize.init(width: adjustorView.frame.size.width, height: adjustorView.frame.size.height)
        drawer.maxContentSize = NSSize.init(width: adjustorView.frame.size.width, height: adjustorView.frame.size.height)
        drawer.contentView = adjustorView
        self.settingsDrawer = drawer
    }
    
    func setVideoInfo(info: [String: AnyObject?]) {
        if let res = info["resolution"] as? String {
            resolutionLabel.stringValue = "Resolution: " + res
            //adjustorView.videoResolutionLabel.stringValue = "Resolution: " + res
        }
        if let codec = info["codec"] as? String {
            codecLabel.stringValue = "Codec: " + codec
            //adjustorView.codecNameLabel.stringValue = "Codec: " + codec
        }
        if let duration = info["duration"] as? String {
            durationLabel.stringValue = "Duration: " + duration
            //adjustorView.videoLengthLabel.stringValue = "Duration: " + duration
        }
        if let width = info["width"] as? Int {
            self.fileWidth = width
        }
        if let height = info["height"] as? Int {
            self.fileHeight = height
        }
    }
    
    func completedFrameCreation() {
        DispatchQueue.main.async {
            self.imageCollectionView.reloadData()
            self.hideLoadingOverlay()
        }
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
    
    /**
     // CANT GET THIS TO WORK :( //
     
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> NSSize {
        NSLog("CALLED")
        return NSSize.init(width: self.view.frame.size.width, height: 100)
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, referenceSizeForFooterInSection section: Int) -> NSSize {
        NSLog("CALLED")
        return NSSize.init(width: self.view.frame.size.width, height: 0)
    }
    
    func collectionView(collectionView: NSCollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> NSView {
        NSLog("Am i ever called?")
        if kind == NSCollectionElementKindSectionHeader {
            let view = collectionView.makeSupplementaryView(ofKind: kind, withIdentifier: "ImageCollectionViewHeader", for: indexPath as IndexPath)
            return view
        }
        return NSView.init(frame: NSRect.init(x: 0, y: 0, width: 0, height: 0))
    }
    **/
    
    public func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = imageCollectionView.makeItem(withIdentifier: "ImageCollectionViewItem", for: indexPath) as! ImageCollectionViewItem
        
        item.customImageView.image = imageSet[indexPath.item].image
        
        if includeTimestamps {
            item.timestampLabel.stringValue = imageSet[indexPath.item].timestamp
        }
        else {
            item.timestampLabel.stringValue = ""
        }
        
        return item
    }
    
    func numberOfSectionsInCollectionView(collectionView: NSCollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageSet.count
    }
    
    internal func collectionView(collectionView: NSCollectionView, sizeForPhotoAtIndexPath indexPath: IndexPath) -> NSSize {
        
        return self.imageSet[indexPath.item].image.size
        
    }
    
    func textDidChangeInTextField(textField: AdjustorViewTextField, value: String?) {
        if let _value = value {
            setChangedParam(editor: textField, newVal: _value)
            self.layout.invalidateLayout()
            
        }
    }
    
    func hideLoadingOverlay() {
        self.loadingOverlay.isHidden = true
        self.adjustorView.allowMouseEvents = true
        self.loadingBar.doubleValue = 0
        //self.adjustorView.overlayView.isHidden = true
    }
    
    func showLoadingOverlay(maxLoadingBarValue: Int, label: String) {
        self.overlayFrameLabel.stringValue = label
        self.adjustorView.allowMouseEvents = false
        self.loadingBar.maxValue =  Double(maxLoadingBarValue)
        self.loadingOverlay.isHidden = false
        //self.adjustorView.overlayView.isHidden = false
    }
    
    func generateMontage() {
        guard let rows = self.layout.numberOfRows else {
            return
        }
        
        let numFrames = (parent as! TabbedPreviewViewController).vfe!.numFrames
        showLoadingOverlay(maxLoadingBarValue: numFrames + 4, label: "Generating Contact Sheet")
        
        guard let contactSheetCreator = ContactSheetCreator.init(_horizontalPadding: self.layout.horizontalPadding, _verticalPadding: self.layout.verticalPadding, _rows: rows, _cols: self.layout.numberOfColumns, _images: imageSet, _width: Int(self.adjustorView.widthField.stringValue)!, _height: Int(self.adjustorView.heightField.stringValue)!, _filePath: self.filePath, _videoInfo: self.videoInformation, _headerInformation: [:], _includeTimestamps: includeTimestamps, _backgroundColor: self.clipView.color, _headerFont: "", _headerTextColor: NSColor.black) else {
            
            NSLog("Failed to initialize contact sheet creator")
            return
        }
        // generate contact sheet in background thread
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            guard let contactSheet = contactSheetCreator.generateContactSheet() else {
                NSLog("Failed to generate contact sheet")
                return
            }
            DispatchQueue.main.async {
                self.hideLoadingOverlay()
                if let win = self.view.window {
                    // we now have the contact sheet as an nsimage - query the user to save it.
                    let saveDialog = NSSavePanel()
                    saveDialog.title = "Save your contact sheet"
                    saveDialog.allowedFileTypes = ["png", "jpg", "jpeg"]
                    saveDialog.nameFieldStringValue = "Contact Sheet.png"
                    saveDialog.beginSheetModal(for: win) {(result) -> Void in
                        if (result == NSFileHandlingPanelOKButton) {
                            let r = saveDialog.url
                            if let url = r {
                                let ext = url.pathExtension
                                switch ext {
                                case "png":
                                    self.saveAsPng(image: contactSheet, path: url)
                                case "jpg", "jpeg":
                                    self.saveAsJpg(image: contactSheet, path: url)
                                default:
                                    return
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func saveAsPng(image: NSImage, path: URL) {
        guard let cgImgRef = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return
        }
        let bmpImgRef = NSBitmapImageRep(cgImage: cgImgRef)
        let pngData = bmpImgRef.representation(using: NSBitmapImageFileType.PNG, properties: [:])!
        do {
            //let path = URL.init(fileURLWithPath: path)
            try pngData.write(to: path)
        } catch {
            NSLog("Couldnt save file")
        }
    }
    
    func saveAsJpg(image: NSImage, path: URL) {
        let reps = image.representations
        let compressionFactor = 1
        let imageProps = NSDictionary.init(object: compressionFactor, forKey: NSImageCompressionFactor as NSCopying)
        guard let bitmapData = NSBitmapImageRep.representationOfImageReps(in: reps, using: NSJPEGFileType, properties: imageProps as! [String : Any]) else {
            return
        }
        do {
            try bitmapData.write(to: path)
        } catch {
            NSLog("Couldn't save file")
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
    
    func redrawTimestamps() {
        for item in self.imageCollectionView.visibleItems() {
            if let _item = item as? ImageCollectionViewItem {
                _item.timestampLabel.stringValue = (self.includeTimestamps ? self.imageSet[(self.imageCollectionView.indexPath(for: _item)?.item)!].timestamp : "")
            }
        }
    }
    
    func setChangedParam(editor: AdjustorViewTextField, newVal: String) {
        if editor == adjustorView.horizontalPaddingField {
           // NSLog("Changing horizontal padding")
            self.layout.horizontalPadding = CGFloat(Int(newVal)!)
        }
        else if editor == adjustorView.verticalPaddingField {
            //NSLog("Changing vertical padding")
            self.layout.verticalPadding = CGFloat(Int(newVal)!)
        }
        else if editor == adjustorView.columnsField {
            //if Int(newVal)! < self.imageSet.count {
            self.layout.numberOfColumns = Int(newVal)!
            //}
            //else {
            //    self.layout.numberOfColumns = self.imageSet.count
            //}
        }
        else if editor == adjustorView.widthField {
            if adjustorView.maintainAspectRatioField.state == NSOnState {
                let adjustedHeight = getMaintainedARHeight(newWidth: Int(newVal)!)
                adjustorView.heightField.stringValue = String(adjustedHeight)
            }
        }
    }
    
    func colorChanged(well: NSColorWell) {
        clipView.color = well.color
        imageCollectionViewHeader.color = well.color
        clipView.needsDisplay = true
        imageCollectionViewHeader.needsDisplay = true
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
        //else if button == adjustorView.keepHeaderField {
            //NSAnimationContext.beginGrouping()
            //NSAnimationContext.current().duration = 0.3
            
//            if enabled {
//                self.includeHeader = true
//                NSAnimationContext.runAnimationGroup({ (context: NSAnimationContext!) -> Void in
//                    context.duration = 0.3
//                    self.setHeaderEnabled(animate: true)
//                })
//            }
//            else {
//                self.includeHeader = false
//                NSAnimationContext.runAnimationGroup({ (context: NSAnimationContext!) -> Void in
//                    context.duration = 0.3
//                    self.setHeaderDisabled(animate: true)
//                })
//            }
            
            //self.imageCollectionViewHeader.layout()
            //NSAnimationContext.endGrouping()
            
        //}
        else if button == adjustorView.keepTimestampsField {
            includeTimestamps = (button.state == NSOnState)
            self.redrawTimestamps()
        }
    }
    
    func setHeaderEnabled(animate: Bool) {
        if animate {
            self.headerViewHeightConstraint.animator().constant = 100
            self.fileNameTopConstraint.animator().constant = 9
            self.durationLabelTopConstraint.animator().constant = 77
            self.codecLabelTopConstraint.animator().constant = 59
            self.resolutionLabelTopConstraint.animator().constant = 41
        }
        else {
            self.headerViewHeightConstraint.constant = 100
            self.fileNameTopConstraint.constant = 9
            self.durationLabelTopConstraint.constant = 77
            self.codecLabelTopConstraint.constant = 59
            self.resolutionLabelTopConstraint.constant = 41
        }
    }
    
    func setHeaderDisabled(animate: Bool) {
        if animate {
            self.durationLabelTopConstraint.animator().constant = 0
            self.codecLabelTopConstraint.animator().constant = 0
            self.resolutionLabelTopConstraint.animator().constant = 0
            self.fileNameTopConstraint.animator().constant = 0
            self.headerViewHeightConstraint.animator().constant = 0
        }
        else {
            self.headerViewHeightConstraint.constant = 0
            self.fileNameTopConstraint.constant = 0
            self.durationLabelTopConstraint.constant = 0
            self.codecLabelTopConstraint.constant = 0
            self.resolutionLabelTopConstraint.constant = 0
        }
    }
    
    
    internal func generatePushed() {
        generateMontage()
    }
    
    internal func savePushed() {
        
    }
    
}
