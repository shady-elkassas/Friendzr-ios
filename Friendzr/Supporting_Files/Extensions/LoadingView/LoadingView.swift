//
//  LoadingView.swift
//  iOS_Customer_App
//
//  Created by Muhammad Sabri Saad on 10/08/2021.
//

import UIKit

class LoadingView: UIView {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadingNamedLabel: UILabel!
    var loadingName: String = "" {
        didSet{
            self.loadingNamedLabel.text = loadingName
        }
    }
    override func draw(_ rect: CGRect) {
        mainView.scale()
        activityIndicator.scalecontinus()
    }
}
