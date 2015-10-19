//
//  CircleView.swift
//  Bandwidth
//
//  Created by Dylan Waits on 10/18/15.
//  Copyright © 2015 Dylan Waits. All rights reserved.
//

import UIKit

class CircleView: UIView {
    
    var progress: Double = 0

    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        let radius: CGFloat = 120.0
        let center = CGPoint(x: 120, y: 120)
        
        // Color Declarations
        let color = UIColor(red: 0.929, green: 0.929, blue: 0.929, alpha: 1.000)
        
        // Oval Drawing
        let ovalPath = UIBezierPath(ovalInRect: CGRectMake(0, 0, 240, 240))
        color.setFill()
        ovalPath.fill()
        
        // Color Declarations
        let color2 = UIColor(red: 0.494, green: 0.827, blue: 0.129, alpha: 1.000)
        
        // Wedge Drawing
        let wedge = UIBezierPath(arcCenter: center, radius: radius, startAngle: degreesToRadians(-90), endAngle: radianProgress(), clockwise: true)
        wedge.addLineToPoint(center)
        color2.setFill()
        wedge.fill()
    }
    
    private func degreesToRadians(degrees: CGFloat) -> CGFloat {
        return CGFloat(3.14159 * degrees / 180.0)
    }
    
    private func decimalToDegrees(decimal: Double) -> CGFloat {
        return CGFloat(decimal * 360.0)
    }
    
    private func radianProgress() -> CGFloat {
        return degreesToRadians(decimalToDegrees(progress) - 90)
    }

}
