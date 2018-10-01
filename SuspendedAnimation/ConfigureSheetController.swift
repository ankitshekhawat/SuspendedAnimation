//
//  ConfigureSheetController.swift
//  SuspendedAnimation
//
//  Created by Ankit Shekhawat on 30/06/18.
//


import Cocoa
import os.log

class ConfigureSheetController : NSObject {
    
    var defaultsManager = DefaultsManager()

    @IBOutlet var window: NSWindow?
    @IBOutlet var canvasColorWell: NSColorWell?
    @IBOutlet var subRedditsTF: NSTextField?
    @IBOutlet weak var doDownload: NSButton!
    @IBOutlet weak var doScaleUp: NSButton!

    
    override init() {
        super.init()
        let myBundle = Bundle(for: ConfigureSheetController.self)
        myBundle.loadNibNamed("ConfigureSheet", owner: self, topLevelObjects: nil)
        canvasColorWell!.color = defaultsManager.canvasColor
        subRedditsTF!.stringValue = defaultsManager.subReddits
        if defaultsManager.doDownload {
            doDownload.state = NSOnState
        } else {
            doDownload.state = NSOffState
        }
        if defaultsManager.doScaleUp {
            doScaleUp.state = NSOnState
        } else {
            doScaleUp.state = NSOffState
        }
    }

    @IBAction func updateDefaults(_ sender: AnyObject) {
        defaultsManager.canvasColor = canvasColorWell!.color
    }
   
    @IBAction func updateSubredit(_ sender: AnyObject){
        defaultsManager.subReddits = (subRedditsTF?.stringValue)!
    }
    
    @IBAction func updateDownloadStatus(_ sender: AnyObject){
        if doDownload?.stringValue == "1" {
            defaultsManager.doDownload = true
        } else {
            defaultsManager.doDownload = false
        }
    }
    
    @IBAction func updateScalingStatus(_ sender: AnyObject){
        if doScaleUp?.stringValue == "1" {
            defaultsManager.doScaleUp = true
        } else {
            defaultsManager.doScaleUp = false
        }
    }
    
    @IBAction func closeConfigureSheet(_ sender: AnyObject) {
        NSColorPanel.shared().close()
//        window!.endSheet(window!)
        NSApp.endSheet(window!)
    }

}
