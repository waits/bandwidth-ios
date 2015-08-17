//
//  request.swift
//  Bandwidth
//
//  Created by Dylan Waits on 8/16/15.
//  Copyright (c) 2015 Dylan Waits. All rights reserved.
//

import Foundation

private let host = "d1djlrw04zbni.cloudfront.net"

public func request(size: Int) {
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
