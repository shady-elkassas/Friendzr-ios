//
//  TutorialScreensFourVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 14/07/2022.
//

import UIKit
import MediaPlayer
import AVFoundation

class TutorialScreensFourVC: UIViewController {
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var skipBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var lbl: UILabel!
    @IBOutlet weak var exitBTn: UIButton!
    @IBOutlet weak var animationsView: UIView!

    var selectVC:String = ""
    var player:AVPlayer = AVPlayer()
    var playerLayer = AVPlayerLayer()
    var linkClickedVM:LinkClickViewModel = LinkClickViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        pageControl.currentPage = 3
                
        let attachment = NSTextAttachment()
        attachment.image = UIImage(named: "like_ic")
        let attachmentString = NSAttributedString(attachment: attachment)
        let str = NSAttributedString(string: " to sort your feed by interest match, then click a profile to see which interests you share!")
        let myString = NSMutableAttributedString(string: "Toggle on ")
        myString.append(attachmentString)
        myString.append(str)
        lbl.attributedText = myString
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Defaults.availableVC = "TutorialScreensFourVC"
        print("availableVC >> \(Defaults.availableVC)")
  
        if selectVC == "MoreVC" {
            initBackButton()
            hideNavigationBar(NavigationBar: false, BackButton: false)
            skipBtn.isHidden = true
            exitBTn.isHidden = false
        }
        else {
            hideNavigationBar(NavigationBar: false, BackButton: true)
            skipBtn.isHidden = false
            exitBTn.isHidden = true
        }
        
        setupAnimations()
    }
    
    func setupAnimations() {
        guard let path = Bundle.main.path(forResource: "Tutorial4", ofType:"mov") else {
            debugPrint("Tutorial4.mp4 not found")
            return
        }
        
        player = AVPlayer(url: URL(fileURLWithPath: path))
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        playerLayer.backgroundColor = UIColor.clear.cgColor
        animationsView.layer.addSublayer(playerLayer)
        player.play()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer.frame = animationsView.layer.bounds
    }
    
    
    func setupViews() {
        nextBtn.cornerRadiusView(radius: 8)
        skipBtn.cornerRadiusView(radius: 8)
        exitBTn.cornerRadiusView(radius: 8)        
    }
    
    
    @IBAction func nextBtn(_ sender: Any) {
        if selectVC == "MoreVC" {
            guard let vc = UIViewController.viewController(withStoryboard: .TutorialScreens, AndContollerID: "TutorialScreensFiveVC") as? TutorialScreensFiveVC else {return}
            vc.selectVC = "MoreVC"
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else {
            Router().toSTutorialScreensFiveVC()
        }
    }
    
    @IBAction func skipBtn(_ sender: Any) {
        DispatchQueue.main.async {
            self.linkClickedVM.linkClickRequest(Key: "SkipTutorial") { error, data in
                if let error = error {
                    DispatchQueue.main.async {
                        self.view.makeToast(error)
                    }
                    return
                }
                
                guard let _ = data else {
                    return
                }
            }
        }
        
        Router().toEditProfileVC(needUpdate: true)
    }
    
    @IBAction func exitBtn(_ sender: Any) {
        Router().toMore()
    }
}
