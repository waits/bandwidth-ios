//
//  Download.swift
//  Bandwidth
//
//  Created by Dylan Waits on 9/26/15.
//  Copyright © 2015 Dylan Waits. All rights reserved.
//

import Foundation

class Download : NSObject {
    private static let host = "cdn.bandwidth.waits.io"
    var callback: (Double?, finished: Bool) -> ()
    
    init(callback: (Double?, finished: Bool) -> ()) {
        self.callback = callback
    }
    
    func startDownloadTest() {
        downloadFile(1, last: 0)
    }
    
    private func downloadFile(size: Int, last: Double) {
        var file: String
        if size > 512 {
            file = "\(size / 1024)m"
        }
        else {
            file = "\(size)k"
        }
        
        let url = NSURL(string: "https://\(Download.host)/\(file)")!
        let sessionConfig = NSURLSessionConfiguration.ephemeralSessionConfiguration()
        let session = NSURLSession(configuration: sessionConfig)
        let startTime = NSDate()
        
        let downloadTask = session.dataTaskWithURL(url) { (data: NSData?, response: NSURLResponse?, error: NSError?) in
            if error == nil {
                let duration = startTime.timeIntervalSinceNow * -1
                let bandwidth = Double(size) / 1024.0 * 8.0 / duration
                print("Downloaded \(file) in \(Int(duration * 1000))ms at \(round(bandwidth * 100) / 100)Mbps")
                if duration > 2.0 {
                    if bandwidth / last > 2.0 || bandwidth / last < 0.5 {
                        self.callback(bandwidth, finished: false)
                        self.downloadFile(size, last: last)
                    }
                    else {
                        let final = (bandwidth * 2 + last) / 3.0
                        self.callback(final, finished: true)
                    }
                }
                else {
                    self.callback(bandwidth, finished: false)
                    self.downloadFile(size * 2, last: bandwidth)
                }
            }
            else {
                print(error)
                self.callback(nil, finished: true)
            }
        }
        
        downloadTask.resume()
    }
}