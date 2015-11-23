//
//  ViewController.swift
//  WiFi RSSI Recorder
//
//  Created by Alex Xu on 11/19/15.
//  Copyright © 2015 Alex Xu. All rights reserved.
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
    
    var timer = NSTimer()       //Timer to get data periodically
    var fileName = String()     //File path and name
    var fileHasCreated = false  //Flag for file writing process
    
    @IBAction func startButtonClicked(sender: NSButton) {
        timer = NSTimer.scheduledTimerWithTimeInterval(1,   //Init timer, get data once per second
            target: self,
            selector: "recordWiFiInformation",
            userInfo: nil,
            repeats: true)
        timer.tolerance = 0.1
        timer.fire()
        
        self.startButton.enabled = false    //Disable the start button
        self.stopButton.enabled = true      //Enable the stop button
        self.position.editable = false      //Disable the position textfield
        self.position.enabled = false
    }
    
    @IBAction func stopButtonClicked(sender: NSButton) {
        
        //Reset UI status
        self.timer.invalidate()     //Stop the timer
        self.agrCtlRSSI.stringValue = ""    //Clear the labels
        self.agrCtlNoise.stringValue = ""
        self.SSID.stringValue = ""
        self.channel.stringValue = ""
        self.linkauth.stringValue = ""
        self.position.stringValue = ""
        self.startButton.enabled = true
        self.stopButton.enabled = false
        self.position.editable = true
        self.position.enabled = true
        fileHasCreated = false
        
        //Read the file just created and create a new file which contains only 
        //the RSSIs of the group, separated by "," with each data, in only one line.
        do {
            
            var fileData: Array = try Array(String(contentsOfFile: self.fileName, encoding: NSUTF8StringEncoding) .componentsSeparatedByString("\t"))
            for var i = 0; i < fileData.count; i++ {
                let tempArray: Array = fileData[i].componentsSeparatedByString("\n")    //Remove "\n" from array
                if tempArray.count > 1 {
                    fileData[i] = tempArray[0]      //Separate the end of a line and the beginning of the next line of the original txt file
                    fileData.insert(tempArray[1], atIndex: i+1)
                }
            }
            
            for var i = 0; i < 2; i++ {
                fileData.removeAtIndex(0)   //Remove header "RSSI   Noise\n" from array
            }
            
            let count = fileData.count      //Avoid calculating fileData.count for multiple times in the coming for loop
            var tempArray2: Array = [String]()

            for var i = 0; i < count-1; i+=2 {    //Keep only RSSIs in the array and put them into tempArray2[]
                                                  //Use count-1 to delete the last element of the array which will be ""
                tempArray2.append(fileData[i])
            }
            
            let oStringForMJG: String = tempArray2.joinWithSeparator(",")
            var mFileName = self.fileName.componentsSeparatedByString(".txt").joinWithSeparator("_")
            mFileName = mFileName + "M.txt"
            try oStringForMJG.writeToFile(mFileName, atomically: true, encoding: NSUTF8StringEncoding)
            
            
        } catch {
            //I promise there won't be any error.
            //You got one?
            //Bite me!
        }
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.startButton.enabled = true
        self.stopButton.enabled = false
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func recordWiFiInformation() {
        //Get Wi-Fi info and record it into a txt file
        //Name the file with current position and time.
        //For example, we got a series of records at 2015.11.19 2:20pm, and we put
        //the Macbook 1.2 meters away from a router, so the file name will be "1.2m_14.20.txt".
        
        let dict: Dictionary = WiFiInformationGetter().getWiFiInfo()
        self.agrCtlRSSI.stringValue = dict["agrCtlRSSI:"]!       //Show RSSI
        let rssi: String = dict["agrCtlRSSI:"]!
        self.agrCtlNoise.stringValue = dict["agrCtlNoise:"]!     //Show Noise
        let noise: String = dict["agrCtlNoise:"]!
        self.SSID.stringValue = dict["SSID:"]!                   //Show SSID
        self.channel.stringValue = dict["channel:"]!             //Show Channel
        self.linkauth.stringValue = dict["linkauth:"]!           //Show Link_Auth
        
        if !fileHasCreated {    //If file not created
            
            let userName: String = NSUserName()     //Get username
            self.fileName = "/Users/" + userName + "/Desktop/"   //Get file path
            
            if self.position.stringValue != "" {    //If has position info
                self.fileName = self.fileName + self.position.stringValue + "_"   //Add position info to file name
            }
            
            let date = NSDate()     //Get current time
            let sec: NSTimeInterval = date.timeIntervalSinceNow
            let currentDate = NSDate(timeIntervalSinceNow: sec)
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "HH.mm"
            let time: String = dateFormatter.stringFromDate(currentDate)
            self.fileName = self.fileName + time + ".txt"       //Add current time to file name
            
            do {
                try "RSSI\tNoise\n".writeToFile(self.fileName, atomically: true, encoding: NSUTF8StringEncoding)
                                                                                                    //Write header into the file
                fileHasCreated = true   //Change the flag
            } catch {
                //Again, I promise there won't be any error.
                //You got another one?
                //Bite me twice, please?
            }
            
        }
        
        let fileHandle: NSFileHandle = NSFileHandle(forWritingAtPath: self.fileName)!
        fileHandle.seekToEndOfFile()
        fileHandle.writeData(rssi.dataUsingEncoding(NSUTF8StringEncoding)!)     //Write RSSI to file
        fileHandle.seekToEndOfFile()
        fileHandle.writeData("\t".dataUsingEncoding(NSUTF8StringEncoding)!)
        fileHandle.seekToEndOfFile()
        fileHandle.writeData(noise.dataUsingEncoding(NSUTF8StringEncoding)!)    //Write Noise to file
        fileHandle.seekToEndOfFile()
        fileHandle.writeData("\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
    }

}

