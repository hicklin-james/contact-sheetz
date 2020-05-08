//
//  BatchTableViewController.swift
//  ContactSheetz
//
//  Created by James Hicklin on 2016-11-21.
//  Copyright © 2016 James Hicklin. All rights reserved.
//

import Cocoa

class BatchTableViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, BatchFileTableViewDelegate, BatchFileTableCellDelegate, BatchTableViewHeaderDelegate {
    
    var currentCell: BatchFileTableCellView?
    var modalViewController: NSViewController?
    
    var batchFiles: [String] = []
    var settingsView: BatchSettingsView?

    @IBOutlet weak var numFramesField: PositiveIntegerTextField!
    @IBOutlet weak var batchItemsTableView: BatchFileTableView!
    
    @IBOutlet weak var numFramesTooltipView: TooltipImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        numFramesTooltipView.setTooltipValue(value: "The number of individual frames to use in the contact sheets")
        
        NotificationCenter.default.addObserver(self, selector: #selector(BatchTableViewController.updateProgressFromFrameGeneration), name: NSNotification.Name(rawValue: Constants.NotificationKeys.VideoFrameGenerated), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(BatchTableViewController.updateProgressFromContactSheetGeneration), name: NSNotification.Name(rawValue: Constants.NotificationKeys.ContactSheetProgress), object: nil)

        batchItemsTableView.batchFileDelegate = self

        var nibObjects:NSArray? = NSArray()
        Bundle.main.loadNibNamed(NSNib.Name(rawValue: "BatchTableViewHeader"), owner: self, topLevelObjects: &nibObjects)
        if let _nibObjects = nibObjects {
            for i in 0..<_nibObjects.count {
                if let headerView = _nibObjects[i] as? BatchTableViewHeader {
                    headerView.delegate = self
                    batchItemsTableView.headerView = headerView
                    batchItemsTableView.headerView?.frame.size.height = 34
                }
            }
        }
    }
    
    // table view data source methods
    func numberOfRows(in tableView: NSTableView) -> Int {
        if batchFiles.count > 0 {
            return batchFiles.count
        }
        else {
            return 1
        }
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 54
    }
    
