//
//  DefaultsManager.swift
//  SuspendedAnimation
//
//  Created by Ankit Shekhawat on 30/06/18.
//



import ScreenSaver

class DefaultsManager {
    
    var defaults: UserDefaults
    
    init() {
        let identifier = Bundle(for: DefaultsManager.self).bundleIdentifier
        defaults = ScreenSaverDefaults.init(forModuleWithName: identifier!)!
    }
    
    var canvasColor: NSColor {
        set(newColor) {
            setColor(newColor, key: "CanvasColor")
        }
        get {
            return getColor("CanvasColor") ?? NSColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        }
    }
    
    var subReddits: String {
        set(newSubreddit){
            defaults.set(NSKeyedArchiver.archivedData(withRootObject: newSubreddit), forKey: "Subreddits")
            defaults.synchronize()
        }
        get {
            
            if let subredditData = defaults.object(forKey: "Subreddits") as? Data {
                return NSKeyedUnarchiver.unarchiveObject(with: subredditData) as? String ?? String("cinemagraphs+perfectloops");
            }
            return String("cinemagraphs+perfectloops");
            }
    }
    var doDownload: Bool {
        set(value){
            defaults.set(NSKeyedArchiver.archivedData(withRootObject: value), forKey: "doDownload")
            defaults.synchronize()
        }
        get{
            if let doDownload = defaults.object(forKey: "doDownload") as? Data {
                return NSKeyedUnarchiver.unarchiveObject(with: doDownload) as? Bool ?? true;
            }
            return true
        }
    }

    var doScaleUp: Bool {
        set(value){
            defaults.set(NSKeyedArchiver.archivedData(withRootObject: value), forKey: "doScaleUp")
            defaults.synchronize()
        }
        get{
            if let doScaleUp = defaults.object(forKey: "doScaleUp") as? Data {
                return NSKeyedUnarchiver.unarchiveObject(with: doScaleUp) as? Bool ?? false;
            }
            return false
        }
    }
    
    func setColor(_ color: NSColor, key: String) {
        defaults.set(NSKeyedArchiver.archivedData(withRootObject: color), forKey: key)
        defaults.synchronize()
    }

    func getColor(_ key: String) -> NSColor? {
        if let canvasColorData = defaults.object(forKey: key) as? Data {
            return NSKeyedUnarchiver.unarchiveObject(with: canvasColorData) as? NSColor
        }
        return nil;
    }

        
}
