//
//  FacialRecognitionPopUpView.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 01/03/2022.
//

import UIKit
import MediaPlayer
import AVFoundation


class FacialRecognitionPopUpView: UIViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var verifyBtn: UIButton!
    @IBOutlet weak var skipBtn: UIButton!
    @IBOutlet weak var removeImageBtn: UIButton!
    
    let imagePicker = UIImagePickerController()
    var faceImgOne: UIImage = UIImage()
    var faceImgTwo: UIImage = UIImage()
    var onFacialRecognitionCallBackResponse: ((_ faceImgOne:UIImage, _ faceImgTwo:UIImage,_ verify:Bool) -> ())?

    var onVerifyCallBackResponse: ((_ tapSelected: String) -> ())?

    var urlString = ""
    var player:AVPlayer = AVPlayer()
    var playerLayer = AVPlayerLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }
    
    func setupViews() {
        containerView.cornerRadiusView(radius: 12)
        profileImg.cornerRadiusForHeight()
        verifyBtn.cornerRadiusView(radius: 8)
        skipBtn.cornerRadiusView(radius: 8)
        removeImageBtn.cornerRadiusView(radius: 8)
        containerView.isHidden = false
        
        profileImg.image = faceImgOne
        profileImg.setBorder(color: UIColor.FriendzrColors.primary?.cgColor, width: 0.5)
    }
    
    @IBAction func verifyBtn(_ sender: Any) {
        self.dismiss(animated: true)
        onVerifyCallBackResponse?("verify")
    }
    
    
    @IBAction func skipBtn(_ sender: Any) {
        self.dismiss(animated: true)
        onVerifyCallBackResponse?("skip")
    }
    
    @IBAction func removeImageBtn(_ sender: Any) {
        self.dismiss(animated: true)
        onVerifyCallBackResponse?("remove")
    }
    
}


extension FacialRecognitionPopUpView : UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
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
