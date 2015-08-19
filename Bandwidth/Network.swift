//
//  request.swift
//  Bandwidth
//
//  Created by Dylan Waits on 8/16/15.
//  Copyright (c) 2015 Dylan Waits. All rights reserved.
//

import Foundation

class Network : NSObject, GBPingDelegate {
    private static let host = "d1djlrw04zbni.cloudfront.net"
    private var pinger: GBPing?
    private var pingTotal: Double = 0.0
    private var pingHandler: ((Int) -> ())?
    private var downloadTotal: Int = 0
    private var downloadTime: UInt64 = 0
    
    func ping(completionHandler: (Int) -> ()) {
        let pinger = GBPing()
        pinger.host = Network.host
        pinger.delegate = self
        pinger.timeout = 0.9
        pinger.pingPeriod = 1.0
        pinger.setupWithBlock() {(success: Bool, error: NSError?) in
            if success {
                self.pingHandler = completionHandler
                pinger.startPinging()
            }
            else {
                println("Failed to start ping")
            }
        }
        self.pinger = pinger
    }
    
    func download(size: Int, completionHandler: (Double) -> ()) {
        var file: String
        if size > 512 {
            file = "\(size / 1024)m"
        }
        else {
            file = "\(size)k"
        }
        let url = NSURL(string: "http://\(Network.host)/\(file)")!
        var request = NSMutableURLRequest(URL: url)
        var response: AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
        var err: NSErrorPointer = nil
        let startTime = mach_absolute_time()
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: { (response: NSURLResponse!, data: NSData!, error: NSError!) in
            let endTime = mach_absolute_time()
            let duration = endTime / NSEC_PER_MSEC - startTime / NSEC_PER_MSEC
            self.downloadTotal += size
            self.downloadTime += duration
            println("Downloaded \(file) in \(duration)ms")
            if duration > 1000 {
                let bandwidth = Double(self.downloadTotal * 1024 * 8) / Double(self.downloadTime * 1000)
                let roundedBandwidth = round(bandwidth * 100) / 100
                completionHandler(roundedBandwidth)
            }
            else {
                self.download(size * 2, completionHandler: completionHandler)
            }
        })
    }
    
    // MARK: - GBPing Delegate
    
    func stopPing() {
        println("Stopping ping")
        self.pinger?.stop()
    }
    
    func ping(pinger: GBPing!, didFailToSendPingWithSummary summary: GBPingSummary!, error: NSError!) {
        println("Failed: \(error)")
        pinger.stop()
    }
    
    func ping(pinger: GBPing!, didFailWithError error: NSError!) {
        println("Error: \(error)")
    }
    
    func ping(pinger: GBPing!, didReceiveReplyWithSummary summary: GBPingSummary!) {
        let rtt = summary.rtt * 1000
        pingTotal += rtt
        println("Ping: \(Int(round(rtt)))ms")
        if summary.sequenceNumber >= 9 {
            pinger.stop()
            let avg = Int(round(pingTotal / 10))
            self.pingHandler?(avg)
        }
    }
    
    func ping(pinger: GBPing!, didReceiveUnexpectedReplyWithSummary summary: GBPingSummary!) {
        println("Unexpected reply: \(summary)")
    }
    
    func ping(pinger: GBPing!, didSendPingWithSummary summary: GBPingSummary!) {
    }
    
    func ping(pinger: GBPing!, didTimeoutWithSummary summary: GBPingSummary!) {
        println("Timeout: \(summary)")
    }
}