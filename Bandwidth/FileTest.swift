//
//  Download.swift
//  Bandwidth
//
//  Created by Dylan Waits on 9/26/15.
//  Copyright © 2015 Dylan Waits. All rights reserved.
//

import Foundation

protocol FileTestDelegate {
    func fileTest(fileTest: FileTest, didMeasureBandwidth: Double)
    func fileTest(fileTest: FileTest, didFinishWithBandwidth: Double)
    func fileTestDidFail()
}

class FileTest : NSObject {
    private var requestStartTime: NSDate?
    private var lastFile: Int!
    private var lastResult: Double = 0
    var upload: Bool
    var delegate: FileTestDelegate!
    
    init(upload: Bool) {
        self.upload = upload
    }
    
    func start() {
        lastFile = 1
        dispatchRequest(1)
    }
    
    func responseHandler(data: NSData?, response: NSURLResponse?, error: NSError?) {
        if error == nil {
            let duration = requestStartTime!.timeIntervalSinceNow * -1
            let rawSize = lastFile
            let bandwidth = Double(rawSize) / 1024.0 * 8.0 / duration
            let verb = upload ? "Uploaded" : "Downloaded"
            print("\(verb) \(rawSize)k in \(Int(duration * 1000))ms at \(round(bandwidth * 100) / 100)Mbps")
            if duration > 2.0 {
                if bandwidth / lastResult > 2.0 || bandwidth / lastResult < 0.5 {
                    dispatch_async(dispatch_get_main_queue()) {self.delegate.fileTest(self, didMeasureBandwidth: bandwidth)}
                    self.dispatchRequest(lastFile)
                }
                else {
                    let final = (bandwidth * 2 + lastResult) / 3.0
                    dispatch_async(dispatch_get_main_queue()) {self.delegate.fileTest(self, didFinishWithBandwidth: final)}
                }
            }
            else {
                dispatch_async(dispatch_get_main_queue()) {self.delegate.fileTest(self, didMeasureBandwidth: bandwidth)}
                lastResult = bandwidth
                lastFile = lastFile * 2
                self.dispatchRequest(lastFile)
            }
        }
        else {
            print(error)
            dispatch_async(dispatch_get_main_queue()) {self.delegate.fileTestDidFail()}
        }
    }
    
    private func dispatchRequest(size: Int) {
        var file: String
        if lastFile > 512 {
            file = "\(lastFile / 1024)m"
        }
        else {
            file = "\(lastFile)k"
        }
        
        let sessionConfig = NSURLSessionConfiguration.ephemeralSessionConfiguration()
        sessionConfig.timeoutIntervalForResource = 8.0
        let session = NSURLSession(configuration: sessionConfig)
        let task: NSURLSessionDataTask
        requestStartTime = NSDate()
        
        if self.upload {
            let url = NSURL(string: "https://bandwidth.waits.io/upload")!
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            request.HTTPBody = Network.randomData(size)
            task = session.dataTaskWithRequest(request, completionHandler: responseHandler)
            task.resume()
        }
        else {
            let url = NSURL(string: "https://cdn.bandwidth.waits.io/\(file)")!
            task = session.dataTaskWithURL(url, completionHandler: responseHandler)
            task.resume()
        }
        
    }
}