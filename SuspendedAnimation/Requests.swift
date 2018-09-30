//
//  downloader.swift
//  rss.test
//
//  Created by Ankit Shekhawat on 01/07/18.
//  Copyright © 2018 Ankit Shekhawat. All rights reserved.


import Foundation
import os.log

class Requests {
    class func save(url: URL, to localUrl: URL, _id:String, completion: @escaping (String) -> ()) {
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let request = URLRequest(url: url)
        
        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                // Success
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    print("Success: \(statusCode)")
                }
                
                do {
                    
                    os_log("extension: %@", localUrl.pathExtension)
//                    Code for enabling gif2mp4 needs more testing
//                    let ext = localUrl.pathExtension
//                    if ext == "gif" {
//                        var u = localUrl
//                        u.deletePathExtension()
//                        u.appendPathExtension("mp4")
//
//                        os_log("w/o ext: %@", u.absoluteString)
//                        let data = try! Data(contentsOf: tempLocalUrl)
//
//
//                                let tempUrl = URL(fileURLWithPath: dirPath).appendingPathComponent("temp.mp4")
//
//                        GIF2MP4(data: data)?.convertAndExport(to: u, completion: { })
//                    } else {
//                    try FileManager.default.copyItem(at: tempLocalUrl, to: localUrl)
//                    }
                    try FileManager.default.copyItem(at: tempLocalUrl, to: localUrl)
                    
                    completion(_id)
                } catch (let writeError) {
                    print("error writing file \(localUrl) : \(writeError)")
                    do{
                        print("Trying to overwrite the file")
                        try _ = FileManager.default.replaceItemAt(localUrl, withItemAt: tempLocalUrl)
                    } catch (let writeError){
                        print("error writing file \(localUrl) : \(writeError)")
                    }
                }
                
            } else {
                print("Failure: %@", error?.localizedDescription ?? "");
            }
        }
        task.resume()
    }
    class func getRedditItems(url: URL, completion: @escaping (_ items:Dictionary<String, [String]>) -> ()){
        let request = URLRequest(url: url)
        var items = [String:[String]]()
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error ?? "Unknown error")
                return
            }
            let xml = SWXMLHash.parse(data)
            let entries = xml["feed"]["entry"]
            
            for entry in entries.all {
                let id = entry["id"].element?.text ?? ""
                let images = imagesFromHTMLString(entry["content"].element?.text ?? "")
                if id != "" && images.count > 0 {
                    items[id] = images
                    
                }
                completion(items)
            }
            
        }
        task.resume()
        
    }
}

func imagesFromHTMLString(_ htmlString: String) -> [String] {
    let htmlNSString = htmlString as NSString;
    var images: [String] = Array();
    
    do {
        let regex = try NSRegularExpression(pattern: "(http?)\\S*(\\.mp4|\\.avi|\\.mov|\\.gif|\\.gifv)", options: [NSRegularExpression.Options.caseInsensitive])
        
        regex.enumerateMatches(in: htmlString, options: [NSRegularExpression.MatchingOptions.reportProgress], range: NSMakeRange(0, htmlString.count)) { (result, flags, stop) -> Void in
            if let range = result?.range {
                images.append(htmlNSString.substring(with: range))  //because Swift ranges are still completely ridiculous
            }
        }
    }
        
    catch {
        
    }
    
    return images;
}

