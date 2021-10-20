//
//  ShowImageVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 25/08/2021.
//

import UIKit

class ShowImageVC: UIViewController {
    
    var imgStr: UIImage!
    var imageView:UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        view.backgroundColor = .white
        initBackButton()
        title = "Show Image"
        clearNavigationBar()
        
        
        imageView = UIImageView(image: imgStr)
        view.addSubview(imageView)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: view.bounds.height).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: view.bounds.width).isActive = true
        imageView.cornerRadiusView(radius: 30)

        imageView.isUserInteractionEnabled = true
        
        imageView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture)))
        
    }
    
    @objc func handlePanGesture(gesture:UIPanGestureRecognizer) {
        
        if gesture.state == .began {
            print("began")
        }else if gesture.state == .changed {
            print("changed")
            let translation = gesture.translation(in: self.view)
            imageView.transform = CGAffineTransform(translationX: translation.x, y: translation.y)
        }else if gesture.state == .ended {
            print("ended")
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 1, options: .curveEaseIn) {
                self.imageView.transform = .identity
            }
        }
    }
}
