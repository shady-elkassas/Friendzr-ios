//
//  FacialRecognitionPopUpView2.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 01/03/2022.
//

import UIKit
import MediaPlayer
import AVFoundation


class FacialRecognitionPopUpView2: UIViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var verifyBtn: UIButton!
    @IBOutlet weak var VideoContainerView: UIView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var nextBtn: UIButton!
    
    
    
    let imagePicker = UIImagePickerController()
    var faceImgOne: UIImage = UIImage()
    var faceImgTwo: UIImage = UIImage()
    var onFacialRecognitionCallBackResponse: ((_ faceImgOne:UIImage, _ faceImgTwo:UIImage,_ verify:Bool) -> ())?

    var onVerifyCallBackResponse: ((_ okBtn: Bool) -> ())?

    var urlString = ""
    var player:AVPlayer = AVPlayer()
    var playerLayer = AVPlayerLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }
    
    func setupViews() {
        containerView.cornerRadiusView(radius: 12)
        VideoContainerView.cornerRadiusView(radius: 12)
        videoView.cornerRadiusView(radius: 12)
        profileImg.cornerRadiusForHeight()
        verifyBtn.cornerRadiusView(radius: 8)
        nextBtn.cornerRadiusView(radius: 8)
        videoView.shadow()
        VideoContainerView.isHidden = true
        containerView.isHidden = false
        
        profileImg.image = faceImgOne
        profileImg.setBorder(color: UIColor.FriendzrColors.primary?.cgColor, width: 0.5)
        
//        guard let path = Bundle.main.path(forResource: "FacialRecognitionVideo", ofType:"mp4") else {
//            debugPrint("Logo-Animation4.mp4 not found")
//            return
//        }
//
//        player = AVPlayer(url: URL(fileURLWithPath: path))
//        playerLayer = AVPlayerLayer(player: player)
//        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
//        videoView.layer.addSublayer(playerLayer)
//        player.play()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer.frame = videoView.layer.bounds
    }
    
    @IBAction func verifyBtn(_ sender: Any) {
        self.dismiss(animated: true)
        onVerifyCallBackResponse?(true)
    }
    
    
    @IBAction func nextBtn(_ sender: Any) {
        VideoContainerView.isHidden = true
        containerView.isHidden = false
    }
}


extension FacialRecognitionPopUpView2 : UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image = info[.originalImage] as! UIImage
        picker.dismiss(animated:true, completion: {
            self.faceImgTwo = image
            self.onFacialRecognitionCallBackResponse?(self.faceImgOne,self.faceImgTwo,true)
            self.onPopup()
        })
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated:true, completion: nil)
    }
}
