//
//  ViewController.swift
//  Bandwidth
//
//  Created by Dylan Waits on 8/16/15.
//  Copyright (c) 2015 Dylan Waits. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let network = Network()
    var download: Download!
    @IBOutlet weak var downloadLabel: UILabel!
    
    @IBOutlet weak var startButton: UIButton!
    
    @IBAction func startWasPressed(sender: UIButton) {
        startButton.enabled = false
        downloadLabel.textColor = UIColor.blackColor()
        self.download.startDownloadTest()
    }
    
    func downloadTestDidReturnData(bandwidth: Double?, finished: Bool) {
        if let bandwidth = bandwidth {
            dispatch_async(dispatch_get_main_queue()) {
                self.downloadLabel.text = "\(round(bandwidth * 100) / 100)Mbps"
                if finished {
                    self.downloadLabel.textColor = UIColor.blueColor()
                    self.startButton.enabled = true
                }
            }
        }
        else {
            dispatch_async(dispatch_get_main_queue()) {
                self.downloadLabel.text = "Error"
                self.downloadLabel.textColor = UIColor.redColor()
                self.startButton.enabled = true
                self.showError()
            }
        }
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

    override func viewDidLoad() {
        super.viewDidLoad()
        download = Download(callback: downloadTestDidReturnData)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
