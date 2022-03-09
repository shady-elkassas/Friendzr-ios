/*
 MIT License

 Copyright (c) 2017-2019 MessageKit

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import UIKit

open class LinkPreviewView: UIView {
    lazy var imageView: UIImageView = {
        let imageView: UIImageView = .init()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    lazy var titleLabel: UILabel = {
        let label: UILabel = .init()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var teaserLabel: UILabel = {
        let label: UILabel = .init()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var peopleLabel: UILabel = {
        let label: UILabel = .init()
        label.numberOfLines = 0
        label.text = "New Lable"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var dateLabel: UILabel = {
        let label: UILabel = .init()
        label.numberOfLines = 0
        label.text = "New Lable"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var domainLabel: UILabel = {
        let label: UILabel = .init()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var gradientView: GradientView2 = {
        let view: GradientView2 = .init(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.firstColor = UIColor.white
        view.secondColor = UIColor.black
        view.vertical = true
        return view
    }()
    
    private lazy var contentView: UIView = {
        let view: UIView = .init(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(view)
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: topAnchor),
            view.leadingAnchor.constraint(equalTo: leadingAnchor,
                                          constant: 0),
            view.trailingAnchor.constraint(equalTo: trailingAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        return view
    }()

    init() {
        super.init(frame: .zero)

        contentView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
        
        contentView.addSubview(gradientView)
        NSLayoutConstraint.activate([
            gradientView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            gradientView.heightAnchor.constraint(greaterThanOrEqualToConstant: 85),
            gradientView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor),
            gradientView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
        
        contentView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: 10)
        ])

        contentView.addSubview(teaserLabel)
        NSLayoutConstraint.activate([
            teaserLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            teaserLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 3),
            teaserLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,constant: -10)
        ])
        
        
     
        contentView.addSubview(peopleLabel)
        NSLayoutConstraint.activate([
            peopleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: -10),
            peopleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,constant: -10)
        ])
        
        contentView.addSubview(dateLabel)
        NSLayoutConstraint.activate([
            dateLabel.leadingAnchor.constraint(equalTo: peopleLabel.leadingAnchor),
            dateLabel.bottomAnchor.constraint(equalTo: peopleLabel.topAnchor,constant: -4)
        ])
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class GradientView2: UIView {
   @IBInspectable var firstColor: UIColor = UIColor.clear
   @IBInspectable var secondColor: UIColor = UIColor.black

   @IBInspectable var vertical: Bool = true

   lazy var gradientLayer: CAGradientLayer = {
       let layer = CAGradientLayer()
       layer.colors = [firstColor.cgColor, secondColor.cgColor]
       layer.startPoint = CGPoint.zero
       return layer
   }()

   //MARK: -

   required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)

       applyGradient()
   }

   override init(frame: CGRect) {
       super.init(frame: frame)

       applyGradient()
   }

   override func prepareForInterfaceBuilder() {
       super.prepareForInterfaceBuilder()
       applyGradient()
   }

   override func layoutSubviews() {
       super.layoutSubviews()
       updateGradientFrame()
   }

   //MARK: -

   func applyGradient() {
       updateGradientDirection()
       layer.sublayers = [gradientLayer]
   }

   func updateGradientFrame() {
       gradientLayer.frame = bounds
   }

   func updateGradientDirection() {
       gradientLayer.endPoint = vertical ? CGPoint(x: 0, y: 1) : CGPoint(x: 1, y: 0)
   }
}
