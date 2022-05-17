//
//  FacialRecognitionPopUpView.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 01/03/2022.
//

import UIKit

class FacialRecognitionPopUpView: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var okBtn: UIButton!
    
    var onOkCallBackResponse: ((_ okBtn: Bool) -> ())?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    func setupViews() {
        containerView.cornerRadiusView(radius: 12)
        okBtn.cornerRadiusView(radius: 8)
    }
    
    @IBAction func okBtn(_ sender: Any) {
        self.dismiss(animated: true)
        onOkCallBackResponse?(true)
    }
}
