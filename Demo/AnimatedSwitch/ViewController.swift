//
//  ViewController.swift
//  AnimatedSwitch
//
//  Created by Alex Sergeev on 4/14/16.
//  Copyright © 2016 ALSEDI Group. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var topSwitch: AnimatedSwitch!
    @IBOutlet weak var middleSwitch: AnimatedSwitch!
    @IBOutlet weak var bottomSwitch: AnimatedSwitch!
    
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var middleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        topSwitch.shape = .Star
        middleSwitch.shape = .Diamond
        bottomSwitch.shape = .Round
        
        /*
         You may set both or only one callback for animation events
         */
        topSwitch.animationDidStart = { _ in
            print("Switch at the top: Animation started (Duration: \(self.topSwitch.animationDuration))")

        }
        
        topSwitch.animationDidStop = { _ in
            print("Switch at the top: Animation finished")
        }
        
        
        middleSwitch.animationDidStart = { _ in
            print("Switch at the middle: Animation started (Duration: \(self.topSwitch.animationDuration))")
            
            UIView.transitionWithView(self.middleLabel, duration: self.middleSwitch.animationDuration, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
                self.middleLabel.textColor = !self.middleSwitch.on ? UIColor.whiteColor() : UIColor.blackColor()
                }, completion: nil)
        }
        
        /*
         Here is only animation stop event
         */
        bottomSwitch.animationDidStop = { _ in
            print("Switch at the bottom: Animation finished")
        }
        
    }
}

