//
//  WiFiInformationGetter.swift
//  WiFi RSSI Recorder
//
//  Created by Alex Xu on 11/19/15.
//  Copyright © 2015 Alex Xu. All rights reserved.
//

import Foundation

class WiFiInformationGetter: NSObject {
    
    func getWiFiInfo() -> [String: String] {    //Use Apple's private API to get wifi information
        
        let task = NSTask()
        task.launchPath = "/System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport"
        task.arguments = ["-I"]
        let pipe = NSPipe()
        task.standardOutput = pipe
        task.launch()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        
        let output = String(data: data, encoding: NSUTF8StringEncoding)
        let dataArray: Array = (output?.componentsSeparatedByString("\n"))!
        var dict: Dictionary = [String: String]()
        
        for str: String in dataArray {
            let newString: String = str.stringByReplacingOccurrencesOfString(" ", withString: "")
            if newString != "" {
                let range: Range = newString.rangeOfString(":")!
                let key: String = newString.substringToIndex(range.endIndex)
                let value: String = newString.substringFromIndex(range.endIndex)
                dict[key] = value
            }
        }
        
        return dict
    }
    
}