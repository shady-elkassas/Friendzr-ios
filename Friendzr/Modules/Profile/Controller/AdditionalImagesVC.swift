//
//  AdditionalImagesVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 01/02/2023.
//

import UIKit
import QCropper
import QuartzCore
import TLPhotoPicker
import Photos

class AdditionalImagesVC: UIViewController {

    @IBOutlet weak var imagContainerView1: UIView!
    @IBOutlet weak var img1: UIImageView!
    @IBOutlet weak var addImg1Btn: UIButton!
    @IBOutlet weak var removeImg1Btn: UIButton!

    @IBOutlet weak var imagContainerView2: UIView!
    @IBOutlet weak var img2: UIImageView!
    @IBOutlet weak var addImg2Btn: UIButton!
    @IBOutlet weak var removeImg2Btn: UIButton!

    @IBOutlet weak var imagContainerView3: UIView!
    @IBOutlet weak var img3: UIImageView!
    @IBOutlet weak var addImg3Btn: UIButton!
    @IBOutlet weak var removeImg3Btn: UIButton!

    @IBOutlet weak var imagContainerView4: UIView!
    @IBOutlet weak var img4: UIImageView!
    @IBOutlet weak var addImg4Btn: UIButton!
    @IBOutlet weak var removeImg4Btn: UIButton!

    @IBOutlet weak var imagContainerView5: UIView!
    @IBOutlet weak var img5: UIImageView!
    @IBOutlet weak var addImg5Btn: UIButton!
    @IBOutlet weak var removeImg5Btn: UIButton!

    
    let imagePicker = UIImagePickerController()

    var additionalImg1Found:Bool = false
    var additionalImg2Found:Bool = false
    var additionalImg3Found:Bool = false
    var additionalImg4Found:Bool = false
    var additionalImg5Found:Bool = false

    var buttonTap:Int = 0
    var profileImages:[UIImage] = [UIImage]()
    var selectedAssets = [TLPHAsset]()
    var viewmodel:EditProfileViewModel = EditProfileViewModel()
    
