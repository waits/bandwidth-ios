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
    
    func pingSetupDidFail() {
        pingHandler?(nil)
    }
    
    static func randomData(size: Int) -> NSData {
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