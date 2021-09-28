//
//  EditMyProfileVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 16/08/2021.
//

import UIKit

class EditMyProfileVC: UIViewController {
    
    //MARK:- Outlets
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var superView: UIView!
    @IBOutlet weak var nameTxt: UITextField!
    @IBOutlet weak var dateBirthLbl: UILabel!
    @IBOutlet weak var bioTxtView: UITextView!
    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var maleImg: UIImageView!
    @IBOutlet weak var femaleImg: UIImageView!
    @IBOutlet weak var otherImg: UIImageView!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var tagsView: UIView!
    @IBOutlet weak var aboutMeView: UIView!
    @IBOutlet weak var placeHolderLbl: UILabel!
    @IBOutlet weak var tagsViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tagsListView: TagListView!
    
    //MARK: - Properties
    lazy var alertView = Bundle.main.loadNibNamed("CalendarView", owner: self, options: nil)?.first as? CalendarView
    var genderString = ""
    let imagePicker = UIImagePickerController()
    var viewmodel:EditProfileViewModel = EditProfileViewModel()
    var profileVM: ProfileViewModel = ProfileViewModel()
    var tagsid:[String] = [String]()
    var attachedImg:Bool = false
    var birthDay = ""
    
    var internetConect:Bool = false
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Edit Profile"
        setup()
        setupDate()
        
        DispatchQueue.main.async {
            self.updateUserInterface()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initBackButton()
        clearNavigationBar()
    }
    
    //MARK: - Helpers
    
    func updateUserInterface() {
        appDelegate.networkReachability()
        
        switch Network.reachability.status {
        case .unreachable:
            internetConect = false
            HandleInternetConnection()
        case .wwan:
            internetConect = true
            getProfileInformation()
        case .wifi:
            internetConect = true
            getProfileInformation()
        }
        
        print("Reachability Summary")
        print("Status:", Network.reachability.status)
        print("HostName:", Network.reachability.hostname ?? "nil")
        print("Reachable:", Network.reachability.isReachable)
        print("Wifi:", Network.reachability.isReachableViaWiFi)
    }
    
    func HandleInternetConnection() {
        self.view.makeToast("No avaliable newtwok ,Please try again!".localizedString)
    }

    func setup() {
        saveBtn.cornerRadiusView(radius: 8)
        nameView.cornerRadiusView(radius: 8)
        dateView.cornerRadiusView(radius: 8)
        bioTxtView.cornerRadiusView(radius: 8)
        tagsView.cornerRadiusView(radius: 8)
        aboutMeView.cornerRadiusView(radius: 8)
        profileImg.cornerRadiusForHeight()
        bioTxtView.delegate = self
        tagsListView.delegate = self
    }
    
    //MARK: - API
    func getProfileInformation() {
        profileVM.getProfileInfo()
        profileVM.userModel.bind { [unowned self]value in
            DispatchQueue.main.async {
                setupDate()
            }
        }
        
        // Set View Model Event Listener
        profileVM.error.bind { [unowned self]error in
            DispatchQueue.main.async {
                self.hideLoading()
                if error == "Internal Server Error" {
                    HandleInternetConnection()
                }else {
                    self.showAlert(withMessage: error)
                }
            }
        }
    }
    
    func setupDate() {
        let model = profileVM.userModel.value
        nameTxt.text = model?.userName
        bioTxtView.text = model?.bio
        dateBirthLbl.text = model?.birthdate
        dateBirthLbl.textColor = .black
        
        profileImg.sd_setImage(with: URL(string: model?.userImage ?? "" ), placeholderImage: UIImage(named: "avatar"))
        
        tagsListView.removeAllTags()
        for itm in model?.listoftagsmodel ?? [] {
            tagsListView.addTag(itm.tagname)
            tagsid.append(itm.tagID)
        }
        
        if tagsListView.rows == 0 {
            tagsViewHeight.constant = 45
        }else {
            tagsViewHeight.constant = CGFloat(tagsListView.rows * 30) + 10
        }
        tagsListView.textFont = UIFont(name: "Montserrat-Regular", size: 10)!
        
        if model?.gender == "male" {
            maleImg.image = UIImage(named: "select_ic")
            femaleImg.image = UIImage(named: "unSelect_ic")
            otherImg.image = UIImage(named: "unSelect_ic")
            
            genderString = "male"
        }else if model?.gender == "female" {
            femaleImg.image = UIImage(named: "select_ic")
            maleImg.image = UIImage(named: "unSelect_ic")
            otherImg.image = UIImage(named: "unSelect_ic")
            
            genderString = "female"
        }else {
            otherImg.image = UIImage(named: "select_ic")
            maleImg.image = UIImage(named: "unSelect_ic")
            femaleImg.image = UIImage(named: "unSelect_ic")
            
            genderString = "other"
        }
    }
    
    func OnInterestsCallBack(_ data: [String], _ value: [String]) -> () {
        print(data, value)
        
        tagsListView.removeAllTags()
        for item in value {
            tagsListView.addTag(item)
        }
        
        if tagsListView.rows == 0 {
            tagsViewHeight.constant = 45
        }else {
            tagsViewHeight.constant = CGFloat(tagsListView.rows * 30) + 10
        }
        
        tagsid.removeAll()
        for tag in data {
            tagsid.append(tag)
        }
    }
    
