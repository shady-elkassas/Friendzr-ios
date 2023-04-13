//
//  SendMessageWithSendRequestView.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 05/03/2023.
//

import UIKit

class SendMessageWithSendRequestView: UIView {
    
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var skipBtn: UIButton!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var messageBoxView: UIView!
    @IBOutlet weak var messageTxtView: UITextView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var textViewCountLbl: UILabel!
    
    @IBOutlet weak var sendReqLbl: UILabel!
    @IBOutlet weak var hideBtn: UIButton!
    var HandleSendBtn: (()->())?
    var HandleSkipBtn: (()->())?
    var HandleHideBtn: (()->())?
    
    override func awakeFromNib() {
        containerView.shadow()
        messageBoxView.setBorder()
        containerView.cornerRadiusView(radius: 8)
        messageBoxView.cornerRadiusView(radius: 6)
        //        skipBtn.cornerRadiusView(radius: 17)
        sendBtn.cornerRadiusView(radius: 17)
        sendReqLbl.cornerRadiusView(radius: 15)
        
        messageTxtView.delegate = self
    }
    
    @IBAction func skipBtn(_ sender: Any) {
        HandleSkipBtn?()
        // handling code
        UIView.animate(withDuration: 0.3, animations: {
            self.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.alpha = 0
        }) { (success: Bool) in
            self.removeFromSuperview()
            self.alpha = 1
            self.transform = CGAffineTransform.init(scaleX: 1, y: 1)
        }
        self.messageTxtView.text = ""
        headerLabel.isHidden = false
        //        messageTxtView.text.count = 0
        textViewCountLbl.text = "0"
    }
    
    @IBAction func sendBtn(_ sender: Any) {
        HandleSendBtn?()
        // handling code
        UIView.animate(withDuration: 0.3, animations: {
            self.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.alpha = 0
        }) { (success: Bool) in
            self.removeFromSuperview()
            self.alpha = 1
            self.transform = CGAffineTransform.init(scaleX: 1, y: 1)
        }
        
        self.messageTxtView.text = ""
        headerLabel.isHidden = false
        //        messageTxtView.text.count = 0
        textViewCountLbl.text = "0"
    }
    
    @IBAction func hideBtnView(_ sender: Any) {
        // handling code
        UIView.animate(withDuration: 0.3, animations: {
            self.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.alpha = 0
        }) { (success: Bool) in
            self.removeFromSuperview()
            self.alpha = 1
            self.transform = CGAffineTransform.init(scaleX: 1, y: 1)
        }
        
        self.messageTxtView.text = ""
        headerLabel.isHidden = false
        //        messageTxtView.text.count = 0
        textViewCountLbl.text = "0"
    }
}

extension SendMessageWithSendRequestView : UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        headerLabel.isHidden = !textView.text.isEmpty
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        print("\(textView.text.count)")
        textViewCountLbl.text = "\(textView.text.count + 1)"
        return newText.count < 160
    }
}
