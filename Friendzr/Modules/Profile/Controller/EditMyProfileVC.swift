//
//  EditMyProfileVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 16/08/2021.
//

import UIKit
//import SCSDKLoginKit
//import TikTokOpenSDK
import FBSDKCoreKit
import FBSDKLoginKit
import ListPlaceholder

class EditMyProfileVC: UIViewController {
    
    //MARK:- Outlets
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var superView: UIView!
    @IBOutlet weak var nameTxt: UITextField!
    @IBOutlet weak var dateBirthLbl: UILabel!
    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var maleImg: UIImageView!
    @IBOutlet weak var femaleImg: UIImageView!
    @IBOutlet weak var otherImg: UIImageView!
    @IBOutlet weak var saveBtn: UIButton!
    
    @IBOutlet weak var aboutMeView: UIView!
    @IBOutlet weak var bioTxtView: UITextView!
    @IBOutlet weak var placeHolderLbl: UILabel!
    
    @IBOutlet weak var tagsView: UIView!
    @IBOutlet weak var tagsViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tagsListView: TagListView!
    @IBOutlet weak var selectTagsLbl: UILabel!
    
    @IBOutlet weak var bestDescribesView: UIView!
    @IBOutlet weak var bestDescribesViewHeight: NSLayoutConstraint!
    @IBOutlet weak var bestDescribesListView: TagListView!
    @IBOutlet weak var selectbestDescribesLbl: UILabel!

    @IBOutlet weak var preferToView: UIView!
    @IBOutlet weak var preferToViewHeight: NSLayoutConstraint!
    @IBOutlet weak var preferToListView: TagListView!
    @IBOutlet weak var selectPreferToLbl: UILabel!

    
    @IBOutlet weak var logoutBtn: UIButton!
    
    @IBOutlet weak var tagsBottomSpaceLayout: NSLayoutConstraint!
    @IBOutlet weak var tagsTopSpaceLayout: NSLayoutConstraint!
    @IBOutlet weak var bestDescribesBottomSpaceLayout: NSLayoutConstraint!
    @IBOutlet weak var bestDescribessTopSpaceLayout: NSLayoutConstraint!
    @IBOutlet weak var preferToBottomSpaceLayout: NSLayoutConstraint!
    @IBOutlet weak var preferToTopSpaceLayout: NSLayoutConstraint!

    @IBOutlet weak var otherGenderSubView: UIView!
    @IBOutlet weak var otherGenderView: UIView!
    @IBOutlet weak var otherGenderTxt: UITextField!
    
    @IBOutlet weak var ProcessingLbl: UILabel!

    //MARK: - Properties
    
    lazy var logoutAlertView = Bundle.main.loadNibNamed("BlockAlertView", owner: self, options: nil)?.first as? BlockAlertView
    lazy var calendarView = Bundle.main.loadNibNamed("CalendarView", owner: self, options: nil)?.first as? CalendarView
    lazy var verifyFaceView = Bundle.main.loadNibNamed("VerifyFaceRegistrationAlertView", owner: self, options: nil)?.first as? VerifyFaceRegistrationAlertView
    
    
    var genderString = ""
    let imagePicker = UIImagePickerController()
    var viewmodel:EditProfileViewModel = EditProfileViewModel()
    var profileVM: ProfileViewModel = ProfileViewModel()
    var logoutVM:LogoutViewModel = LogoutViewModel()
    var faceRecognitionVM:FaceRecognitionViewModel = FaceRecognitionViewModel()
    var tagsid:[String] = [String]()
    var tagsNames:[String] = [String]()
    var bestDescribesid:[String] = [String]()
    var bestDescribesNames:[String] = [String]()

    var attachedImg:Bool = false
    var birthDay = ""
    
    var internetConect:Bool = false
    
