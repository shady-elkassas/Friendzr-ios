//
//  FaceRecognitionVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 22/01/2022.
//

import UIKit

class FaceRecognitionVC: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var superView: UIView!
    @IBOutlet weak var modelImg: UIImageView!
    @IBOutlet weak var verifyBtn: UIButton!
    @IBOutlet weak var contactUsBtn: UIButton!
    
    
    let imagePicker = UIImagePickerController()
    var faceImgOne: UIImage = UIImage()
    var faceImgTwo: UIImage = UIImage()
    
    var onFaceRegistrationCallBackResponse: ((_ faceImgOne:UIImage, _ faceImgTwo:UIImage,_ verify:Bool) -> ())?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initBackButton()
        setupViews()
    }
    
    
    func setupViews() {
        modelImg.cornerRadiusView(radius: 10)
        verifyBtn.cornerRadiusForHeight()
    }
    
    @IBAction func verifyBtn(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = false
            imagePicker.cameraCaptureMode = .photo
            imagePicker.cameraDevice = .front
            self.present(imagePicker, animated: true, completion: nil)
        }
//        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
//            imagePicker.delegate = self
//            imagePicker.sourceType = .photoLibrary
//            imagePicker.allowsEditing = true
//            self.present(imagePicker, animated: true, completion: nil)
//        }
        
    }

    @IBAction func contactBtn(_ sender: Any) {
    }
    
}

extension FaceRecognitionVC : UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image = info[.originalImage] as! UIImage
        picker.dismiss(animated:true, completion: {
            self.faceImgTwo = image
            self.onFaceRegistrationCallBackResponse?(self.faceImgOne,self.faceImgTwo,true)
            self.onPopup()
        })
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated:true, completion: nil)
    }
}
