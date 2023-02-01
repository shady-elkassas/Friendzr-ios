//
//  AddEditProfileImagesVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 15/01/2023.
//

import UIKit
import QCropper
import QuartzCore
import TLPhotoPicker
import Photos

class AddEditProfileImagesVC: UIViewController {

    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var saveBtn: UIButton!
    
    let cellID = "AddImagesCollectionViewCell"
    
    var imagesStr:[String] = [String]()
    var profileImages:[UIImage] = [UIImage]()
    var attachedImg = false
    var selectedAssets = [TLPHAsset]()
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
    
    func showExceededMaximumAlert(vc: UIViewController) {
        vc.view.makeToast("You can only add 5 additional photos.")
    }
    
    @objc func handleAddImg() {
        print("Add Images")
        if profileImages.count != 5 {
            let viewController = CustomPhotoPickerViewController()
            viewController.modalPresentationStyle = .fullScreen
            viewController.delegate = self
            viewController.didExceedMaximumNumberOfSelection = { [weak self] (picker) in
                self?.showExceededMaximumAlert(vc: picker)
            }
            var configure = TLPhotosPickerConfigure()
            configure.numberOfColumn = 3
            configure.selectedColor = UIColor.FriendzrColors.primary!
            configure.maxSelectedAssets = 5 - profileImages.count
//            configure.cameraIcon = nil
            
            viewController.configure = configure
            viewController.selectedAssets = self.selectedAssets
            viewController.logDelegate = self
            self.present(viewController, animated: true, completion: nil)
        }
        else {
            self.view.makeToast("You can only add 5 additional photos.")
        }
    }
}

extension AddEditProfileImagesVC : TLPhotosPickerLogDelegate , TLPhotosPickerViewControllerDelegate {
    //For Log User Interaction
    func selectedCameraCell(picker: TLPhotosPickerViewController) {
        print("selectedCameraCell")
    }
    
    func selectedPhoto(picker: TLPhotosPickerViewController, at: Int) {
        print("selectedPhoto")
    }
    
    func deselectedPhoto(picker: TLPhotosPickerViewController, at: Int) {
        print("deselectedPhoto")
    }
    
    func selectedAlbum(picker: TLPhotosPickerViewController, title: String, at: Int) {
        print("selectedAlbum")
    }
    
    func dismissPhotoPicker(withPHAssets: [PHAsset]) {
        // if you want to used phasset.
        print("withPHAssets = \(withPHAssets.count)")
        
        for item in withPHAssets {
            profileImages.append(getAssetThumbnail(asset: item))
            self.collectionView.reloadData()
        }
    }

    func photoPickerDidCancel() {
        // cancel
        print("cancel")
    }

    func dismissComplete() {
        // picker dismiss completion
        print("picker dismiss completion")
    }
}
