//
//  SuspendedAnimation.swift
//  SuspendedAnimation
//
//  Created by Ankit Shekhawat on 30/06/18.
//  Copyright © 2018 Ankit Shekhawat. All rights reserved.
//


import ScreenSaver
import os.log
import AVKit

class SuspendedAnimationView: ScreenSaverView {
    
    var defaultsManager: DefaultsManager = DefaultsManager()
    lazy var sheetController: ConfigureSheetController = ConfigureSheetController()
   
    let configs = ["concurrentDownloads": 3,
                   "convertToMp4": true,
                   "deleteOldFiles": false,
                   "subreddits": "cinemagraphs+perfectloops",
                   "download": true
        ] as [String : Any]
    
    var looper : NSObject?
    let dirPath = NSString(string: "~/Documents/cinemagraphs/").expandingTildeInPath
    
    override init(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)!
        self.animationTimeInterval = 60
        drawCinemagraphs()
        if defaultsManager.doDownload {
            getRedditCinemagraphs()
            
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override func hasConfigureSheet() -> Bool {
        return true
    }
    
    override func configureSheet() -> NSWindow? {
        return sheetController.window
    }

    
    override func startAnimation() {
        super.startAnimation()
      
    }
    
    override func stopAnimation() {
        super.stopAnimation()
    }
    

    override func draw(_ rect: NSRect) {
        let bPath:NSBezierPath = NSBezierPath(rect: bounds)
        defaultsManager.canvasColor.set()
        bPath.fill()

     }
    
    override func animateOneFrame() {
        window!.disableFlushing()
        
        window!.enableFlushing()
    }
    
    func drawCinemagraphs(){
        
        let fileManager = FileManager.default
        do{
            try fileManager.createDirectory(at: URL(fileURLWithPath: dirPath, isDirectory: true), withIntermediateDirectories: true)
        } catch let error as NSError {
            NSLog("Ooops! Something went wrong: \(error)")
            NSString(string:"coud not create/find Directory at ~/Documents/cinemagraphs").draw(at:NSPoint(x:250, y:250), withAttributes:nil)
        }
        
        let (file, isValid) =  get_file(dirPath: NSString(string:dirPath))
        
        for view in self.subviews{
            view.removeFromSuperview()
        }
        
        if !isValid {
            let message:NSString = "No Gifs/Videos found, downloading some will check again soon"
            NSColor.red.setFill()
            NSRectFill(self.bounds)
            NSColor.white.setFill()
            message.draw(at: NSPoint(x: 100.0, y: 200.0), withAttributes:nil)
            
        } else{
            if file.pathExtension == "gif" || file.pathExtension == "gifv"{
                
                let gifImage = NSImage(byReferencingFile:file as String)
                
                let imageView = NSImageView(frame: NSRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
                imageView.canDrawSubviewsIntoLayer = true
                if defaultsManager.doScaleUp {
                    imageView.imageScaling = .scaleProportionallyUpOrDown }
                else{ imageView.imageScaling = .scaleProportionallyDown }
                
                imageView.animates = true
                imageView.image = gifImage!
                self.addSubview(imageView)
            }
            else {
                let videoURL = URL(fileURLWithPath: file as String)
                let asset  = AVAsset(url:videoURL)
                
                let playerItem = AVPlayerItem(asset:asset)
                
                let queuePlayer = AVQueuePlayer()
                
                let avPlayerView = AVPlayerView(frame: NSRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
                avPlayerView.player = queuePlayer
                avPlayerView.controlsStyle = .none
                
                self.addSubview(avPlayerView)
                //            avPlayerView.ShowsPlaybackControls = false
                queuePlayer.isMuted = true
                queuePlayer.play()
                let duration = Int64( ( (Float64(CMTimeGetSeconds(asset.duration)) *  10.0) - 1) / 10.0 )
                self.looper = AVPlayerLooper(player:queuePlayer, templateItem:playerItem, timeRange:CMTimeRange(start: kCMTimeZero, end: CMTimeMake(duration, 1)))
                
                
            }
        }
    }
    
    func get_file(dirPath:NSString) -> (file: NSString, isValid: Bool) {
        let fileManager =   FileManager.default
        do {
            let files =  try fileManager.contentsOfDirectory(atPath: dirPath as String)
            let animatables = files.filter {
                let validExtensions = ["gif","mp4","avi","mov","gifv"]
                return validExtensions.contains(NSString(string:$0).pathExtension)
            }
            if animatables.count<1{
                return ("", false)
            }
            let index =         Int(arc4random_uniform(UInt32(animatables.count)))
            let dirString =     dirPath as String
            let file =          NSString(string: dirString + "/" + animatables[index])
            return (file, true)
            
        }
        catch let error as NSError {            
            NSLog("Ooops! Something went wrong: \(error)")
            return (NSString(string: "Ooops! Something went wrong: \(error)") , false)
        }
        
    }
    
    
    func getRedditCinemagraphs(){
        let dirPath = NSString(string: "~/Documents/cinemagraphs/").expandingTildeInPath
        
        let fileManager = FileManager.default
        do{
            try fileManager.createDirectory(at: URL(fileURLWithPath: dirPath, isDirectory: true), withIntermediateDirectories: true)
        } catch let error as NSError {
            NSLog("Ooops! Something went wrong: \(error)")
            NSString(string:"coud not create/find Directory at ~/Documents/cinemagraphs").draw(at:NSPoint(x:250, y:250), withAttributes:nil)
            
        }
        
        
        let url = "http://www.reddit.com/r/\(String(describing: defaultsManager.subReddits))/hot.rss"
        
    
        Requests.getRedditItems(url: URL(string: url)!, completion:saveItems)
        
        
    }
    
    
    func saveItems(_ items: Dictionary<String, [String]> ){
        os_log("[SAsaver] SaveItem")
        let fileUrl = dirPath + "/reddit.plist" // Your path here
        var ids = NSArray(contentsOfFile: fileUrl) as? [String] ?? []
        var todo = [String:String]()
        for (id, urls) in items {
            if !(ids.contains(id)) && urls.count>0{
                todo[id] = urls[0]
                os_log("[SASaver]To Download: %@", id)
                
            }
        }
        
        for (id, url) in todo{
            let filename = NSString(string:url).pathExtension
            let destPath = dirPath + "/" + id + "." + filename
            func appendIds(id:String){
                ids.append(id)
                (ids as NSArray).write(to: URL(fileURLWithPath:fileUrl), atomically: true)
            }
            
            Requests.save(url: URL(string:url)!, to: URL(fileURLWithPath: destPath), _id: id, completion: appendIds)
            
        }
    }
    
}
    