    // disable selection
    func selectionShouldChange(in tableView: NSTableView) -> Bool {
        return false
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if batchFiles.count > 0 {
            let cell = batchItemsTableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "BatchFileTableCell"), owner: self) as! BatchFileTableCellView
            cell.delegate = self
            if row % 2 != 0 {
                cell.isGrey = true
            }
            let url = URL.init(fileURLWithPath: batchFiles[row])
            cell.textField?.stringValue = url.lastPathComponent
            return cell
        }
        else {
            let cell = batchItemsTableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "NoFilesCell"), owner: self)
            return cell
        }
    }
    
    
    func addedFiles(files: [String]) {
        //NSLog("Adding files")
        // remove duplicates from files
        var filesWithoutDupes: [String] = []
        for f in files {
            if !batchFiles.contains(f) && !f.isEmpty {
                filesWithoutDupes.append(f)
            }
        }
        let indexRange = Range.init(uncheckedBounds: (lower: batchFiles.count, upper: batchFiles.count + filesWithoutDupes.count))
        let indexSet: IndexSet = IndexSet.init(integersIn: indexRange)
        // don't add duplicates
        if batchFiles.count == 0 && filesWithoutDupes.count > 0 {
            batchItemsTableView.removeRows(at: IndexSet.init(integer: 0), withAnimation: NSTableView.AnimationOptions.slideRight)
        }
        batchFiles += filesWithoutDupes
        batchItemsTableView.insertRows(at: indexSet, withAnimation: NSTableView.AnimationOptions.slideLeft)
        //batchItemsTableView.insertRows(at: indexSet, withAnimation: NSTableViewAnimation.)
    }
    
    func clearFilesButtonPushed() {
        if batchFiles.count > 0 {
            clearAllFiles()
        }
    }
    
    func addButtonPushed() {
        let dialog = NSOpenPanel()
        dialog.allowsMultipleSelection = true
        dialog.title = "Choose video files"
        dialog.allowedFileTypes = Constants.AcceptedFileTypes
        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            let result = dialog.urls
            let resultStrs = result.map({
                return $0.path
            })
           addedFiles(files: resultStrs)
            return
        }
    }
    
    func clearAllFiles() {
        //var indexRange = Range.init(uncheckedBounds: (lower: 0, upper: 0))
        let indexRange: Range<Int>
        if batchFiles.count > 0 {
            indexRange = Range.init(uncheckedBounds: (lower: 0, upper: batchFiles.count))
        }
        else {
            indexRange = Range.init(uncheckedBounds: (lower: 0, upper: 1))
        }
        let indexSet: IndexSet = IndexSet.init(integersIn: indexRange)
        for i in 0..<batchFiles.count {
            let cell = batchItemsTableView.view(atColumn: 0, row: i, makeIfNecessary: false)
            if let _cell = cell as? BatchFileTableCellView {
                _cell.resetCell()
            }
        }
        batchFiles = []
        batchItemsTableView.removeRows(at: indexSet, withAnimation: NSTableView.AnimationOptions.slideLeft)
        if batchFiles.count == 0 {
            batchItemsTableView.insertRows(at: IndexSet.init(integer: 0), withAnimation: NSTableView.AnimationOptions.slideLeft)
        }
    }
    
    // Cell delegate functions
    func removeCellRequested(from: BatchFileTableCellView) {
        let cellPoint = from.superview!.frame.origin
        let row = batchItemsTableView.row(at: cellPoint)
        let cell = batchItemsTableView.view(atColumn: 0, row: row, makeIfNecessary: false)
        if let _cell = cell as? BatchFileTableCellView {
            _cell.resetCell()
        }
        //NSLog("Deleting row: " + String(row))
        batchFiles.remove(at: row)
        let indexSet = IndexSet.init(integer: row)
        batchItemsTableView.removeRows(at: indexSet, withAnimation: NSTableView.AnimationOptions.slideLeft)
        if row != batchFiles.count {
            adjustRowColors(row: row, initialCell: from)
        }
        if batchFiles.count == 0 {
            batchItemsTableView.insertRows(at: IndexSet.init(integer: 0), withAnimation: NSTableView.AnimationOptions.slideLeft)
        }
    }
    
    func adjustRowColors(row: Int, initialCell: BatchFileTableCellView) {
        
        let visibleRect = batchItemsTableView.enclosingScrollView!.visibleRect
        let visibleRows = batchItemsTableView.rows(in: visibleRect)
        let range = Range.init(uncheckedBounds: (lower: row, upper: Range.init(visibleRows)!.upperBound))
        var c = initialCell.isGrey
        for r in range.lowerBound..<range.upperBound {
            let cell = batchItemsTableView.view(atColumn: 0, row: r, makeIfNecessary: false) as! BatchFileTableCellView
            cell.isGrey = c
            cell.needsDisplay = true
            c = !c
        }
    }
    
    @IBAction func openBatchProcessSettings(_ sender: Any) {
        guard let i = Int(self.numFramesField.stringValue), i > 0 else {
            displayAlert(message: "Must have one or more frames", alertStyle: NSAlert.Style.critical)
            return
        }
        guard batchFiles.count > 0 else {
            displayAlert(message: "Must have at least one file", alertStyle: NSAlert.Style.critical)
            return
        }
        var nibObjects:NSArray? = NSArray()
        Bundle.main.loadNibNamed(NSNib.Name(rawValue: "BatchSettingsView"), owner: self, topLevelObjects: &nibObjects)
        if let _nibObjects = nibObjects {
            for i in 0..<_nibObjects.count {
                if let _settingsView = _nibObjects[i] as? BatchSettingsView {
                    _settingsView.delegate = self
                    //_settingsView.toggleOverlay()
                    
                    let vc = NSViewController.init()
                    vc.view = _settingsView
                    self.presentViewControllerAsModalWindow(vc)
                    vc.view.window?.maxSize = NSSize.init(width: 310, height: 591)
                    vc.view.window?.minSize = NSSize.init(width: 310, height: 591)
                    let zoomButton = vc.view.window?.standardWindowButton(NSWindow.ButtonType.zoomButton)
                    if let _zb = zoomButton {
                        _zb.isEnabled = false
                    }
                    vc.view.window?.title = "Batch Settings"
                    self.settingsView = _settingsView
                    let heightConstraint = NSLayoutConstraint.init(item: _settingsView, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.greaterThanOrEqual, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 536)
                    _settingsView.addConstraint(heightConstraint)
                    self.modalViewController = vc
                }
            }
        }
    }
    
    func displayAlert(message: String, alertStyle: NSAlert.Style) {
        let alertSheet = NSAlert.init()
        alertSheet.alertStyle = alertStyle
        alertSheet.messageText = message
        alertSheet.beginSheetModal(for: self.view.window!) {(r: NSApplication.ModalResponse) in
            NSLog("Alert closed")
        }
    }
}

