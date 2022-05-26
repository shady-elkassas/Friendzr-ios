//
//  ExpandDescriptionVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 28/03/2022.
//

import UIKit

class ExpandDescriptionVC: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var dismissBtn: UIButton!
    @IBOutlet weak var hideView: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var discView: UIView!
    @IBOutlet weak var viewHeightLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var closeBtn: UIButton!
    
    //MARK: - Properties
    var myString : String = ""
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        discView.cornerRadiusView(radius: 21)
        discView.setBorder()
        
        self.title = "Event Description"
        
        textView.text = myString
        closeBtn.tintColor = .white
        closeBtn.cornerRadiusForHeight()
        textView.addDoneOnKeyboard(withTarget: self, action: #selector(dismissKeyboard))
    }
    
    //MARK: - Actions
    @IBAction func dismissBtn(_ sender: Any) {
        self.onDismiss()
    }
    
    @IBAction func closeBtn(_ sender: Any) {
        self.onDismiss()
    }
}

//MARK: - extension Calculate Height Or Width for any lable
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
