//
//  ViewController.swift
//  WiFi Info Recorder
//
//  Created by Alex Xu on 11/19/15.
//  Copyright © 2018 Pinjing "Alex" Xu. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet var SSID: NSTextField!
    @IBOutlet var linkauth: NSTextField!
    @IBOutlet var channel: NSTextField!
    @IBOutlet var agrCtlNoise: NSTextField!
    @IBOutlet var agrCtlRSSI: NSTextField!
    @IBOutlet var position: NSTextField!
    @IBOutlet var startButton: NSButton!
    @IBOutlet var stopButton: NSButton!
    
    var timer = Timer()         // Timer to get data periodically
    var fileName = String()     // File path and name
    var fileHasCreated = false  // Flag for file writing process
    
    @IBAction func startButtonClicked(sender: NSButton) {
        timer = Timer.scheduledTimer(timeInterval: 1,   // Init timer, get data once per second
            target: self,
            selector: #selector(recordWiFiInformation),
            userInfo: nil,
            repeats: true)
        timer.tolerance = 0.1
        timer.fire()
        
        self.startButton.isEnabled = false    // Disable the start button
        self.stopButton.isEnabled = true      // Enable the stop button
        self.position.isEnabled = false       // Disable the position textfield
        self.position.isEnabled = false
    }
    
    @IBAction func stopButtonClicked(sender: NSButton) {
        
        // Reset UI status
        self.timer.invalidate()     // Stop the timer
        self.agrCtlRSSI.stringValue = ""    // Clear the labels
        self.agrCtlNoise.stringValue = ""
        self.SSID.stringValue = ""
        self.channel.stringValue = ""
        self.linkauth.stringValue = ""
        self.position.stringValue = ""
        self.startButton.isEnabled = true
        self.stopButton.isEnabled = false
        self.position.isEnabled = true
        self.position.isEnabled = true
        fileHasCreated = false
        
        // Read the file just created and create a new file which contains only
        // the RSSIs of the group, separated by "," with each data, in only one line.
        do {
            
            var fileData: Array = try Array(String(contentsOfFile: self.fileName, encoding: String.Encoding.utf8).components(separatedBy: "\t"))
            for i in 0..<fileData.count {
                let tempArray: Array = fileData[i].components(separatedBy: "\n")    // Remove "\n" from array
                if tempArray.count > 1 {
                    fileData[i-1] = tempArray[1]      // Take only the RSSI value
                }
            }
            
            fileData.removeLast(2);   // Remove useless elements
            
            let oStringForMJG: String = fileData.joined(separator: ",")
            var mFileName = self.fileName.components(separatedBy: ".txt").joined(separator: "_")
            mFileName = mFileName + "M.txt"
            try oStringForMJG.write(toFile: mFileName, atomically: true, encoding: String.Encoding.utf8)
            
            
        } catch {
            // I promise there won't be any error.
            // You got one?
            // Bite me!
            print("STOP - BITE YOU!")
            print(error.localizedDescription)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.startButton.isEnabled = true
        self.stopButton.isEnabled = false
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    @objc func recordWiFiInformation() {
        // Get Wi-Fi info and record it into a txt file
        // Name the file with current position and time.
        // For example, we got a series of records at 2015.11.19 2:20pm, and we put
        // the Macbook 1.2 meters away from a router, so the file name will be "1.2m_14.20.txt".
        
        let dict: Dictionary = WiFiInformationGetter().getWiFiInfo()
        self.agrCtlRSSI.stringValue = dict["agrCtlRSSI:"]!       // Show RSSI
        let rssi: String = dict["agrCtlRSSI:"]!
        self.agrCtlNoise.stringValue = dict["agrCtlNoise:"]!     // Show Noise
        let noise: String = dict["agrCtlNoise:"]!
        self.SSID.stringValue = dict["SSID:"]!                   // Show SSID
        self.channel.stringValue = dict["channel:"]!             // Show Channel
        self.linkauth.stringValue = dict["linkauth:"]!           // Show Link_Auth
        
        if !fileHasCreated {    // If file not created
            
            let userName: String = NSUserName()     // Get username
            self.fileName = "/Users/" + userName + "/Desktop/"   // Get file path
            
            if self.position.stringValue != "" {    //If has position info
                self.fileName = self.fileName + self.position.stringValue + "_"   // Add position info to file name
            }
            
            let date = NSDate()     // Get current time
            let sec: TimeInterval = date.timeIntervalSinceNow
            let currentDate = NSDate(timeIntervalSinceNow: sec)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH.mm"
            let time: String = dateFormatter.string(from: currentDate as Date)
            self.fileName = self.fileName + time + ".txt"       // Add current time to file name
            
            do {
                try "RSSI\tNoise\n".write(toFile: self.fileName, atomically: true, encoding: String.Encoding.utf8)
                // Write header into the file
                fileHasCreated = true   // Change the flag
            } catch {
                // Again, I promise there won't be any error.
                // You got another one?
                // Bite me twice, please?
                print("BITE YOU!")
                print(error.localizedDescription)
            }
            
        }
        
        let fileHandle: FileHandle = FileHandle(forWritingAtPath: self.fileName)!
        fileHandle.seekToEndOfFile()
        fileHandle.write(rssi.data(using: String.Encoding.utf8)!)     // Write RSSI to file
        fileHandle.seekToEndOfFile()
        fileHandle.write("\t".data(using: String.Encoding.utf8)!)
        fileHandle.seekToEndOfFile()
        fileHandle.write(noise.data(using: String.Encoding.utf8)!)    // Write Noise to file
        fileHandle.seekToEndOfFile()
        fileHandle.write("\n".data(using: String.Encoding.utf8)!)
        
    }
    
}


