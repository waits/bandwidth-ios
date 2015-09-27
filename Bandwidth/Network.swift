//
//  request.swift
//  Bandwidth
//
//  Created by Dylan Waits on 8/16/15.
//  Copyright (c) 2015 Dylan Waits. All rights reserved.
//

import Foundation

class Network : NSObject, GBPingDelegate {
    private var pinger: GBPing?
    private var pingsCompleted: Int = 0
    private var pingTime: Double = 0.0
    private var pingHandler: ((Int?) -> ())?
    
    func startPing(completionHandler: (Int?) -> ()) {
        self.pingHandler = completionHandler
        let pinger = GBPing()
        pinger.host = "cdn.bandwidth.waits.io"
        pinger.delegate = self
        pinger.timeout = 0.9
        pinger.pingPeriod = 1.0
        pinger.setupWithBlock() {(success: Bool, error: NSError?) in
            if success {
                self.pingsCompleted = 0
                self.pingTime = 0.0
                pinger.startPinging()
            }
            else {
                self.pingHandler?(nil)
            }
        }
        self.pinger = pinger
    }
    
    func startUpload(completionHandler: (Double?) -> ()) {
        upload(1, last: (0, 0), completionHandler: completionHandler)
    }
    
    func upload(size: Int, last: (size: Int, time: Double), completionHandler: (Double?) -> ()) {
        var file: String
        if size > 512 {
            file = "\(size / 1024)m"
        }
        else {
            file = "\(size)k"
        }
        let url = NSURL(string: "https://bandwidth.waits.io/upload")!
        let startTime = NSDate()
        
        let sessionConfig = NSURLSessionConfiguration.ephemeralSessionConfiguration()
        let session = NSURLSession(configuration: sessionConfig)
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.HTTPBody = randomData(size)
        
        let uploadTask = session.dataTaskWithRequest(request) { (data: NSData?, response: NSURLResponse?, error: NSError?) in
            if error == nil {
                let duration = startTime.timeIntervalSinceNow * -1
                print("Uploaded \(file) in \(Int(duration * 1000))ms")
                if duration > 1.0 && last.time > 0.5 {
                    let bandwidth = Double((size + last.size) / 1024 * 8) / (duration + last.time)
                    let roundedBandwidth = round(bandwidth * 100) / 100
                    completionHandler(roundedBandwidth)
                }
                else {
                    self.upload(size * 2, last: (size, duration), completionHandler: completionHandler)
                }
            }
            else {
                completionHandler(nil)
            }
        }
        
        uploadTask.resume()
    }
    
    func pingSetupDidFail() {
        pingHandler?(nil)
    }
    
    private func randomData(size: Int) -> NSData {
        return NSMutableData(length: size * 1024)!.copy() as! NSData
    }
    
    // MARK: - GBPing Delegate
    
    func stopPing() {
        print("Stopping ping")
        self.pinger?.stop()
    }
    
    func ping(pinger: GBPing!, didFailToSendPingWithSummary summary: GBPingSummary!, error: NSError!) {
        print("Failed: \(error)")
        if summary.sequenceNumber >= 9 {
            pinger.stop()
            pingHandler?(nil)
        }
    }
    
    func ping(pinger: GBPing!, didFailWithError error: NSError!) {
        print("Error: \(error)")
    }
    
    func ping(pinger: GBPing!, didReceiveReplyWithSummary summary: GBPingSummary!) {
        let rtt = summary.rtt * 1000
        pingTime += rtt
        pingsCompleted++
        print("Ping #\(summary.sequenceNumber): \(Int(round(rtt)))ms")
        if pingsCompleted >= 5 {
            pinger.stop()
            let avg = Int(round(pingTime / Double(pingsCompleted)))
            self.pingHandler?(avg)
        }
    }
    
    func ping(pinger: GBPing!, didReceiveUnexpectedReplyWithSummary summary: GBPingSummary!) {
        print("Unexpected reply: \(summary)")
    }
    
    func ping(pinger: GBPing!, didSendPingWithSummary summary: GBPingSummary!) {
    }
    
    func ping(pinger: GBPing!, didTimeoutWithSummary summary: GBPingSummary!) {
        print("Timeout: \(summary)")
    }
}