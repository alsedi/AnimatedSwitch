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

typealias VoidClosure = () -> ()

enum AnimatedSwitchShapeType {
    case Round
    case Diamond
    case Star
    case Custom(UIBezierPath)
}

extension AnimatedSwitchShapeType {
    
    private func polygon(inCircleOfRadius radius: Double, vertices: Int, offset: Double = 0) -> [CGPoint] {
        let step = M_PI * 2 / Double(vertices)
        let x: Double = 0
        let y: Double = 0
        var points = [CGPoint]()
        for i in 0...vertices {
            let xv = x - radius * cos(step * Double(i) + (step * offset))
            let yv = y - radius * sin(step * Double(i) + (step * offset))
            points.append(CGPoint(x: xv, y: yv))
        }
        return points
    }
    
    private func starShape(radius: Double, vertices: Int) -> UIBezierPath {
        let path = UIBezierPath()
        let externalVertices = polygon(inCircleOfRadius: radius, vertices: vertices)
        let internalVertices = polygon(inCircleOfRadius: radius/2, vertices: vertices, offset: 0.5)
        
        if (externalVertices.count >= 3){
            path.moveToPoint(externalVertices[0])
            for i in 0..<externalVertices.count-1 {
               path.addLineToPoint(internalVertices[i])
               path.addLineToPoint(externalVertices[i + 1])
            }
            path.closePath()
        }
        return path
    }
    
    func scaleFactor(from: Double, to: CGRect) -> CGFloat {
        var endRadius: CGFloat = sqrt(to.width * to.width + to.height * to.height) / 2
        print("From \(from)")
        print("Initial \(endRadius)")
        
        switch (self) {
        case .Star:
            endRadius = endRadius / 2
        default:
            break
        }
        print("Adjusted \(endRadius)")
        print("Mult \(endRadius / CGFloat(from))")

        
        return endRadius / CGFloat(from)
    }
    
    func bezierPathInRect(rect: CGRect) -> UIBezierPath {
        let centerX = rect.origin.x + rect.width / 2
        let centerY = rect.origin.y + rect.height / 2
        let size = sqrt(rect.width * rect.width / 4 + rect.height *  rect.height / 4)
        switch self {
        case .Diamond:
            let path = UIBezierPath(rect: CGRectMake(0, 0, size, size));
            path.applyTransform(CGAffineTransformConcat(CGAffineTransformMakeRotation(CGFloat(M_PI_4)), CGAffineTransformMakeTranslation(centerX, rect.origin.y)))
            return path
        case .Star:
            let path = starShape(Double(50), vertices: 5)
            path.applyTransform(CGAffineTransformMakeTranslation(centerX, centerY))
            return path
        case .Custom(let path):
            path.applyTransform(CGAffineTransformMakeTranslation(centerX, centerY))
            return path
        default:
            return UIBezierPath(ovalInRect: rect)
        }
    }
}

@IBDesignable class AnimatedSwitch: UISwitch {
    private var originalParentBackground: UIColor?
    private var toColor: UIColor?
    private let animationIdentificator = "animatedSwitch"
    private let containerLayer = CAShapeLayer()
    
    @IBInspectable var color: UIColor = UIColor.clearColor()
    @IBInspectable var startRadius: Double = 15
    @IBInspectable var animationDuration: Double = 0.25
    
    @IBInspectable var showBorder: Bool = true
    @IBInspectable var borderColor: UIColor = UIColor.whiteColor()
    
    var shape: AnimatedSwitchShapeType = .Diamond
    
    
    var isAnimating: Bool = false
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
        
        drawBorder()
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
        layer.path = shape.bezierPathInRect(correctedFrame).CGPath
        layer.position = self.center
        layer.lineWidth = 0
        layer.fillColor = toColor!.CGColor
        containerLayer.addSublayer(layer)
        
        let animation = CABasicAnimation(keyPath: "transform")
        animation.duration = NSTimeInterval(animationDuration)
        animation.fromValue = NSValue(CATransform3D: CATransform3DIdentity)
        
        let multiplicator = shape.scaleFactor(startRadius / 2, to: parent.frame)
        animation.toValue = NSValue(CATransform3D: CATransform3DMakeScale(multiplicator, multiplicator, 1))
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        animation.delegate = self
        animation.setValue(layer, forKey: "animationLayer")
        animation.fillMode = kCAFillModeForwards;
        animation.removedOnCompletion = false
        layer.addAnimation(animation, forKey: animationIdentificator)
        
        isAnimating = true
        
        if let callback = animationDidStart {
            callback()
        }
        
        drawBorder()
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        containerLayer.backgroundColor = toColor?.CGColor
        CATransaction.commit()
        
        if let layer = anim.valueForKey("animationLayer") {
            layer.removeFromSuperlayer()
            isAnimating = false
        }
        
        if let callback = animationDidStop {
            callback()
        }
    }
    
    func drawBorder() {
        if showBorder && on {
            self.layer.borderWidth = 0.5
            self.layer.borderColor = self.borderColor.CGColor;
            self.layer.cornerRadius = frame.size.height / 2;
        } else {
            self.layer.borderWidth = 0
        }

    }
}
