//
//  WiFiInformationGetter.swift
//  WiFi Info Recorder
//
//  Created by Alex Xu on 11/19/15.
//  Copyright © 2018 Pinjing "Alex" Xu. All rights reserved.
//

import Foundation

class WiFiInformationGetter: NSObject {
    
    func getWiFiInfo() -> [String: String] {    // Use Apple's private API to get wifi information
        
        let task = Process()
        task.launchPath = "/System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport"
        task.arguments = ["-I"]
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        
        let output = String(data: data, encoding: String.Encoding.utf8)
        let dataArray: Array = (output?.components(separatedBy: "\n"))!
        var dict: Dictionary = [String: String]()
        
        for str: String in dataArray {
            let newString: String = str.replacingOccurrences(of: " ", with: "")
            if newString != "" {
                let range: Range = newString.range(of: ":")!
                let key: String = newString.substring(to: range.upperBound)
                let value: String = newString.substring(from: range.upperBound)
                dict[key] = value
            }
        }
        
        return dict
    }
    
}
