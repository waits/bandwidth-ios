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

class FileTest : NSObject, NSURLSessionDataDelegate {
    private var requestStartTime: NSDate?
    var total: Int = 0
    var upload: Bool
    var delegate: FileTestDelegate!
    
    init(upload: Bool) {
        self.upload = upload
    }
    
    func start() {
        dispatchRequest((upload ? 64 : 128) * 1024 * 1024)
    }
    
    private func dispatchRequest(size: Int) {
        let file = convertSize(size)
        
        let sessionConfig = NSURLSessionConfiguration.ephemeralSessionConfiguration()
        sessionConfig.URLCache = NSURLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)
        let session = NSURLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
        let task: NSURLSessionDataTask
        
        if self.upload {
            let url = NSURL(string: "https://bandwidth.waits.io/upload")!
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            request.HTTPBody = Network.randomData(size)
            task = session.dataTaskWithRequest(request)
            
            requestStartTime = NSDate()
            task.resume()
        }
        else {
            let url = NSURL(string: "https://cdn.bandwidth.waits.io/\(file)")!
            task = session.dataTaskWithURL(url)
            task.resume()
        }
    }
    
    private func convertSize(size: Int) -> String {
        if size >= 1_048_576 {
            return size % 1_048_576 == 0 ? "\(size / 1_048_576)m" : "\(Double(size) / 1_048_576.0)m"
        }
        if size > 1024 {
            return size % 1024 == 0 ? "\(size / 1024)k" : "\(Double(size) / 1024.0)k"
        }
        else {
            return "\(size)b"
        }
    }
    
    private func processData(session: NSURLSession, data: Int) {
        let duration = requestStartTime!.timeIntervalSinceNow * -1
        let bandwidth = Double(data) * 8.0 / 1_048_576.0 / duration
        
        if duration > 5.0 {
            session.invalidateAndCancel()
            dispatch_async(dispatch_get_main_queue()) {self.delegate.fileTest(self, didFinishWithBandwidth: bandwidth)}
        }
        else {
            dispatch_async(dispatch_get_main_queue()) {self.delegate.fileTest(self, didMeasureBandwidth: bandwidth)}
        }
    }
    
    // Data Task Delegate
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
        requestStartTime = NSDate()
        completionHandler(NSURLSessionResponseDisposition.Allow)
    }
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        self.total += data.length
        processData(session, data: total)
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        processData(session, data: Int(totalBytesSent))
    }
}