    var UserFBID = ""
    var UserFBMobile = ""
    var UserFBEmail = ""
    var UserFBFirstName = ""
    var UserFBLastName = ""
    var userFace_BookAccessToken = ""
    var UserFBUserName = ""
    var UserFBImage = ""
    
    var facebookLink = ""
    var tiktokLink = ""
    var instgramLink = ""
    var snapchatLink = ""
    
    var needUpdateVC:Bool = false
    
    var faceImgOne: UIImage = UIImage()
    var faceImgTwo: UIImage = UIImage()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Edit Profile".localizedString
        setup()
        setupDate()
        
        DispatchQueue.main.async {
            self.updateUserInterface()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if needUpdateVC == true {
            logoutBtn.isHidden = false
            initCloseApp()
        }else {
            logoutBtn.isHidden = true
            initBackButton()
        }
        clearNavigationBar()
        
        CancelRequest.currentTask = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.hideLoading()
        CancelRequest.currentTask = true
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
    
    func updateUserInterface2() {
        appDelegate.networkReachability()
        
        switch Network.reachability.status {
        case .unreachable:
            internetConect = false
            HandleInternetConnection()
        case .wwan:
            internetConect = true
        case .wifi:
            internetConect = true
        }
        
        print("Reachability Summary")
        print("Status:", Network.reachability.status)
        print("HostName:", Network.reachability.hostname ?? "nil")
        print("Reachable:", Network.reachability.isReachable)
        print("Wifi:", Network.reachability.isReachableViaWiFi)
    }
    
    func HandleInternetConnection() {
        self.view.makeToast("No available network, please try again!".localizedString)
    }
    
    func setup() {
        saveBtn.cornerRadiusView(radius: 8)
        nameView.cornerRadiusView(radius: 8)
        dateView.cornerRadiusView(radius: 8)
        bioTxtView.cornerRadiusView(radius: 8)
        tagsView.cornerRadiusView(radius: 8)
        bestDescribesView.cornerRadiusView(radius: 8)

        aboutMeView.cornerRadiusView(radius: 8)
        otherGenderSubView.cornerRadiusView(radius: 8)
        logoutBtn.cornerRadiusView(radius: 8)
        
        logoutBtn.setBorder(color: UIColor.FriendzrColors.primary?.cgColor, width: 1.0)
        
        profileImg.cornerRadiusForHeight()
        bioTxtView.delegate = self
        tagsListView.delegate = self
        bestDescribesListView.delegate = self
    }
    
    //MARK: - API
    func getProfileInformation() {
        self.superView.showLoader()
        profileVM.getProfileInfo()
        profileVM.userModel.bind { [unowned self]value in
            DispatchQueue.main.async {
                setupDate()
                self.superView.hideLoader()
            }
        }
        
        // Set View Model Event Listener
        profileVM.error.bind { [unowned self]error in
            DispatchQueue.main.async {
                self.hideLoading()
                if error == "Internal Server Error" {
                    HandleInternetConnection()
                }
                else {
                    DispatchQueue.main.async {
                        self.view.makeToast(error)
                    }
                    
                }
            }
        }
    }
    
    func setupDate() {
        let model = profileVM.userModel.value
        
        nameTxt.text = model?.userName
        
        if model?.bio != "" {
            bioTxtView.text = model?.bio
            placeHolderLbl.isHidden = true
        }else {
            bioTxtView.text = ""
            placeHolderLbl.isHidden = false
        }
        
//        if model?.whatAmILookingFor != "" {
//            lookingforTxtView.text = model?.whatAmILookingFor
//            lookingforPlaceHolderLbl.isHidden = true
//        }else {
//            lookingforTxtView.text = ""
//            lookingforPlaceHolderLbl.isHidden = false
//        }
//
        if model?.birthdate == "" {
            dateBirthLbl.text = "Select your birthdate".localizedString
            dateBirthLbl.textColor = .lightGray
        }else {
            dateBirthLbl.text = model?.birthdate
            dateBirthLbl.textColor = .black
        }
        
        if model?.userImage != "" {
            profileImg.sd_setImage(with: URL(string: model?.userImage ?? "" ), placeholderImage: UIImage(named: "placeholder"))
            self.attachedImg = true
        }else {
            self.attachedImg = false
        }
        
        tagsListView.removeAllTags()
        for itm in model?.listoftagsmodel ?? [] {
            tagsListView.addTag(tagId: itm.tagID, title: "#\(itm.tagname)")
            tagsid.append(itm.tagID)
            tagsNames.append(itm.tagname)
        }
        
        if tagsListView.rows == 0 {
            tagsViewHeight.constant = 45
            selectTagsLbl.isHidden = false
            selectTagsLbl.textColor = .lightGray
        }else {
            tagsViewHeight.constant = CGFloat(tagsListView.rows * 25) + 25
            selectTagsLbl.isHidden = true
            
            print("tagsViewHeight.constant >> \(tagsViewHeight.constant)")
        }
        
        tagsListView.textFont = UIFont(name: "Montserrat-Regular", size: 10)!
        if tagsListView.rows == 0 {
            tagsTopSpaceLayout.constant = 5
            tagsBottomSpaceLayout.constant = 5
        }else if tagsListView.rows == 1 {
            tagsTopSpaceLayout.constant = 25
            tagsBottomSpaceLayout.constant = 5
        }else if tagsListView.rows == 2 {
            tagsTopSpaceLayout.constant = 16
            tagsBottomSpaceLayout.constant = 5
        }else if tagsListView.rows == 3 {
            tagsTopSpaceLayout.constant = 10
            tagsBottomSpaceLayout.constant = 5
        }else if tagsListView.rows == 4 {
            tagsTopSpaceLayout.constant = 10
            tagsBottomSpaceLayout.constant = 17
        }
        
        
        bestDescribesListView.removeAllTags()
        for itm in model?.whatBestDescripsMeList ?? [] {
            bestDescribesListView.addTag(tagId: itm.tagID, title: "#\(itm.tagname)")
            bestDescribesid.append(itm.tagID)
            bestDescribesNames.append(itm.tagname)
        }
        
        if bestDescribesListView.rows == 0 {
            bestDescribesViewHeight.constant = 45
            selectbestDescribesLbl.isHidden = false
            selectbestDescribesLbl.textColor = .lightGray
        }else {
            bestDescribesViewHeight.constant = CGFloat(bestDescribesListView.rows * 25) + 25
            selectbestDescribesLbl.isHidden = true
            
            print("bestViewHeight.constant >> \(bestDescribesViewHeight.constant)")
        }
        
        bestDescribesListView.textFont = UIFont(name: "Montserrat-Regular", size: 10)!
        
        if bestDescribesListView.rows == 0 {
            bestDescribessTopSpaceLayout.constant = 5
            bestDescribesBottomSpaceLayout.constant = 5
        }else if bestDescribesListView.rows == 1 {
            bestDescribessTopSpaceLayout.constant = 25
            bestDescribesBottomSpaceLayout.constant = 5
        }else if bestDescribesListView.rows == 2 {
            bestDescribessTopSpaceLayout.constant = 16
            bestDescribesBottomSpaceLayout.constant = 5
        }else if bestDescribesListView.rows == 3 {
            bestDescribessTopSpaceLayout.constant = 10
            bestDescribesBottomSpaceLayout.constant = 5
        }else if bestDescribesListView.rows == 4 {
            bestDescribessTopSpaceLayout.constant = 10
            bestDescribesBottomSpaceLayout.constant = 17
        }
        
        if model?.gender == "male" {
            maleImg.image = UIImage(named: "select_ic")
            femaleImg.image = UIImage(named: "unSelect_ic")
            otherImg.image = UIImage(named: "unSelect_ic")
            otherGenderView.isHidden = true
            otherGenderTxt.text = ""
            
            genderString = "male"
        }else if model?.gender == "female" {
            femaleImg.image = UIImage(named: "select_ic")
            maleImg.image = UIImage(named: "unSelect_ic")
            otherImg.image = UIImage(named: "unSelect_ic")
            otherGenderView.isHidden = true
            otherGenderTxt.text = ""
            
            genderString = "female"
        }else {
            otherImg.image = UIImage(named: "select_ic")
            maleImg.image = UIImage(named: "unSelect_ic")
            femaleImg.image = UIImage(named: "unSelect_ic")
            otherGenderView.isHidden = false
            otherGenderTxt.text = model?.otherGenderName
            
            genderString = "other"
        }
    }
    
    func OnInterestsCallBack(_ data: [String], _ value: [String]) -> () {
        print(data, value)
        
        selectTagsLbl.isHidden = true
        tagsListView.removeAllTags()
        tagsNames.removeAll()
        for item in value {
            tagsListView.addTag(tagId: "", title: "#\(item)")
            tagsNames.append(item)
        }
        
        if tagsListView.rows == 0 {
            tagsViewHeight.constant = 45
            selectTagsLbl.isHidden = false
            selectTagsLbl.textColor = .lightGray
        }else {
            tagsViewHeight.constant = CGFloat(tagsListView.rows * 25) + 25
            selectTagsLbl.isHidden = true
        }
        
        print("tagsViewHeight.constant >> \(tagsViewHeight.constant)")
        
        tagsid.removeAll()
        for itm in data {
            tagsid.append(itm)
        }
        
        if tagsListView.rows == 0 {
            tagsTopSpaceLayout.constant = 5
            tagsBottomSpaceLayout.constant = 5
        }else if tagsListView.rows == 1 {
            tagsTopSpaceLayout.constant = 25
            tagsBottomSpaceLayout.constant = 5
        }else if tagsListView.rows == 2 {
            tagsTopSpaceLayout.constant = 16
            tagsBottomSpaceLayout.constant = 5
        }else if tagsListView.rows == 3 {
            tagsTopSpaceLayout.constant = 10
            tagsBottomSpaceLayout.constant = 5
        }else if tagsListView.rows == 4 {
            tagsTopSpaceLayout.constant = 10
            tagsBottomSpaceLayout.constant = 17
        }
        
    }
    
    func OnbestDescribesCallBack(_ data: [String], _ value: [String]) -> () {
        print(data, value)
        
        selectbestDescribesLbl.isHidden = true
        bestDescribesListView.removeAllTags()
        bestDescribesNames.removeAll()
        for item in value {
            bestDescribesListView.addTag(tagId: "", title: "#\(item)")
            bestDescribesNames.append(item)
        }
        
        if bestDescribesListView.rows == 0 {
            bestDescribesViewHeight.constant = 45
            selectbestDescribesLbl.isHidden = false
            selectbestDescribesLbl.textColor = .lightGray
        }else {
            bestDescribesViewHeight.constant = CGFloat(bestDescribesListView.rows * 25) + 25
            selectbestDescribesLbl.isHidden = true
        }
        
        print("bestViewHeight.constant >> \(bestDescribesViewHeight.constant)")
        
        bestDescribesid.removeAll()
        for itm in data {
            bestDescribesid.append(itm)
        }
        
        if bestDescribesListView.rows == 0 {
            bestDescribessTopSpaceLayout.constant = 5
            bestDescribesBottomSpaceLayout.constant = 5
        }else if bestDescribesListView.rows == 1 {
            bestDescribessTopSpaceLayout.constant = 25
            bestDescribesBottomSpaceLayout.constant = 5
        }else if bestDescribesListView.rows == 2 {
            bestDescribessTopSpaceLayout.constant = 16
            bestDescribesBottomSpaceLayout.constant = 5
        }else if bestDescribesListView.rows == 3 {
            bestDescribessTopSpaceLayout.constant = 10
            bestDescribesBottomSpaceLayout.constant = 5
        }else if bestDescribesListView.rows == 4 {
            bestDescribessTopSpaceLayout.constant = 10
            bestDescribesBottomSpaceLayout.constant = 17
        }
        
    }
    func logout() {
        logoutAlertView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        logoutAlertView?.titleLbl.text = "Confirm?".localizedString
        logoutAlertView?.detailsLbl.text = "Are you sure you want to logout?".localizedString
        
        logoutAlertView?.HandleConfirmBtn = {
            self.updateUserInterface2()
            if self.internetConect {
                self.logoutVM.logoutRequest { error, data in
                    self.hideLoading()
                    if let error = error {
                        DispatchQueue.main.async {
                            self.view.makeToast(error)
                        }
                        return
                    }
                    
                    guard let _ = data else {return}
                    Defaults.deleteUserData()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3 , execute: {
                        Router().toOptionsSignUpVC()
                    })
                }
            }
            
            // handling code
            UIView.animate(withDuration: 0.3, animations: {
                self.logoutAlertView?.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
                self.logoutAlertView?.alpha = 0
            }) { (success: Bool) in
                self.logoutAlertView?.removeFromSuperview()
                self.logoutAlertView?.alpha = 1
                self.logoutAlertView?.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            }
        }
        
        self.view.addSubview((logoutAlertView)!)
    }
    
    
    func showFailAlert() {
        verifyFaceView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        verifyFaceView?.HandleOkBtn = {
            self.ProcessingLbl.isHidden = true
            self.ProcessingLbl.text = "Processing...".localizedString
            self.ProcessingLbl.textColor = .blue
        }
        
        self.view.addSubview((verifyFaceView)!)
    }
    
