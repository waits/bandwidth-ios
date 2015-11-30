//
//  Download.swift
//  Bandwidth
//
//  Created by Dylan Waits on 9/26/15.
//  Copyright © 2015 Dylan Waits. All rights reserved.
//

import Foundation

protocol FileTestDelegate {
    func fileTest(fileTest: FileTest, didMeasureBandwidth: Double, withProgress: Double)
    func fileTest(fileTest: FileTest, didFinishWithBandwidth: Double)
    func fileTestDidFail()
}

class FileTest : NSObject, NSURLSessionDataDelegate {
    
    var total: Int = 0
    var upload: Bool
    var delegate: FileTestDelegate!
    private var requestStartTime: NSDate?
    private var testDuration = 8.0
    
    init(upload: Bool) {
        self.upload = upload
    }
    
    func start() {
        dispatchRequest()
    }
    
    private func dispatchRequest() {
        let sessionConfig = NSURLSessionConfiguration.ephemeralSessionConfiguration()
        sessionConfig.URLCache = NSURLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)
        let session = NSURLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
        let task: NSURLSessionDataTask
        
        if self.upload {
            let url = NSURL(string: "http://test.ntwrk.waits.io/upload")!
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            request.HTTPBody = Network.randomData(16000000)
            task = session.dataTaskWithRequest(request)
            
            requestStartTime = NSDate()
            task.resume()
        }
        else {
            let url = NSURL(string: "http://test.ntwrk.waits.io/download")!
            task = session.dataTaskWithURL(url)
            task.resume()
        }
    }
    
    private func processData(session: NSURLSession, data: Int) {
        let elapsedTime = requestStartTime!.timeIntervalSinceNow * -1
        let bandwidth = Double(data) * 8.0 / 1000000.0 / elapsedTime
        
        if elapsedTime >= testDuration {
            session.invalidateAndCancel()
            dispatch_async(dispatch_get_main_queue()) {self.delegate.fileTest(self, didFinishWithBandwidth: bandwidth)}
        }
        else {
            dispatch_async(dispatch_get_main_queue()) {self.delegate.fileTest(self, didMeasureBandwidth: bandwidth, withProgress: Double(elapsedTime / self.testDuration))}
        }
    }
    
    // MARK: - Data Task Delegate
    
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