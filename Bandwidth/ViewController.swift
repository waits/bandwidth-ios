//
//  ViewController.swift
//  Bandwidth
//
//  Created by Dylan Waits on 8/16/15.
//  Copyright (c) 2015 Dylan Waits. All rights reserved.
//

import UIKit

class ViewController: UIViewController, FileTestDelegate {
    
    let network = Network()
    var download: FileTest!
    var upload: FileTest!
    @IBOutlet weak var downloadLabel: UILabel!
    @IBOutlet weak var uploadLabel: UILabel!
    
    @IBOutlet weak var startButton: UIButton!
    
    @IBAction func startWasPressed(sender: UIButton) {
        startButton.enabled = false
        downloadLabel.textColor = UIColor.blackColor()
        download.startDownloadTest()
    }
    
    
    private func showError() {
        let message = "Your internet connection is pretty spotty. Try connecting to a more reliable network and start the test again."
        self.showAlert("Test Failed", message: message, action: "Close")
    }
    
    private func showAlert(title: String, message: String, action: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let closeAction = UIAlertAction(title: action, style: .Default) { (action: UIAlertAction) in
            self.startButton.enabled = true
        }
        alert.addAction(closeAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // File Test Delegate
    
    func fileTest(fileTest: FileTest, didMeasureBandwidth bandwidth: Double) {
        self.downloadLabel.text = "\(round(bandwidth * 100) / 100)Mbps"
    }
    
    func fileTest(fileTest: FileTest, didFinishWithBandwidth bandwidth: Double) {
        self.downloadLabel.text = "\(round(bandwidth * 100) / 100)Mbps"
        self.downloadLabel.textColor = UIColor.redColor()
        self.startButton.enabled = true
    }
    
    func fileTestDidFail() {
        startButton.enabled = true
        showError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        download = FileTest(upload: false)
        download.delegate = self
        upload = FileTest(upload: true)
        upload.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
