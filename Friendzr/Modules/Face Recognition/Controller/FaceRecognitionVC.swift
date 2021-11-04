//
//  FaceRecognitionVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 03/11/2021.
//

import UIKit
import SFaceCompare

final class FaceRecognitionVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak private var firstImageView: UIImageView!
    @IBOutlet weak private var secondImageView: UIImageView!
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak private var infoLabel: UILabel!
    
    // MARK: - Properties
    private var images = [UIImage]() {
        didSet {
            guard images.count == 2 else { return }
            activityIndicator.startAnimating()
            let faceComparator = SFaceCompare.init(on: self.images[0], and: self.images[1])
            faceComparator.compareFaces { [weak self] result in
                switch result {
                case .failure(let error):
                    self?.activityIndicator.stopAnimating()
                    self?.infoLabel.text = (error as? SFaceError)?.localizedDescription
                    self?.view.backgroundColor = UIColor.red
                case .success(let data):
                    self?.activityIndicator.stopAnimating()
                    self?.view.backgroundColor = UIColor.green
                    self?.infoLabel.text = "Yay! Faces are the same!\n With Coefficient: \(data.probability)"
                }
            }
        }
    }
    private var selectedImageViewTag = 0
    
    // MARK: - Lifecycle events
    override func viewDidLoad() {
        super.viewDidLoad()
        setDegaultViewsStates()
        addClickListenersToImageViews()
        
        initBackButton()
        setupNavBar()
        //      title = ""
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        guard motion == .motionShake else { return }
        setDegaultViewsStates()
    }
    
    
    // MARK: - Actions
    @objc func connected( _ sender:AnyObject) {
        selectedImageViewTag = sender.view.tag
        presentImagePicker()
    }
    
    // MARK: - Private methods
    private func setDegaultViewsStates() {
        images.removeAll()
        infoLabel.text = ""
        firstImageView.image = #imageLiteral(resourceName: "placeholder")
        secondImageView.image = #imageLiteral(resourceName: "placeholder")
        firstImageView.isUserInteractionEnabled = true
        UIView.animate(withDuration: 0.35, animations: {
            self.view.backgroundColor = UIColor.white
            self.secondImageView.alpha = 0.1
        })
    }
    
    private func addClickListenersToImageViews() {
        let firstImageViewTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(FaceRecognitionVC.connected(_:)))
        let secondImageViewTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(FaceRecognitionVC.connected(_:)))
        
        firstImageView.addGestureRecognizer(firstImageViewTapGestureRecognizer)
        secondImageView.addGestureRecognizer(secondImageViewTapGestureRecognizer)
    }
}

// MARK: - UIImagePickerControllerDelegate
extension FaceRecognitionVC: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedPhoto = info[.originalImage] as? UIImage else {
            return
        }
        dismiss(animated: true, completion: { [unowned self, selectedPhoto] in
            self.images.append(selectedPhoto)
            switch self.selectedImageViewTag {
            case 0:
                self.firstImageView.image = selectedPhoto
                self.secondImageView.isUserInteractionEnabled = true
                self.firstImageView.isUserInteractionEnabled = false
                UIView.animate(withDuration: 0.35, animations: { [weak self] in
                    self?.secondImageView.alpha = 1
                })
            case 1:
                self.secondImageView.image = selectedPhoto
                self.secondImageView.isUserInteractionEnabled = false
            default:
                fatalError("Unexpected behaviour")
            }
        })
    }
    
    func presentImagePicker() {
        let imagePickerActionSheet = UIAlertController(title: "Snap/Upload Image",
                                                       message: nil, preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraButton = UIAlertAction(title: "Camera",
                                             style: .default) { [unowned self] (alert) -> Void in
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .camera
                imagePicker.allowsEditing = true
                self.present(imagePicker, animated: true)
            }
            imagePickerActionSheet.addAction(cameraButton)
        }
        
        let libraryButton = UIAlertAction(title: "Photo Liberary",
                                          style: .default) { [unowned self] (alert) -> Void in
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true)
        }
        
        imagePickerActionSheet.addAction(libraryButton)
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel)
        imagePickerActionSheet.addAction(cancelButton)
        present(imagePickerActionSheet, animated: true)
    }
    
}

// MARK: - UINavigationControllerDelegate
extension FaceRecognitionVC: UINavigationControllerDelegate {
    
}