    //MARK: - Actions
    
    @IBAction func logoutBtn(_ sender: Any) {
        logout()
    }
    
    @IBAction func editProfileImgBtn(_ sender: Any) {
        if UIDevice.current.userInterfaceIdiom == .pad {
            let settingsActionSheet: UIAlertController = UIAlertController(title:nil, message:nil, preferredStyle: .alert)
            
            settingsActionSheet.addAction(UIAlertAction(title:"Camera".localizedString, style:UIAlertAction.Style.default, handler:{ action in
                self.openCamera()
            }))
            settingsActionSheet.addAction(UIAlertAction(title:"Photo Library".localizedString, style:UIAlertAction.Style.default, handler:{ action in
                self.openLibrary()
            }))
            settingsActionSheet.addAction(UIAlertAction(title:"Cancel".localizedString, style:UIAlertAction.Style.cancel, handler:nil))
            
            present(settingsActionSheet, animated:true, completion:nil)
            
        }else {
            let settingsActionSheet: UIAlertController = UIAlertController(title:nil, message:nil, preferredStyle:UIAlertController.Style.actionSheet)
            
            settingsActionSheet.addAction(UIAlertAction(title:"Camera".localizedString, style:UIAlertAction.Style.default, handler:{ action in
                self.openCamera()
            }))
            settingsActionSheet.addAction(UIAlertAction(title:"Photo Library".localizedString, style:UIAlertAction.Style.default, handler:{ action in
                self.openLibrary()
            }))
            settingsActionSheet.addAction(UIAlertAction(title:"Cancel".localizedString, style:UIAlertAction.Style.cancel, handler:nil))
            
            present(settingsActionSheet, animated:true, completion:nil)
        }
    }
    
