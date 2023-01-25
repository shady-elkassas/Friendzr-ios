//
//  AddEditProfileImagesVC.swift
//  Friendzr
//
//  Created by Shady Elkassas on 15/01/2023.
//

import UIKit
import QCropper

class AddEditProfileImagesVC: UIViewController {

    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var saveBtn: UIButton!
    
    let cellID = "AddImagesCollectionViewCell"
    
    var imagesStr:[String] = [String]()
    var profileImages:[UIImage] = [UIImage]()
    let imagePicker = UIImagePickerController()
    var attachedImg = false
    var viewmodel:EditProfileViewModel = EditProfileViewModel()
    
    var onAdditionalPhotosCallBackResponse: ((_ data: [UIImage], _ value: [String]) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initAddImageBtn()
        initBackButton()
        setupViews()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        onAdditionalPhotosCallBackResponse?(profileImages,["\(profileImages.count)"])
    }
    
    func setupViews() {
        
//        for item in imagesStr {
//            profileImages.append(convertToImage(imagURL: item))
//        }
        self.title = "Additional Images"
        collectionView.register(UINib(nibName: cellID, bundle: nil), forCellWithReuseIdentifier: cellID)
        saveBtn.cornerRadiusView(radius: 8)
        saveBtn.isHidden = true
    }
    
    @IBAction func saveBtn(_ sender: Any) {
        if profileImages.count != 0 {
            self.attachedImg = true
        }else {
            self.attachedImg = false
        }
        
        self.saveBtn.setTitle("Saving...", for: .normal)
        self.saveBtn.isUserInteractionEnabled = false
        
        viewmodel.UpdateUserImages(WithAchedImg: self.attachedImg, AndUserImage: profileImages) { error, data in
            if let error = error {
                DispatchQueue.main.async {
                    self.view.makeToast(error)
                    self.saveBtn.setTitle("Save", for: .normal)
                    self.saveBtn.isUserInteractionEnabled = true
                }
                return
            }
            
            guard data != nil else {return}
            
            DispatchQueue.main.async {
                self.saveBtn.setTitle("Save", for: .normal)
                self.saveBtn.isUserInteractionEnabled = true
            }
        }
    }
}

extension AddEditProfileImagesVC : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return profileImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as? AddImagesCollectionViewCell else {return UICollectionViewCell()}
        cell.profileImg.image = profileImages[indexPath.row]
        
        cell.HandleRemoveBtn = {
            self.profileImages.remove(at: indexPath.row)
            collectionView.reloadData()
        }
        
        return cell
    }
}

extension AddEditProfileImagesVC:UICollectionViewDelegateFlowLayout,UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let wid = collectionView.frame.width
        let hig = collectionView.frame.height
        
        return CGSize(width: wid/2, height: hig/4)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension AddEditProfileImagesVC {
    func initAddImageBtn() {
        var imageName = ""
        imageName = "Plus_ic"
        let button = UIButton.init(type: .custom)
        let image = UIImage.init(named: imageName)
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        button.setImage(image, for: .normal)
        button.cornerRadiusView()
        button.backgroundColor = UIColor.FriendzrColors.primary
        button.addTarget(self, action:  #selector(handleAddImg), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    @objc func handleAddImg() {
        print("Add Images")
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
}

//MARK: - Extensions UIImagePickerControllerDelegate && UINavigationControllerDelegate
extension AddEditProfileImagesVC : UIImagePickerControllerDelegate,UINavigationControllerDelegate {
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
        
        let cropper = CustomCropperViewController(originalImage: originImg)
        cropper.delegate = self
        self.navigationController?.pushViewController(cropper, animated: true)
        picker.dismiss(animated: true) {
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.attachedImg = false
        self.tabBarController?.tabBar.isHidden = false
        picker.dismiss(animated:true, completion: nil)
    }
}

extension AddEditProfileImagesVC: CropperViewControllerDelegate {
    
    func aspectRatioPickerDidSelectedAspectRatio(_ aspectRatio: AspectRatio) {
        print("\(String(describing: aspectRatio.dictionary))")
    }
    
    func cropperDidConfirm(_ cropper: CropperViewController, state: CropperState?) {
        cropper.onPopup()
        if let state = state,
           let image = cropper.originalImage.cropped(withCropperState: state) {
            if profileImages.count != 5 {
                profileImages.append(image)
                collectionView.reloadData()
//                onAdditionalPhotosCallBackResponse?(profileImages,["\(profileImages.count)"])
            } else {
                self.view.makeToast("To add more photos, please delete one or more of your photos first")
            }
            
            self.attachedImg = true
            print(cropper.isCurrentlyInInitialState)
            print(image)
        }
    }
    
    func cropperDidCancel(_ cropper: CropperViewController) {
        cropper.onPopup()
    }
}