    var onAdditionalPhotosCallBackResponse: ((_ data: [UIImage], _ value: [String]) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Additional Images"
        
        initSaveBarButton(istap: false)
        initBackButton()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        onAdditionalPhotosCallBackResponse?(profileImages,["\(profileImages.count)"])
    }
    
    
    func setupViews() {
        
        img1.cornerRadiusView(radius: 8)
        img2.cornerRadiusView(radius: 8)
        img3.cornerRadiusView(radius: 8)
        img4.cornerRadiusView(radius: 8)
        img5.cornerRadiusView(radius: 8)
        
        imagContainerView1.cornerRadiusView(radius: 8)
        imagContainerView2.cornerRadiusView(radius: 8)
        imagContainerView3.cornerRadiusView(radius: 8)
        imagContainerView4.cornerRadiusView(radius: 8)
        imagContainerView5.cornerRadiusView(radius: 8)

        if profileImages.count == 5 {
            additionalImg1Found = true
            additionalImg2Found = true
            additionalImg3Found = true
            additionalImg4Found = true
            additionalImg5Found = true
            
            img1.isHidden = false
            img2.isHidden = false
            img3.isHidden = false
            img4.isHidden = false
            img5.isHidden = false

            img1.image = profileImages[0]
            img2.image = profileImages[1]
            img3.image = profileImages[2]
            img4.image = profileImages[3]
            img5.image = profileImages[4]
        }
        else if profileImages.count == 4 {
            additionalImg1Found = true
            additionalImg2Found = true
            additionalImg3Found = true
            additionalImg4Found = true
            additionalImg5Found = false
            img1.isHidden = false
            img2.isHidden = false
            img3.isHidden = false
            img4.isHidden = false
            img5.isHidden = true
            img1.image = profileImages[0]
            img2.image = profileImages[1]
            img3.image = profileImages[2]
            img4.image = profileImages[3]
        }
        else if profileImages.count == 3 {
            additionalImg1Found = true
            additionalImg2Found = true
            additionalImg3Found = true
            additionalImg4Found = false
            additionalImg5Found = false
            
            img1.isHidden = false
            img2.isHidden = false
            img3.isHidden = false
            img4.isHidden = true
            img5.isHidden = true

            img1.image = profileImages[0]
            img2.image = profileImages[1]
            img3.image = profileImages[2]
        }
        else if profileImages.count == 2 {
            additionalImg1Found = true
            additionalImg2Found = true
            additionalImg3Found = false
            additionalImg4Found = false
            additionalImg5Found = false
            img1.isHidden = false
            img2.isHidden = false
            img3.isHidden = true
            img4.isHidden = true
            img5.isHidden = true

            img1.image = profileImages[0]
            img2.image = profileImages[1]
        }
        else if profileImages.count == 1 {
            additionalImg1Found = true
            additionalImg2Found = false
            additionalImg3Found = false
            additionalImg4Found = false
            additionalImg5Found = false

            img1.isHidden = false
            img2.isHidden = true
            img3.isHidden = true
            img4.isHidden = true
            img5.isHidden = true

            img1.image = profileImages[0]
        }
        else {
            additionalImg1Found = false
            additionalImg2Found = false
            additionalImg3Found = false
            additionalImg4Found = false
            additionalImg5Found = false
            
            img1.isHidden = true
            img2.isHidden = true
            img3.isHidden = true
            img4.isHidden = true
            img5.isHidden = true

        }

        if additionalImg1Found {
            addImg1Btn.isHidden = true
            removeImg1Btn.isHidden = false
        }else {
            img1.image = UIImage(named: "placeholder")
            addImg1Btn.isHidden = false
            removeImg1Btn.isHidden = true
        }
        
        if additionalImg2Found {
            addImg2Btn.isHidden = true
            removeImg2Btn.isHidden = false
        }else {
            img2.image = UIImage(named: "placeholder")
            addImg2Btn.isHidden = false
            removeImg2Btn.isHidden = true
        }
        
        if additionalImg3Found {
            addImg3Btn.isHidden = true
            removeImg3Btn.isHidden = false
        }else {
            addImg3Btn.isHidden = false
            removeImg3Btn.isHidden = true
        }
        
        if additionalImg4Found {
            addImg4Btn.isHidden = true
            removeImg4Btn.isHidden = false
        }else {
            addImg4Btn.isHidden = false
            removeImg4Btn.isHidden = true
        }
        
        if additionalImg5Found {
            addImg5Btn.isHidden = true
            removeImg5Btn.isHidden = false
        }else {
            addImg5Btn.isHidden = false
            removeImg5Btn.isHidden = true
        }
    }
    
    @IBAction func addImg1Btn(_ sender: Any) {
        buttonTap = 1
        setupImagePicker()
    }
    
    @IBAction func addImg2Btn(_ sender: Any) {
        buttonTap = 2
        setupImagePicker()
    }
    @IBAction func addImg3Btn(_ sender: Any) {
        buttonTap = 3
        setupImagePicker()
    }
    @IBAction func addImg4Btn(_ sender: Any) {
        buttonTap = 4
        setupImagePicker()
    }
    
    @IBAction func addImg5Btn(_ sender: Any) {
        buttonTap = 5
        setupImagePicker()
    }
    
    @IBAction func removeImg1Btn(_ sender: Any) {
        img1.isHidden = true
        addImg1Btn.isHidden = false
        removeImg1Btn.isHidden = true
        additionalImg1Found = false

        profileImages.removeAll(where: {$0 == img1.image})
    }
    
    @IBAction func removeImg2Btn(_ sender: Any) {
        img2.isHidden = true
        addImg2Btn.isHidden = false
        removeImg2Btn.isHidden = true
        additionalImg2Found = false
        
        profileImages.removeAll(where: {$0 == img2.image})
    }
    @IBAction func removeImg3Btn(_ sender: Any) {
        img3.isHidden = true
        addImg3Btn.isHidden = false
        removeImg3Btn.isHidden = true
        additionalImg3Found = false
        profileImages.removeAll(where: {$0 == img3.image})
    }
    
