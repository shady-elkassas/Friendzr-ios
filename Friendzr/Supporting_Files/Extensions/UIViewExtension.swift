//
//  UIViewExtension.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 10/08/2021.
//

import Foundation
import UIKit

extension UIView {
    
    func setBorder( color: CGColor? = UIColor.setColor(lightColor: .lightGray, darkColor: .white).cgColor.copy(alpha: 0.5), width: CGFloat? = 0.5) {
        self.layer.borderColor = color ?? UIColor.setColor(lightColor: .lightGray, darkColor: .white).cgColor.copy(alpha: 0.5)
        self.layer.borderWidth = width ?? 0.5
    }
    
    func scale()  {
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.fromValue = 1.40
        pulse.toValue = 1.0
        pulse.duration = 1
        self.layer.add(pulse, forKey: nil)
    }
    
    func scalecontinus()  {
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.fromValue = 1
        pulse.toValue = 0.5
        pulse.duration = 0.8
        pulse.initialVelocity = 0.5
        //        pulse.damping = 0.5
        pulse.repeatCount = .infinity
        self.layer.add(pulse, forKey: nil)
    }
    
    
    func shadow( shadowOpacity: Float? = 0.5, color: CGColor? = UIColor.lightGray.withAlphaComponent(0.5).cgColor) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = color
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowOpacity = shadowOpacity ?? 0.5
    }
    
    func cornerRadiusView( radius: CGFloat? = nil) {
        self.layer.cornerRadius = radius ?? self.frame.width / 2
        self.layer.masksToBounds = true
    }
    
    func cornerRadiusForHeight() {
        self.layer.cornerRadius = self.frame.height / 2
        self.layer.masksToBounds = true
    }
    
    func setGradientBackground(colorTop: UIColor, colorBottom: UIColor) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorBottom.cgColor, colorTop.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.locations = [0, 0.5]
        gradientLayer.frame = bounds
       layer.insertSublayer(gradientLayer, at: 0)
    }
    
    /// [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    func setCornerforTop( withShadow: Bool? = false, cornerMask: CACornerMask? = [.layerMaxXMinYCorner, .layerMinXMinYCorner], radius: CGFloat? = 10) {
        self.layer.masksToBounds = true
        self.clipsToBounds = true
        self.layer.cornerRadius = radius ?? 10
        if withShadow ?? false {
            self.shadow()
        }
        if #available(iOS 11.0, *) {
            self.layer.maskedCorners = cornerMask ?? [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        }
    }
    
    /// [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    func setCornerforBottom( withShadow: Bool? = false, cornerMask: CACornerMask? = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner], radius: CGFloat? = 12) {
        self.layer.masksToBounds = true
        self.clipsToBounds = true
        self.layer.cornerRadius = radius ?? 12
        if withShadow ?? false {
            self.shadow()
        }
        if #available(iOS 11.0, *) {
            self.layer.maskedCorners = cornerMask ?? [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
    }
    
}

class RoundedView: UIView {
    override func awakeFromNib() {
        self.layer.cornerRadius = 8.0
        //        self.layer.borderColor = UIColor.color("#8E8E8E")?.cgColor
        //        self.layer.borderWidth = 0.5
    }
    
}

class RoundedBtn: UIButton {
    override func awakeFromNib() {
        self.layer.cornerRadius = 8.0
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 0.5
    }
    
}
class RoundedImg: UIImageView {
    override func awakeFromNib() {
        self.layer.cornerRadius = self.layer.frame.size.width / 2
    }
    
}


extension CALayer {
    func applySketchShadow(color: UIColor = .black,alpha: Float = 0.2,x: CGFloat = 0,y: CGFloat = 20,blur: CGFloat = 50,spread: CGFloat = 5) {
        masksToBounds = false
        shadowColor = color.cgColor
        shadowOpacity = alpha
        shadowOffset = CGSize(width: x, height: y)
        shadowRadius = blur / 1.5
        if spread == 0 {
            shadowPath = nil
        } else {
            let dx = -spread
            let rect = bounds.insetBy(dx: dx, dy: dx)
            shadowPath = UIBezierPath(rect: rect).cgPath
        }
    }
}
