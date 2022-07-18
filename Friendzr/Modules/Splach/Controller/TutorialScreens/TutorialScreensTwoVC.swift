//
//  TutorialScreensTwoVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 14/07/2022.
//

import UIKit
import MediaPlayer
import AVFoundation

class TutorialScreensTwoVC: UIViewController {
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var skipBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var exitBTn: UIButton!
    @IBOutlet weak var animationsView: UIView!
    
    var selectVC:String = ""
    var player:AVPlayer = AVPlayer()
    var playerLayer = AVPlayerLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        pageControl.currentPage = 1
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Defaults.availableVC = "TutorialScreensTwoVC"
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
        guard let path = Bundle.main.path(forResource: "Tutorial2", ofType:"mov") else {
            debugPrint("Tutorial2.mp4 not found")
            return
        }
        
        player = AVPlayer(url: URL(fileURLWithPath: path))
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        playerLayer.backgroundColor = UIColor.clear.cgColor
        playerLayer.contentsFormat = .RGBA16Float
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
            guard let vc = UIViewController.viewController(withStoryboard: .TutorialScreens, AndContollerID: "TutorialScreensThreeVC") as? TutorialScreensThreeVC else {return}
            vc.selectVC = "MoreVC"
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else {
            Router().toSTutorialScreensThreeVC()
        }
    }
    
    
    @IBAction func skipBtn(_ sender: Any) {
        Router().toEditProfileVC(needUpdate: true)
    }
    
    @IBAction func exitBtn(_ sender: Any) {
        Router().toMore()
    }
}