    //MARK: - Actions
    @IBAction func editProfileImgBtn(_ sender: Any) {
        if UIDevice.current.userInterfaceIdiom == .pad {
            let settingsActionSheet: UIAlertController = UIAlertController(title:nil, message:nil, preferredStyle: .alert)
            
            settingsActionSheet.addAction(UIAlertAction(title:"Camera".localizedString, style:UIAlertAction.Style.default, handler:{ action in
                self.openCamera()
            }))
            settingsActionSheet.addAction(UIAlertAction(title:"Photo Liberary".localizedString, style:UIAlertAction.Style.default, handler:{ action in
                self.openLibrary()
            }))
            settingsActionSheet.addAction(UIAlertAction(title:"Cancel".localizedString, style:UIAlertAction.Style.cancel, handler:nil))
            
            present(settingsActionSheet, animated:true, completion:nil)
            
        }else {
            let settingsActionSheet: UIAlertController = UIAlertController(title:nil, message:nil, preferredStyle:UIAlertController.Style.actionSheet)
            
            settingsActionSheet.addAction(UIAlertAction(title:"Camera".localizedString, style:UIAlertAction.Style.default, handler:{ action in
                self.openCamera()
            }))
            settingsActionSheet.addAction(UIAlertAction(title:"Photo Liberary".localizedString, style:UIAlertAction.Style.default, handler:{ action in
                self.openLibrary()
            }))
            settingsActionSheet.addAction(UIAlertAction(title:"Cancel".localizedString, style:UIAlertAction.Style.cancel, handler:nil))
            
            present(settingsActionSheet, animated:true, completion:nil)
        }
    }
    
    @IBAction func dateBtn(_ sender: Any) {
        alertView?.frame = CGRect(x: 0, y: -100, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        alertView?.HandleOKBtn = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            self.dateBirthLbl.text = formatter.string(from: (self.alertView?.calendarView.date)!)
            self.birthDay = formatter.string(from: (self.alertView?.calendarView.date)!)
            
            UIView.animate(withDuration: 0.3, animations: {
                self.alertView?.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
                self.alertView?.alpha = 0
            }) { (success: Bool) in
                self.alertView?.removeFromSuperview()
                self.alertView?.alpha = 1
                self.alertView?.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            }
        }
        
        alertView?.HandleCancelBtn = {
            // handling code
            UIView.animate(withDuration: 0.3, animations: {
                self.alertView?.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
                self.alertView?.alpha = 0
            }) { (success: Bool) in
                self.alertView?.removeFromSuperview()
                self.alertView?.alpha = 1
                self.alertView?.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            }
        }
        
        self.view.addSubview((alertView)!)
    }
    
    @IBAction func maleBtn(_ sender: Any) {
        maleImg.image = UIImage(named: "select_ic")
        femaleImg.image = UIImage(named: "unSelect_ic")
        otherImg.image = UIImage(named: "unSelect_ic")
        
        genderString = "male"
    }
    
    @IBAction func femaleBtn(_ sender: Any) {
        femaleImg.image = UIImage(named: "select_ic")
        maleImg.image = UIImage(named: "unSelect_ic")
        otherImg.image = UIImage(named: "unSelect_ic")
        
        genderString = "female"
    }
    
    @IBAction func otherBtn(_ sender: Any) {
        otherImg.image = UIImage(named: "select_ic")
        maleImg.image = UIImage(named: "unSelect_ic")
        femaleImg.image = UIImage(named: "unSelect_ic")
        
        genderString = "other"
    }
    
    @IBAction func tagsBtn(_ sender: Any) {
        updateUserInterface()
        if internetConect {
            guard let vc = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "TagsVC") as? TagsVC else {return}
            vc.onInterestsCallBackResponse = self.OnInterestsCallBack
            self.navigationController?.pushViewController(vc, animated: true)
        }else {
            return
        }
    }
    
    @IBAction func integrationInstgramBtn(_ sender: Any) {
    }
    
    @IBAction func integrationSnapchatBtn(_ sender: Any) {
    }
    
    @IBAction func integrationFacebookBtn(_ sender: Any) {
    }
    
    @IBAction func integrationTiktokBtn(_ sender: Any) {
    }
    
    @IBAction func saveBtn(_ sender: Any) {
        updateUserInterface()
        
        if internetConect {
            self.showLoading()
            viewmodel.editProfile(withUserName: nameTxt.text!, AndGender: genderString, AndGeneratedUserName: nameTxt.text!, AndBio: bioTxtView.text!, AndBirthdate: dateBirthLbl.text!, tagsId: tagsid, attachedImg: self.attachedImg, AndUserImage: self.profileImg.image ?? UIImage()) { error, data in
                self.hideLoading()
                if let error = error {
                    self.showAlert(withMessage: error)
                    return
                }
                
                guard let _ = data else {return}
                //            self.showAlert(withMessage: "Edits Saved")
                
                DispatchQueue.main.async {
                    if Defaults.needUpdate == 1 {
                        return
                    }else {
                        Router().toHome()
                    }
                }
            }
        }else {
            return
        }
    }
}

//MARK: - Extensions
extension EditMyProfileVC : UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    //MARK:- Take Picture
    func openCamera(){
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera;
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    func openLibrary(){
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        picker.dismiss(animated:true, completion: {
            
            self.profileImg.image = image
            self.attachedImg = true
        })
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated:true, completion: nil)
    }
}

extension EditMyProfileVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeHolderLbl.isHidden = !textView.text.isEmpty
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (bioTxtView.text as NSString).replacingCharacters(in: range, with: text)
        return newText.count < 250
    }
}

extension EditMyProfileVC : TagListViewDelegate {
    
    // MARK: TagListViewDelegate
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        print("Tag pressed: \(title), \(sender)")
        //        tagView.isSelected = !tagView.isSelected
    }
    
    func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) {
        print("Tag Remove pressed: \(title), \(sender)")
        //        sender.removeTagView(tagView)
    }
}
