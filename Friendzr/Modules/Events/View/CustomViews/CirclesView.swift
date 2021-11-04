//
//  CirclesView.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 18/08/2021.
//

import Foundation
import UIKit

class CirclesView: UIView {
    
    override func draw(_ rect: CGRect) {
        for i in 0..<3 {
            let Circles1 = UIBezierPath(arcCenter: CGPoint(x: bounds.width/2, y: bounds.height/2), radius: 50 + CGFloat(i)  * 20, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
            
            Circles1.lineWidth = 3
            UIColor.red.setStroke()
            Circles1.stroke()
        }
    }
}