    @IBAction func dateBtn(_ sender: Any) {
        calendarView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        calendarView?.HandleOKBtn = {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MM-yyyy"
            self.dateBirthLbl.text = formatter.string(from: (self.calendarView?.calendarView.date)!)
            self.birthDay = formatter.string(from: (self.calendarView?.calendarView.date)!)
            self.dateBirthLbl.textColor = .black
            
            UIView.animate(withDuration: 0.3, animations: {
                self.calendarView?.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
                self.calendarView?.alpha = 0
            }) { (success: Bool) in
                self.calendarView?.removeFromSuperview()
                self.calendarView?.alpha = 1
                self.calendarView?.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            }
        }
        
        calendarView?.HandleCancelBtn = {
            // handling code
            UIView.animate(withDuration: 0.3, animations: {
                self.calendarView?.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
                self.calendarView?.alpha = 0
            }) { (success: Bool) in
                self.calendarView?.removeFromSuperview()
                self.calendarView?.alpha = 1
                self.calendarView?.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            }
        }
        
        self.view.addSubview((calendarView)!)
    }
    
    @IBAction func maleBtn(_ sender: Any) {
        maleImg.image = UIImage(named: "select_ic")
        femaleImg.image = UIImage(named: "unSelect_ic")
        otherImg.image = UIImage(named: "unSelect_ic")
        otherGenderView.isHidden = true
        otherGenderTxt.text = ""
        
        genderString = "male"
    }
    
