//
//  ForgetAddPictureVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 09/02/2023.
//

import UIKit

class ForgetAddPictureVC: UIViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var verifyBtn: UIButton!
    @IBOutlet weak var completeLaterBtn: UIButton!
    
    
    var onForgetAddPictureCallBackResponse: ((_ tapSelected: String) -> ())?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
    }
    
    
    func setupViews() {
        containerView.cornerRadiusView(radius: 12)
        verifyBtn.cornerRadiusView(radius: 8)
        completeLaterBtn.cornerRadiusView(radius: 8)
        containerView.isHidden = false
    }
    
    @IBAction func verifyBtn(_ sender: Any) {
        self.dismiss(animated: true)
        onForgetAddPictureCallBackResponse?("UploadAndVerify")
    }
    
    @IBAction func completeLaterBtn(_ sender: Any) {
        self.dismiss(animated: true)
        onForgetAddPictureCallBackResponse?("CompleteLater")
    }
}