extension BatchTableViewController: ParameterAdjustorViewDelegate {
    
    @objc func updateProgressFromFrameGeneration(notification: NSNotification) {
        DispatchQueue.main.async {
            if let _vfe = notification.object as? VideoFrameExtractor, let rowIndex = self.batchFiles.index(of: _vfe.filePath) {
                if let viewCell = self.batchItemsTableView.view(atColumn: 0, row: rowIndex, makeIfNecessary: false) as? BatchFileTableCellView {
                    viewCell.incrementProgressBar(increment: Double(1))
                }
                
            }
        }
    }
    
    @objc func updateProgressFromContactSheetGeneration(notification: NSNotification) {
        DispatchQueue.main.async {
            if let _csc = notification.object as? ContactSheetCreator, let fileName = _csc.file?.path, let rowIndex = self.batchFiles.index(of: fileName) {
                if let viewCell = self.batchItemsTableView.view(atColumn: 0, row: rowIndex, makeIfNecessary: false) as? BatchFileTableCellView {
                    viewCell.incrementProgressBar(increment: Double(1))
                }
            }
        }
    }
    
    func setTableViewProgressBars(numFrames: Int) {
        for i in 0..<batchFiles.count {
            if let viewCell = batchItemsTableView.view(atColumn: 0, row: i, makeIfNecessary: true) as? BatchFileTableCellView {
                viewCell.initializeCompletionBar(maxLength: Double(numFrames * 2 + 4))
                viewCell.removeItemButton.isEnabled = false
                viewCell.statusLabel.isHidden = true
            }
        }
    }
    
    func setError(file: String, errorMessage: String) {
        DispatchQueue.main.async {
            if let rowIndex = self.batchFiles.index(of: file), let viewCell = self.batchItemsTableView.view(atColumn: 0, row: rowIndex, makeIfNecessary: false) as? BatchFileTableCellView {
                viewCell.statusLabel.isHidden = false
                viewCell.statusLabel.textColor = NSColor.init(red: 1, green: 0.839, blue: 0.863, alpha: 1)
                viewCell.statusLabel.stringValue = errorMessage
                viewCell.removeItemButton.isEnabled = true
            }
        }
    }
    
    func setSuccess(file: String) {
        DispatchQueue.main.async {
            if let rowIndex = self.batchFiles.index(of: file), let viewCell = self.batchItemsTableView.view(atColumn: 0, row: rowIndex, makeIfNecessary: false) as? BatchFileTableCellView {
                viewCell.statusLabel.isHidden = false
                viewCell.statusLabel.textColor = NSColor.init(red: 0.871, green: 1, blue: 0.878, alpha: 1)
                viewCell.statusLabel.stringValue = "Completed"
                viewCell.removeItemButton.isEnabled = true
            }
        }
    }
    
