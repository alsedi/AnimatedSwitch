//
//  ViewController.swift
//  AnimatedSwitch
//
//  Created by Alex Sergeev on 4/14/16.
//  Copyright © 2016 ALSEDI Group. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
  @IBOutlet weak var animatedSwitch: AnimatedSwitch!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    animatedSwitch.animationDidStart = { _ in
      print("Animation started")
    }
    
    animatedSwitch.animationDidStop = { _ in
      print("Animation stopped")
    }
    
    // Do any additional setup after loading the view, typically from a nib.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
}

