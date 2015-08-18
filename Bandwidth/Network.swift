//
//  request.swift
//  Bandwidth
//
//  Created by Dylan Waits on 8/16/15.
//  Copyright (c) 2015 Dylan Waits. All rights reserved.
//

import Foundation

class Network : NSObject, GBPingDelegate {
    let host = "d1djlrw04zbni.cloudfront.net"
    var pinger: GBPing?
    var pingTotal: Double = 0.0
    
    func ping() {
        let pinger = GBPing()
        pinger.host = host
        pinger.delegate = self
        pinger.timeout = 0.9
        pinger.pingPeriod = 1.0
        pinger.setupWithBlock() {(success: Bool, error: NSError?) in
            if success {
                println("Starting ping")
                pinger.startPinging()
            }
            else {
                println("Failed to start ping")
            }
        }
        self.pinger = pinger
    }

    func request(size: Int) {
        let url = NSURL(string: "http://\(host)/\(size)m")!
        var request = NSMutableURLRequest(URL: url)
        var response: AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
        var err: NSErrorPointer = nil
        let startTime = mach_absolute_time()
        if let data = NSURLConnection.sendSynchronousRequest(request, returningResponse: response, error: err) {
            let endTime = mach_absolute_time()
            let duration = Int(endTime / NSEC_PER_MSEC - startTime / NSEC_PER_MSEC)
            let rawBandwidth = size * 1024 * 1024 * 8 / duration
            let bandwidth = Double(rawBandwidth * 1000) / Double(1024 * 1024)
            let roundedBandwidth = round(bandwidth * 100) / 100
            println("Duration: \(duration)ms, Bandwidth: \(roundedBandwidth)Mbps (\(rawBandwidth * 1000)bps)")
        }
        else {
            println(err)
        }
    }
    
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
            println("Average: \(avg)ms")
        }
    }
    
    func ping(pinger: GBPing!, didReceiveUnexpectedReplyWithSummary summary: GBPingSummary!) {
        println("Unexpected reply: \(summary)")
    }
    
    func ping(pinger: GBPing!, didSendPingWithSummary summary: GBPingSummary!) {
        println("Sent")
    }
    
    func ping(pinger: GBPing!, didTimeoutWithSummary summary: GBPingSummary!) {
        println("Timeout: \(summary)")
    }
}