    func createContactSheetForFile(file: String, params: [String: AnyObject]) {
        let numFrames = params["numFrames"] as! Int
        let hPadding = params["hPadding"] as! CGFloat
        let vPadding = params["vPadding"] as! CGFloat
        let cols = params["cols"] as! Int
        let rows = params["rows"] as! Int
        let width = params["width"] as! Int
        var height = params["height"] as! Int
        //let includeHeader = params["includeHeader"] as! Bool
        let headerInfo = params["headerInformation"] as! [String : Bool]
        let includeTimestamps = params["includeTimestamps"] as! Bool
        let backgroundColor = params["backgroundColor"] as! NSColor
        let keepAr = params["keepAr"] as! Bool
        let headerFont = params["headerFont"] as! String
        let headerColor = params["headerColor"] as! NSColor
        
        var errorString = ""
        guard let vfe = VideoFrameExtractor(filePath: file, _numFrames: numFrames, errorString: &errorString) else {
            self.setError(file: file, errorMessage: errorString)
            return
        }
                
        guard let images = vfe.generateFrames() else {
            self.setError(file: file, errorMessage: "Unable to extract frames from file")
            return
        }
        let videoInfo = vfe.getVideoInformation()
        
        guard let _height = videoInfo?["height"] as? Int, let _width = videoInfo?["width"] as? Int else {
            self.setError(file: file, errorMessage: "Couldn't extract width and/or height from video file")
            return
            
        }
        if keepAr {
            let ar = Double(_width) / Double(_height)
            height = Int(Double(width) / ar)
        }
        
        guard let csc = ContactSheetCreator.init(_horizontalPadding: hPadding, _verticalPadding: vPadding, _rows: rows, _cols: cols, _images: images, _width: width, _height: height, _filePath: file, _videoInfo: videoInfo, _headerInformation: headerInfo, _includeTimestamps: includeTimestamps, _backgroundColor: backgroundColor, _headerFont: headerFont, _headerTextColor: headerColor) else {
            self.setError(file: file, errorMessage: "Couldn't initialize contact sheet creator")
            return
        }
        
        guard let image = csc.generateContactSheet() else {
            self.setError(file: file, errorMessage: "Couldn't create contact sheet")
            return
        }
        
        DispatchQueue.main.async {
            let fp = URL.init(fileURLWithPath: file)
            let fpNoExt = fp.deletingPathExtension()
            if let formatIndex = params["formatIndex"] as? Int {
                switch formatIndex {
                case 0:
                    let imURL = URL.init(fileURLWithPath: fpNoExt.path + " Contact Sheet.png")
                    ImageHelper.saveAsFormat(image: image, path: imURL, format: NSBitmapImageRep.FileType.png)
                    self.setSuccess(file: file)
                case 1:
                    let imURL = URL.init(fileURLWithPath: fpNoExt.path + " Contact Sheet.jpg")
                    ImageHelper.saveAsFormat(image: image, path: imURL, format: NSBitmapImageRep.FileType.jpeg)
                    self.setSuccess(file: file)
                case 2:
                    let imURL = URL.init(fileURLWithPath: fpNoExt.path + " Contact Sheet.tiff")
                    ImageHelper.saveAsFormat(image: image, path: imURL, format: NSBitmapImageRep.FileType.tiff)
                    self.setSuccess(file: file)
                case 3:
                    let imURL = URL.init(fileURLWithPath: fpNoExt.path + " Contact Sheet.bmp")
                    ImageHelper.saveAsFormat(image: image, path: imURL, format: NSBitmapImageRep.FileType.bmp)
                    self.setSuccess(file: file)
                default:
                    self.setError(file: file, errorMessage: "Something bad happened - no file format selected")
                }
            }
        }
    }