    @IBAction func femaleBtn(_ sender: Any) {
        femaleImg.image = UIImage(named: "select_ic")
        maleImg.image = UIImage(named: "unSelect_ic")
        otherImg.image = UIImage(named: "unSelect_ic")
        otherGenderView.isHidden = true
        otherGenderTxt.text = ""
        
        genderString = "female"
    }
    
    @IBAction func otherBtn(_ sender: Any) {
        otherImg.image = UIImage(named: "select_ic")
        maleImg.image = UIImage(named: "unSelect_ic")
        femaleImg.image = UIImage(named: "unSelect_ic")
        otherGenderView.isHidden = false
        otherGenderTxt.text = Defaults.OtherGenderName
        
        genderString = "other"
    }
    
    @IBAction func tagsBtn(_ sender: Any) {
        updateUserInterface2()
        if internetConect {
            guard let vc = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "SelectedTagsVC") as? SelectedTagsVC else {return}
            vc.arrSelectedDataIds = tagsid
            vc.arrSelectedDataNames = tagsNames
            vc.onInterestsCallBackResponse = self.OnInterestsCallBack
            self.navigationController?.pushViewController(vc, animated: true)
        }else {
            return
        }
    }
    
    @IBAction func bestDescribesBtn(_ sender: Any) {
        updateUserInterface2()
        if internetConect {
            guard let vc = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "BestDescripsVC") as? BestDescripsVC else {return}
            vc.arrSelectedDataIds = bestDescribesid
            vc.arrSelectedDataNames = bestDescribesNames
            vc.onBestDescripstsCallBackResponse = self.OnbestDescribesCallBack
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    @IBAction func preferToBtn(_ sender: Any) {
        
    }
    
    @IBAction func saveBtn(_ sender: Any) {
        updateUserInterface2()
        if self.attachedImg == false {
            DispatchQueue.main.async {
                self.view.makeToast("Please add profile image".localizedString)
            }
            return
        }else {
            if tagsid.isEmpty {
                DispatchQueue.main.async {
                    self.view.makeToast("Please select your tags".localizedString)
                }
                return
            }else if bestDescribesid.isEmpty {
                DispatchQueue.main.async {
                    self.view.makeToast("Please select your best describes".localizedString)
                }
                return
            }
            else {
                if internetConect {
                    self.saveBtn.setTitle("Saving...", for: .normal)
                    self.saveBtn.isUserInteractionEnabled = false
                    
                    viewmodel.editProfile(withUserName: nameTxt.text!, AndGender: genderString, AndGeneratedUserName: nameTxt.text!, AndBio: bioTxtView.text!, AndBirthdate: dateBirthLbl.text!, OtherGenderName: otherGenderTxt.text!, tagsId: tagsid, attachedImg: self.attachedImg, AndUserImage: self.profileImg.image ?? UIImage(),whatAmILookingFor:"",WhatBestDescrips:bestDescribesid) { error, data in
                        
                        DispatchQueue.main.async {
                            self.saveBtn.setTitle("Save", for: .normal)
                            self.saveBtn.isUserInteractionEnabled = true
                        }
                        
                        if let error = error {
                            DispatchQueue.main.async {
                                self.view.makeToast(error)
                            }
                            return
                        }
                        
                        guard let _ = data else {return}
                        DispatchQueue.main.async {
                            if Defaults.needUpdate == 1 {
                                return
                            }else {
                                Router().toFeed()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func onFaceRegistrationCallBack(_ faceImgOne:UIImage, _ faceImgTwo:UIImage,_ verify:Bool) -> () {
        self.faceImgOne = faceImgOne
        self.faceImgTwo = faceImgTwo
        print("1:\(faceImgOne),2:\(faceImgTwo)")
        
        self.ProcessingLbl.isHidden = false
        faceRecognitionVM.compare(withImage1: self.faceImgOne, AndImage2: self.faceImgTwo) { error, data in
            
            if error != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.ProcessingLbl.text = "Failed".localizedString
                    self.ProcessingLbl.textColor = .red
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.showFailAlert()
                    }
                }
                return
            }
            
            guard let data = data else {return}
            print(data)
            if data == "Matched" {
                DispatchQueue.main.async {
                    self.ProcessingLbl.text = "Matched"
                    self.ProcessingLbl.textColor = .green
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.ProcessingLbl.isHidden = true
                    self.ProcessingLbl.text = "Processing...".localizedString
                    self.ProcessingLbl.textColor = .blue
                }
                
                DispatchQueue.main.async {
                    self.profileImg.image = faceImgOne
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.ProcessingLbl.text = data
                    self.ProcessingLbl.textColor = .red
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        //                        self.showFailAlert()
                        self.ProcessingLbl.isHidden = true
                        self.ProcessingLbl.text = "Processing...".localizedString
                        self.ProcessingLbl.textColor = .blue
                    }
                }
            }
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
            imagePicker.sourceType = .camera
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
            let size = CGSize(width: screenW, height: screenW)
            let img = image.crop(to: size)
            self.profileImg.image = img
            self.attachedImg = true
            
            //            self.faceImgOne = image
            //
            //            guard let vc = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "FaceRecognitionVC") as? FaceRecognitionVC else {return}
            //            vc.faceImgOne = self.faceImgOne
            //            vc.onFaceRegistrationCallBackResponse = self.onFaceRegistrationCallBack
            //            self.navigationController?.pushViewController(vc, animated: true)
        })
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated:true, completion: nil)
    }
}

//text view delegate
extension EditMyProfileVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
//        if textView == bioTxtView {
        placeHolderLbl.isHidden = !bioTxtView.text.isEmpty
//        }else {
//            lookingforPlaceHolderLbl.isHidden = !lookingforTxtView.text.isEmpty
//        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//        if textView == bioTxtView {
            let newText = (bioTxtView.text as NSString).replacingCharacters(in: range, with: text)
            return newText.count < 150
//        }else {
//            let newText = (lookingforTxtView.text as NSString).replacingCharacters(in: range, with: text)
//            return newText.count < 150
//        }
    }
}

//tags list
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

extension EditMyProfileVC {
    func initCloseApp() {
        
        var imageName = ""
//        if Language.currentLanguage() == "ar" {
            imageName = "back_icon"
//        }else {
//            imageName = "back_icon"
//        }
        
        let button = UIButton.init(type: .custom)
        let image = UIImage.init(named: imageName)
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        button.setImage(image, for: .normal)
        image?.withTintColor(UIColor.blue)
        button.addTarget(self, action:  #selector(backToInbox), for: .touchUpInside)
        //        button.sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.leftBarButtonItem = barButton
    }
    
    @objc func backToInbox() {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
        }
    }
}
