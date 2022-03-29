//
//  ExpandDescriptionVC.swift
//  Friendzr
//
//  Created by Shady Elkassas on 28/03/2022.
//

import UIKit

class ExpandDescriptionVC: UIViewController {
    
    @IBOutlet weak var dismissBtn: UIButton!
    @IBOutlet weak var hideView: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var discView: UIView!
    
    @IBOutlet weak var viewHeightLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var closeBtn: UIButton!
    var myString : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        discView.cornerRadiusView(radius: 21)
        discView.setBorder()
        
        self.title = "Event Description"
        
        textView.text = myString
        
        let height = myString.height(withConstrainedWidth: textView.frame.width, font: UIFont(name: "Montserrat-Medium", size: 14)!)
        
        viewHeightLayoutConstraint.constant = height + 20
        
        closeBtn.tintColor = .white
        closeBtn.cornerRadiusForHeight()
    }
    
    @IBAction func dismissBtn(_ sender: Any) {
        self.onDismiss()
    }
    
    @IBAction func closeBtn(_ sender: Any) {
        self.onDismiss()
    }
}

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
    
        return ceil(boundingBox.height)
    }

    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)

        return ceil(boundingBox.width)
    }
}
