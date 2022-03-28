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
    
    var myString : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        discView.cornerRadiusView(radius: 21)
        discView.setBorder()
        
        self.title = "Event Description"
        
        textView.text = myString
    }
    
    @IBAction func dismissBtn(_ sender: Any) {
        self.onDismiss()
    }
    
}