    @IBAction func removeImg4Btn(_ sender: Any) {
        img4.isHidden = true
        addImg4Btn.isHidden = false
        removeImg4Btn.isHidden = true
        additionalImg4Found = false
        profileImages.removeAll(where: {$0 == img4.image})
    }
    @IBAction func removeImg5Btn(_ sender: Any) {
        img5.isHidden = true
        addImg5Btn.isHidden = false
        removeImg5Btn.isHidden = true
        additionalImg5Found = false
        profileImages.removeAll(where: {$0 == img5.image})
    }
}


extension AdditionalImagesVC {
    
    func setupImagePicker() {
        let settingsActionSheet: UIAlertController = UIAlertController(title:nil, message:nil, preferredStyle:UIAlertController.Style.actionSheet)
        
        let cameraBtn = UIAlertAction(title: "Camera", style: .default) {_ in
            self.openCamera()
        }
        let libraryBtn = UIAlertAction(title: "Photo Library", style: .default) {_ in
            self.openLibrary()
        }
        
        let cancelBtn = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        cameraBtn.setValue(UIColor.FriendzrColors.primary, forKey: "titleTextColor")
        libraryBtn.setValue(UIColor.FriendzrColors.primary, forKey: "titleTextColor")
        cancelBtn.setValue(UIColor.red, forKey: "titleTextColor")
        
        settingsActionSheet.addAction(cameraBtn)
        settingsActionSheet.addAction(libraryBtn)
        settingsActionSheet.addAction(cancelBtn)
        
        present(settingsActionSheet, animated: true, completion: nil)
    }
    
    func initSaveBarButton(istap:Bool) {
        let button = UIButton.init(type: .custom)
        button.setTitle(istap ? "Saving..." : "Save", for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 70, height: 35)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "Montserrat-Bold", size: 12)
        button.backgroundColor = .FriendzrColors.primary!
        button.cornerRadiusView(radius: 8)
        button.isUserInteractionEnabled = istap ? false : true
        button.tintColor = UIColor.setColor(lightColor: UIColor.black, darkColor: UIColor.white)
        button.addTarget(self, action: #selector(handleSaveEdits), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    @objc func handleSaveEdits() {
        print("profileImagesCount = \(profileImages.count)")
        initSaveBarButton(istap: true)
        viewmodel.UpdateUserImages(WithAchedImg: true, AndUserImage: profileImages) { error, data in
            if let error = error {
                DispatchQueue.main.async {
                    self.view.makeToast(error)
                }
                return
            }
            
            guard data != nil else {return}
            
            DispatchQueue.main.async {
                self.onPopup()
            }
        }
    }
}

extension AdditionalImagesVC : UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    //MARK: - Take Picture
    func openCamera(){
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera;
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    //MARK: - Open Library
    func openLibrary(){
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image = info[.originalImage] as! UIImage
        let originImg = image.fixOrientation()

        picker.dismiss(animated: true) {
            if self.buttonTap == 1 {
                self.img1.isHidden = false
                self.img1.image = originImg
                self.additionalImg1Found = true
                self.addImg1Btn.isHidden = true
                self.removeImg1Btn.isHidden = false
                self.profileImages.append(originImg)
            }
            else if self.buttonTap == 2 {
                self.img2.isHidden = false
                self.img2.image = originImg
                self.additionalImg2Found = true
                self.addImg2Btn.isHidden = true
                self.removeImg2Btn.isHidden = false
                self.profileImages.append(originImg)

            }
            else if self.buttonTap == 3 {
                self.img3.isHidden = false
                self.img3.image = originImg
                self.additionalImg3Found = true
                self.addImg3Btn.isHidden = true
                self.removeImg3Btn.isHidden = false
                self.profileImages.append(originImg)

            }
            else if self.buttonTap == 4 {
                self.img4.isHidden = false
                self.img4.image = originImg
                self.additionalImg4Found = true
                self.additionalImg4Found  = true
                self.addImg4Btn.isHidden = true
                self.profileImages.append(originImg)

            }
            else if self.buttonTap == 5 {
                self.img5.isHidden = false
                self.img5.image = originImg
                self.additionalImg5Found = true
                self.addImg5Btn.isHidden = true
                self.removeImg5Btn.isHidden = false
                self.profileImages.append(originImg)
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.tabBarController?.tabBar.isHidden = false
        picker.dismiss(animated:true, completion: nil)
    }

}
