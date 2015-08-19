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
    
    @IBOutlet weak var startButton: UIButton!
    
    @IBAction func startWasPressed(sender: UIButton) {
        self.network.ping() {(latency: Int) in
            self.network.download(1) { (bandwidth: Double) in
                let message = "Latency: \(latency)ms\nBandwidth: \(bandwidth)Mbps"
                var alert = UIAlertController(title: "Results", message: message, preferredStyle: .Alert)
                let closeAction = UIAlertAction(title: "Done", style: .Default, handler: nil)
                alert.addAction(closeAction)
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
