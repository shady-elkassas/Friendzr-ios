//
//  DegreeScaleView.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 30/09/2021.
//

import UIKit

class DegreeScaleView: UIView {
    
    /// background view
    private lazy var backgroundView: UIView = {
        let v = UIView(frame: bounds)
        return v
    }()
    
    /// Horizontal view
    private lazy var levelView: UIView = {
        let levelView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width / 2 - 50, height: 1))
        levelView.center = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
        levelView.backgroundColor = .white
        return levelView
    }()
    
    /// vertical view
    private lazy var verticalView: UIView = {
        let verticalView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: self.frame.size.height / 2 - 50))
        verticalView.center = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
        verticalView.backgroundColor = .white
        return verticalView
    }()
    
    /// Pointer view
    private lazy var lineView: UIView = {
        let lineView = UIView(frame: CGRect(x: self.frame.size.width / 2 - 1.5, y: 20, width: 3, height: 60))
        lineView.backgroundColor = .white
        return lineView
    }()
    
    /// Compass triangle view
    private lazy var compassTriangleView: UIView = {
        let triangle = UIView(frame: CGRect(x: 0, y: 0, width: screenW, height: screenW))
        triangle.backgroundColor = .clear
        return triangle
    }()
    
    /// Red triangle view
    private lazy var redTriangleView = UIView()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        clipsToBounds = true
        layer.cornerRadius = frame.size.width / 2
        addSubview(backgroundView)
        addSubview(levelView)
        addSubview(verticalView)
        insertSubview(lineView, at: 0)
        configScaleDial()
        addSubview(compassTriangleView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - Update multiple times
extension DegreeScaleView {
    /// Calculate the center coordinates
        ///
        ///-Parameters:
        ///-center: center point
        ///-angle: angle
        ///-scale: scale
    /// - Returns: CGPoint
    private func calculateTextPositon(withArcCenter center: CGPoint, andAngle angle: CGFloat, andScale scale: CGFloat) -> CGPoint {
        let x = (self.frame.size.width / 2 - 50) * scale * CGFloat(cosf(Float(angle)))
        let y = (self.frame.size.width / 2 - 50) * scale * CGFloat(sinf(Float(angle)))
        return CGPoint(x: center.x + x, y: center.y + y)
    }
    
    /// Rotate to reset the direction of the scale mark
        ///
        ///-Parameter heading: heading
    public func resetDirection(_ heading: CGFloat) {
        backgroundView.transform = CGAffineTransform(rotationAngle: heading)
        for label in backgroundView.subviews {
            backgroundView.subviews[1].transform = .identity    // The red triangle view does not rotate.
            label.transform = CGAffineTransform(rotationAngle: -heading)
        }
    }
    
}

//MARK: - Configure
extension DegreeScaleView {
    
    /// Configure the scale table
    private func configScaleDial() {
        
        /// 360 degrees
        let degree_360: CGFloat = CGFloat.pi
        
        /// 180 degree
        let degree_180: CGFloat = degree_360 / 2
        
        /// angle
        let angle: CGFloat = degree_360 / 90
        
        /// Direction array
        let directionArray = ["N", "E", "S", "W"]
        
        /// point
        let po = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        
        //Draw a circle, draw an arc every 2°, a total of 180
        for i in 0 ..< 180 {
            
            /// Starting angle
            let startAngle: CGFloat = -(degree_180 + degree_360 / 180 / 2) + angle * CGFloat(i)
            
            /// End angle
            let endAngle: CGFloat = startAngle + angle / 2
            
            // Create a path object
            let bezPath = UIBezierPath(arcCenter: po, radius: frame.size.width / 2 - 70, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            
            /// Deformation layer
            let shapeLayer = CAShapeLayer()
            
            if i % 15 == 0 {
                // Set the stroke color
                shapeLayer.strokeColor = UIColor.white.cgColor
                shapeLayer.lineWidth = 20
            }else {
                shapeLayer.strokeColor = UIColor.gray.cgColor
                shapeLayer.lineWidth = 20
            }
            shapeLayer.path = bezPath.cgPath
            shapeLayer.fillColor = UIColor.clear.cgColor    // Set fill path color
            backgroundView.layer.addSublayer(shapeLayer)
            
            //Scale labeling
            if i % 15 == 0 {
                ///Marking of the scale 0 30 60...
                var tickText = "\(i * 2)"
                
                let textAngle: CGFloat = startAngle + (endAngle - startAngle) / 2
                
                let point: CGPoint = calculateTextPositon(withArcCenter: po, andAngle: textAngle, andScale: 1.15)
                
                // UILabel
                let label = UILabel(frame: CGRect(x: point.x, y: point.y, width: 30, height: 20))
                label.center = point
                label.text = tickText
                label.textColor = .white
                label.font = UIFont.systemFont(ofSize: 15)
                label.textAlignment = .center
                backgroundView.addSubview(label)
                
                if i % 45 == 0 {    //North East South West
                    tickText = directionArray[i / 45]
                    
                    let point2: CGPoint = calculateTextPositon(withArcCenter: po, andAngle: textAngle, andScale: 0.65)
                    // UILabel
                    let label2 = UILabel(frame: CGRect(x: point2.x, y: point2.y, width: 30, height: 20))
                    label2.center = point2
                    label2.text = tickText
                    label2.textColor = .white
                    label2.font = UIFont.systemFont(ofSize: 27)
                    label2.textAlignment = .center
                    
                    if tickText == "N" {
                        DrawRedTriangleView(point)
                    }
                    backgroundView.addSubview(label2)
                }
            }
        }
    }
    
    /// Draw a red triangle view
    private func DrawRedTriangleView(_ point: CGPoint) {
        redTriangleView = UIView(frame: CGRect(x: point.x, y: point.y, width: 12, height: 12))
        redTriangleView.center = CGPoint(x: point.x, y: point.y + 17)
        redTriangleView.backgroundColor = .clear
        backgroundView.addSubview(redTriangleView)
        
        // draw a triangle
        let trianglePath = UIBezierPath()
        var point = CGPoint(x: 0, y: 12)
        trianglePath.move(to: point)
        point = CGPoint(x: 12 / 2, y: 0)
        trianglePath.addLine(to: point)
        point = CGPoint(x: 12, y: 12)
        trianglePath.addLine(to: point)
        trianglePath.close()
        let triangleLayer = CAShapeLayer()
        triangleLayer.path = trianglePath.cgPath
        triangleLayer.fillColor = UIColor.red.cgColor
        redTriangleView.layer.addSublayer(triangleLayer)
    }
    
}
