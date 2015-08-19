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
            println("Latency: \(latency)ms")
            self.network.download(1) { (bandwidth: Double) in
                println("Bandwidth: \(bandwidth)Mbps")
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
