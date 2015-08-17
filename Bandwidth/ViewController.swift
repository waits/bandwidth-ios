//
//  ViewController.swift
//  Bandwidth
//
//  Created by Dylan Waits on 8/16/15.
//  Copyright (c) 2015 Dylan Waits. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var startButton: UIButton!
    
    @IBAction func startWasPressed(sender: UIButton) {
        request(1)
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