    func generatePushed() {
        NSApplication.shared.keyWindow?.makeFirstResponder(nil)
        if let _mc = self.modalViewController {
            self.dismissViewController(_mc)
        }
        
        if let _settingsView = self.settingsView {
            var params: [String: AnyObject] = Dictionary.init()
            let numFrames = Int(self.numFramesField.stringValue)!
            params["numFrames"] = numFrames as AnyObject?
            let hPadding = CGFloat(Int(_settingsView.horizontalPaddingField.stringValue)!)
            params["hPadding"] = hPadding as AnyObject?
            let vPadding = CGFloat(Int(_settingsView.verticalPaddingField.stringValue)!)
            params["vPadding"] = vPadding as AnyObject?
            let cols = Int(_settingsView.columnsField.stringValue)!
            params["cols"] = cols as AnyObject?
            let rows = numFrames / cols + ((numFrames % cols) > 0 ? 1 : 0)
            params["rows"] = rows as AnyObject?
            let width = Int(_settingsView.widthField.stringValue)!
            params["width"] = width as AnyObject?
            var height = 0
            if let a = Int(_settingsView.heightField.stringValue) {
                height = a
            }
            //let height = Int(_settingsView.heightField.stringValue)!
            params["height"] = height as AnyObject?
            let keepAr = (_settingsView.maintainAspectRatioField.state == NSControl.StateValue.on)
            params["keepAr"] = keepAr as AnyObject?
            let headerFont = _settingsView.headerFontField.titleOfSelectedItem
            params["headerFont"] = headerFont as AnyObject?
            let includeTitle = ( _settingsView.headerTitleButton.state == NSControl.StateValue.on)
            let includeResolution = ( _settingsView.headerResolutionButton.state == NSControl.StateValue.on)
            let includeCodec = ( _settingsView.headerCodecButton.state == NSControl.StateValue.on)
            let includeDuration = ( _settingsView.headerDurationButton.state == NSControl.StateValue.on)
            let includeSize = ( _settingsView.headerSizeButton.state == NSControl.StateValue.on)
            let includeBitrate = ( _settingsView.headerBitrateButton.state == NSControl.StateValue.on)
            params["headerInformation"] = ["includeTitle": includeTitle,
                                           "includeCodec": includeCodec,
                                           "includeResolution": includeResolution,
                                           "includeDuration": includeDuration,
                                           "includeSize": includeSize,
                                           "includeBitrate": includeBitrate
                                          ] as AnyObject?
            
            let includeTimestamps = (_settingsView.keepTimestampsField.state == NSControl.StateValue.on)
            params["includeTimestamps"] = includeTimestamps as AnyObject?
            let backgroundColor = _settingsView.backgroundColorField.color
            params["backgroundColor"] = backgroundColor as AnyObject?
            let headerColor = _settingsView.headerTextColorField.color
            params["headerColor"] = headerColor as AnyObject?
            let formatIndex = _settingsView.outputFormatSelector.indexOfSelectedItem
            params["formatIndex"] = formatIndex as AnyObject?
            setTableViewProgressBars(numFrames: numFrames)
            
            for (_, file) in batchFiles.enumerated() {
                //self.createContactSheetForFile(file: file, params: params)
                DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
                    self.createContactSheetForFile(file: file, params: params)
                }
            }
        }
    }
    
    func inputButtonClicked(enabled: Bool, button: NSButton) {
        if button == self.settingsView?.maintainAspectRatioField {
            if enabled {
                self.settingsView?.heightField.isEnabled = false
                //let h = getMaintainedARHeight(newWidth: Int(adjustorView.widthField.stringValue)!)
                //adjustorView.heightField.stringValue = String(h)
                self.settingsView?.heightField.stringValue = ""
            }
            else {
                self.settingsView?.heightField.isEnabled = true
            }
        }
    }
    
    func colorChanged(well: NSColorWell) {}
    func savePushed() {}

}


