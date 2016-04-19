//  AnimatedSwitch
//  The MIT License (MIT)
//
//  Created by Alex Sergeev on 4/14/16.
//  Copyright © 2016 ALSEDI Group. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import UIKit
import QuartzCore

@IBDesignable class AnimatedSwitch: UISwitch {
  @IBInspectable var color: UIColor = UIColor.clearColor()
  @IBInspectable var animationDuration: Double = 0.25
  @IBInspectable var startRadius: Double = 15
  
  @IBInspectable var borderColor: UIColor = UIColor.whiteColor()
  @IBInspectable var showBorder: Bool = true
  
  private var originalParentBackground: UIColor?
  private var toColor: UIColor?

  private let animationIdentificator = "animatedSwitch"
  private let containerLayer = CAShapeLayer()
  
  typealias VoidClosure = () -> ()
  var animationDidStart: VoidClosure?
  var animationDidStop: VoidClosure?
  
  private func setupView(parent: UIView) {
    removeTarget(self, action: #selector(AnimatedSwitch.valueChanged), forControlEvents: .ValueChanged)
    addTarget(self, action: #selector(AnimatedSwitch.valueChanged), forControlEvents: .ValueChanged)
    containerLayer.anchorPoint = CGPoint(x: 0, y: 0)
    containerLayer.masksToBounds = true
    
    parent.layer.insertSublayer(containerLayer, atIndex: 0)
  }
  
  override func willMoveToSuperview(newSuperview: UIView?) {
    if let parent = newSuperview {
      setupView(parent)
      originalParentBackground = parent.backgroundColor
    }
  }
  
  override func layoutSubviews() {
    guard let parent = superview else { return }
    containerLayer.frame = CGRect(x: 0, y: 0, width: parent.frame.width, height: parent.frame.height)
    if on {
      containerLayer.backgroundColor = color.CGColor
    } else {
      containerLayer.backgroundColor = originalParentBackground?.CGColor
    }
  }
  
  func valueChanged() {
    guard let parent = superview else { return }
    
    if on {
      toColor = color
    } else {
      toColor = parent.backgroundColor
    }
    
    guard let _ = toColor else { return }
    
    let correctedFrame = CGRectMake(center.x - CGFloat(startRadius), center.y - CGFloat(startRadius), CGFloat(startRadius) * 2, CGFloat(startRadius) * 2)
    
    let layer = CAShapeLayer()
    layer.removeAllAnimations()
    layer.bounds = correctedFrame
    layer.position = self.center
    layer.path = UIBezierPath(ovalInRect: correctedFrame).CGPath
    layer.lineWidth = 0
    layer.fillColor = toColor!.CGColor
    layer.opaque = false
    containerLayer.addSublayer(layer)

    let animation = CABasicAnimation(keyPath: "transform")
    animation.duration = NSTimeInterval(animationDuration)
    animation.fromValue = NSValue(CATransform3D: CATransform3DIdentity)
    
    let endRadius = max(parent.frame.width, parent.frame.height)
    let multiplicator = endRadius / CGFloat(startRadius)
    animation.toValue = NSValue(CATransform3D: CATransform3DMakeScale(multiplicator, multiplicator, 1))
    animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
    animation.delegate = self
    animation.setValue(layer, forKey: "animationLayer")
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = false
    layer.addAnimation(animation, forKey: animationIdentificator)
    
    if let callback = animationDidStart {
      callback()
    }
    
    if showBorder && on {
      self.layer.borderWidth = 0.5
      self.layer.borderColor = UIColor.whiteColor().CGColor;
      self.layer.cornerRadius = frame.size.height / 2;
    } else {
      self.layer.borderWidth = 0
    }

  }
  
  override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
    CATransaction.begin()
    CATransaction.setDisableActions(true)
    containerLayer.backgroundColor = toColor?.CGColor
    CATransaction.commit()

    if let layer = anim.valueForKey("animationLayer") {
      layer.removeFromSuperlayer()
    }
    
    if let callback = animationDidStop {
      callback()
    }
    
  }
}
