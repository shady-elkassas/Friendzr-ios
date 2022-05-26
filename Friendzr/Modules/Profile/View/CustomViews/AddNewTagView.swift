//
//  AddNewTagView.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 02/01/2022.
//

import Foundation
import UIKit


class AddNewTagView: UIView {
    
    @IBOutlet weak var titleViewLbl: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var newTagTxt: UITextField!
    @IBOutlet weak var confirmBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var textBorderView: UIView!
    
    var HandleConfirmBtn: (()->())?
    var HandleCancelBtn: (()->())?

    override func awakeFromNib() {
        
        textBorderView.setBorder()
        textBorderView.cornerRadiusView(radius: 8)
        confirmBtn.cornerRadiusView(radius: 8)
        cancelBtn.cornerRadiusView(radius: 8)
//        newTagTxt.addDoneOnKeyboard(withTarget: self, action: #selector(dismissKeyboard))
    }
    
    @IBAction func confirmBtn(_ sender: Any) {
        HandleConfirmBtn?()
    }
    
    @IBAction func cancelBtn(_ sender: Any) {
        HandleCancelBtn?()
        // handling code
        UIView.animate(withDuration: 0.3, animations: {
            self.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.alpha = 0
        }) { (success: Bool) in
            self.removeFromSuperview()
            self.alpha = 1
            self.transform = CGAffineTransform.init(scaleX: 1, y: 1)
        }
    }
}
