//
//  LandingPageVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 17/07/2022.
//

import UIKit
import MediaPlayer
import AVFoundation

class LandingPageVC: UIViewController {
    
    @IBOutlet weak var takeTourBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var signupBtn: UIButton!
    @IBOutlet weak var videoView: UIView!
    
    @IBOutlet weak var videoTopConstraint: NSLayoutConstraint!
    
    var player:AVPlayer = AVPlayer()
    var playerLayer = AVPlayerLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let path = Bundle.main.path(forResource: "FriendzrlogomarkwhiteBG", ofType:"mp4") else {
            debugPrint("FriendzrlogomarkwhiteBG.mp4 not found")
            return
        }
        
        player = AVPlayer(url: URL(fileURLWithPath: path))
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        playerLayer.backgroundColor = UIColor.white.cgColor
        videoView.layer.addSublayer(playerLayer)
        
        //        NotificationCenter.default.addObserver(self, selector:  #selector(playerItemDidReachEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player.currentItem)
        player.play()
        
        //        let imageData = try? Data(contentsOf: Bundle.main.url(forResource: "Friendzrlogomark", withExtension: "gif")!)
        //        let advTimeGif = UIImage.sd_image(withGIFData: imageData!)
        //        let imageView2 = UIImageView(image: advTimeGif)
        //        imageView2.frame = CGRect(x: 0, y: 0, width:
        //                                    self.videoView.frame.size.width, height: self.videoView.frame.size.height)
        //        videoView.addSubview(imageView2)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer.frame = videoView.layer.bounds
    }
    
    @objc func playerItemDidReachEnd(notification: NSNotification) {
        //        self.player.seek(to: CMTime.zero)
        //        self.player.play()
    }
    
    func setupView() {
        takeTourBtn.cornerRadiusForHeight()
        signupBtn.cornerRadiusForHeight()
        
        if Defaults.isIPhoneLessThan2500 {
            videoTopConstraint.constant = 0
        }else {
            videoTopConstraint.constant = 40
        }
    }
    
    @IBAction func signupBtn(_ sender: Any) {
        guard let vc = UIViewController.viewController(withStoryboard: .Register, AndContollerID: "OptionsSignUpVC") as? OptionsSignUpVC else {return}
        Defaults.isFirstLogin = false
        vc.isOpenVC = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func takeTourBtn(_ sender: Any) {
        Router().toFeed()
    }
    
    @IBAction func loginBtn(_ sender: Any) {
        guard let vc = UIViewController.viewController(withStoryboard: .Login, AndContollerID: "LoginVC") as? LoginVC else {return}
        Defaults.isFirstLogin = false
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
