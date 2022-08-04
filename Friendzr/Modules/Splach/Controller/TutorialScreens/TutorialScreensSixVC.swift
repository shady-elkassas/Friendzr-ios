//
//  TutorialScreensSixVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 14/07/2022.
//

import UIKit
import MediaPlayer
import AVFoundation

class TutorialScreensSixVC: UIViewController {
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var skipBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var exitBTn: UIButton!
    @IBOutlet weak var animationsView: UIView!

    var selectVC:String = ""
    var player:AVPlayer = AVPlayer()
    var playerLayer = AVPlayerLayer()
    var linkClickedVM:LinkClickViewModel = LinkClickViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        pageControl.currentPage = 5
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Defaults.availableVC = "TutorialScreensSixVC"
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
        guard let path = Bundle.main.path(forResource: "Tutorial6", ofType:"mov") else {
            debugPrint("Tutorial6.mp4 not found")
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
    
    //MARK: - Actions
    @IBAction func nextBtn(_ sender: Any) {
        if selectVC == "MoreVC" {
            guard let vc = UIViewController.viewController(withStoryboard: .TutorialScreens, AndContollerID: "TutorialScreensSevenVC") as? TutorialScreensSevenVC else {return}
            vc.selectVC = "MoreVC"
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else {
            Router().toSTutorialScreensSevenVC()
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
