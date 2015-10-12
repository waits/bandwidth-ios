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
    @IBOutlet weak var downloadLabel: UILabel!
    @IBOutlet weak var uploadLabel: UILabel!
    
    @IBOutlet weak var startButton: UIButton!
    
    @IBAction func startWasPressed(sender: UIButton) {
        startButton.enabled = false
        downloadLabel.textColor = UIColor.blackColor()
        downloadLabel.text = ""
        uploadLabel.textColor = UIColor.blackColor()
        uploadLabel.text = ""
        let download = FileTest(upload: false)
        download.delegate = self
        download.start()
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
        if fileTest.upload {
            self.uploadLabel.text = "\(round(bandwidth * 100) / 100)Mbps"
        }
        else {
            self.downloadLabel.text = "\(round(bandwidth * 100) / 100)Mbps"
        }
    }
    
    func fileTest(fileTest: FileTest, didFinishWithBandwidth bandwidth: Double) {
        if fileTest.upload {
            self.uploadLabel.text = "\(round(bandwidth * 100) / 100)Mbps"
            self.uploadLabel.textColor = UIColor.redColor()
            self.startButton.enabled = true
        }
        else {
            self.downloadLabel.text = "\(round(bandwidth * 100) / 100)Mbps"
            self.downloadLabel.textColor = UIColor.redColor()
            let upload = FileTest(upload: true)
            upload.delegate = self
            upload.start()
        }
    }
    
    func fileTestDidFail() {
        startButton.enabled = true
        showError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
