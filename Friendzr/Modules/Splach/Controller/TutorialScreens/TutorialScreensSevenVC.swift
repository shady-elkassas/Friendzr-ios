//
//  TutorialScreensSevenVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 17/07/2022.
//

import UIKit

class TutorialScreensSevenVC: UIViewController {
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var skipBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var exitBTn: UIButton!
    
    @IBOutlet weak var lbl1: UILabel!
    @IBOutlet weak var lbl2: UILabel!
    @IBOutlet weak var lbl3: UILabel!
    @IBOutlet weak var lbl4: UILabel!
    @IBOutlet weak var lbl5: UILabel!
    
    @IBOutlet weak var Lbl1Top: NSLayoutConstraint!
    @IBOutlet weak var Lbl2Top: NSLayoutConstraint!
    @IBOutlet weak var Lbl3Top: NSLayoutConstraint!
    @IBOutlet weak var Lbl4Top: NSLayoutConstraint!
    @IBOutlet weak var Lbl5Top: NSLayoutConstraint!

    
    var selectVC:String = ""
    
    var myString1:String = "Be kind, respectful and considerate. \nPeople are more likely to want to connect!".localizedString
    var myString2:String = "Be real! Friendzr is an authentic community where we connect as friends.".localizedString
    var myString3:String = "Be genuine in your approaches, and actively participate in events and meetups.".localizedString
    var myString4:String = "No definitely means no! \nRespect others’ privacy and personal space as they request.".localizedString
    var myMutableString1 = NSMutableAttributedString()
    var myMutableString2 = NSMutableAttributedString()
    var myMutableString3 = NSMutableAttributedString()
    var myMutableString4 = NSMutableAttributedString()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        pageControl.currentPage = 6
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Defaults.availableVC = "TutorialScreensSixVC"
        print("availableVC >> \(Defaults.availableVC)")
        
        if selectVC == "MoreVC" {
            
            initBackButton()
            hideNavigationBar(NavigationBar: false, BackButton: false)
            nextBtn.isHidden = false
            skipBtn.isHidden = true
            exitBTn.isHidden = true
            
            nextBtn.setTitle("EXIT", for: .normal)
            nextBtn.backgroundColor = .clear
            nextBtn.setTitleColor(.black, for: .normal)
        }
        else {
            hideNavigationBar(NavigationBar: false, BackButton: true)
            nextBtn.isHidden = false
            skipBtn.isHidden = true
            exitBTn.isHidden = true
            
            nextBtn.setTitle("Create Your Profile", for: .normal)
        }
    }
    
    func setupViews() {
        nextBtn.cornerRadiusView(radius: 8)
        skipBtn.cornerRadiusView(radius: 8)
        exitBTn.cornerRadiusView(radius: 8)
        
        
        if Defaults.isIPhoneLessThan2500 {
            Lbl1Top.constant = 26
            Lbl2Top.constant = 8
            Lbl3Top.constant = 8
            Lbl4Top.constant = 8
            Lbl5Top.constant = 8
        }else {
            Lbl1Top.constant = 40
            Lbl2Top.constant = 20
            Lbl3Top.constant = 20
            Lbl4Top.constant = 20
            Lbl5Top.constant = 20
        }
        
        myMutableString1 = NSMutableAttributedString(string: myString1, attributes: [NSAttributedString.Key.font:UIFont(name: "Montserrat-Medium", size: 16.0)!])
        myMutableString1.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "Montserrat-Bold", size: 18)!, range: NSRange(location:0,length:7))

        myMutableString1.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.color("#71D992")!, range: NSRange(location:0,length:7))
        
        
        myMutableString2 = NSMutableAttributedString(string: myString2, attributes: [NSAttributedString.Key.font:UIFont(name: "Montserrat-Medium", size: 16.0)!])
        myMutableString2.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.color("#71D992")!, range: NSRange(location:0,length:8))
        myMutableString2.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "Montserrat-Bold", size: 18)!, range: NSRange(location:0,length:8))

        
        myMutableString3 = NSMutableAttributedString(string: myString3, attributes: [NSAttributedString.Key.font:UIFont(name: "Montserrat-Medium", size: 16.0)!])
        myMutableString3.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.color("#71D992")!, range: NSRange(location:0,length:10))
        myMutableString3.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "Montserrat-Bold", size: 18)!, range: NSRange(location:0,length:10))

        
        myMutableString4 = NSMutableAttributedString(string: myString4, attributes: [NSAttributedString.Key.font:UIFont(name: "Montserrat-Medium", size: 16.0)!])
        myMutableString4.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.color("#71D992")!, range: NSRange(location:0,length:23))
        myMutableString4.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "Montserrat-Bold", size: 18)!, range: NSRange(location:0,length:23))
        
        // set label Attribute
        lbl2.attributedText = myMutableString1
        lbl3.attributedText = myMutableString2
        lbl4.attributedText = myMutableString3
        lbl5.attributedText = myMutableString4
    }
    
    @IBAction func nextBtn(_ sender: Any) {
        if selectVC == "MoreVC" {
            Router().toMore()
        }else {
            Router().toEditProfileVC(needUpdate: true)
        }
    }
    
    
    @IBAction func skipBtn(_ sender: Any) {
        Router().toEditProfileVC(needUpdate: true)
    }
    
    @IBAction func exitBtn(_ sender: Any) {
        Router().toMore()
    }
    
}
