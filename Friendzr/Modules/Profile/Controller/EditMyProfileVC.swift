//
//  EditMyProfileVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 16/08/2021.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import ListPlaceholder
import QCropper
import Network
import SafariServices
import AWSRekognition

class EditMyProfileVC: UIViewController,UIPopoverPresentationControllerDelegate , SFSafariViewControllerDelegate{
    
    //MARK: - Outlets
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var superView: UIView!
    @IBOutlet weak var nameTxt: UITextField!
    @IBOutlet weak var dateBirthdayTxt: UITextField!
    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var maleImg: UIImageView!
    @IBOutlet weak var femaleImg: UIImageView!
    @IBOutlet weak var otherImg: UIImageView!
    //    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var aboutMeView: UIView!
    @IBOutlet weak var bioTxtView: UITextView!
    @IBOutlet weak var placeHolderLbl: UILabel!
    @IBOutlet weak var tagsSubView: UIView!
    @IBOutlet weak var tagsView: UIView!
    @IBOutlet weak var tagsViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tagsListView: TagListView!
    @IBOutlet weak var selectTagsLbl: UILabel!
    @IBOutlet weak var bestDescribesSubView: UIView!
    @IBOutlet weak var bestDescribesView: UIView!
    @IBOutlet weak var bestDescribesViewHeight: NSLayoutConstraint!
    @IBOutlet weak var bestDescribesListView: TagListView!
    @IBOutlet weak var selectbestDescribesLbl: UILabel!
    @IBOutlet weak var preferToSubView: UIView!
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
    @IBOutlet weak var universalCodeView: UIView!
    @IBOutlet weak var universalCodeTxt: UITextField!
    @IBOutlet weak var additionalPhotoBtn: UIButton!
    @IBOutlet weak var additionalPhotoBtnView: UIView!
    @IBOutlet weak var additionalPhotosBtnViewHeight: NSLayoutConstraint!
    
    
    //MARK: - Properties
    lazy var logoutAlertView = Bundle.main.loadNibNamed("BlockAlertView", owner: self, options: nil)?.first as? BlockAlertView
    lazy var calendarView = Bundle.main.loadNibNamed("CalendarView", owner: self, options: nil)?.first as? CalendarView
    lazy var verifyFaceView = Bundle.main.loadNibNamed("VerifyFaceRegistrationAlertView", owner: self, options: nil)?.first as? VerifyFaceRegistrationAlertView
    
    
    var genderString = ""
    let imagePicker = UIImagePickerController()
    var viewmodel:EditProfileViewModel = EditProfileViewModel()
    var profileVM: ProfileViewModel = ProfileViewModel()
    var profileModel:ProfileObj? = nil
    var logoutVM:LogoutViewModel = LogoutViewModel()
    var faceRecognitionVM:FaceRecognitionViewModel = FaceRecognitionViewModel()
    var allValidatConfigVM:AllValidatConfigViewModel = AllValidatConfigViewModel()
    
    var iamViewModel = IamViewModel()
    var IamArr:[IamObj]? = [IamObj]()
    
    var preferToViewModel = PreferToViewModel()
    var preferToArr:[PreferToObj]? = [PreferToObj]()
    
    var tagsid:[String] = [String]()
    var tagsNames:[String] = [String]()
    var iamid:[String] = [String]()
    var iamNames:[String] = [String]()
    
    var preferToid:[String] = [String]()
    var preferToNames:[String] = [String]()
    
//    var attachedImg:Bool = false
    var birthDay = ""
    
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
    var firstLogin:Int? = 0
    
    var imgTake: Int = 0
    var imageIsVerified:Bool = false
    let datePicker = UIDatePicker()
    
    var infoLinksMap: [Int:String] = [1000:""]
    var rekognitionObject:AWSRekognition?
    
    var checkoutName:String = ""
    
    var profileImages:[UIImage] = [UIImage]()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Edit Profile".localizedString
        setup()
        
        
        DispatchQueue.main.async {
            if self.checkoutName == "editProfile" ||  self.checkoutName == "interests" || self.checkoutName == "additionalImages" {
                self.getProfileInformation()
            }
            else {
//                self.getProfileInformation()
                self.setupData()
            }
        }
        
        showDatePicker()
        
        DispatchQueue.main.async {
            self.updateUserInterface()
        }
        
        initSaveBarButton(istap: false)
        
        if Defaults.isFirstLogin == false {
            imgTake = 0
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Defaults.availableVC = "EditMyProfileVC"
        print("availableVC >> \(Defaults.availableVC)")
        
        if needUpdateVC == true {
            logoutBtn.isHidden = false
            initCloseApp()
        }else {
            logoutBtn.isHidden = true
            initBackButton()
        }
        
        CancelRequest.currentTask = false
        
        setupNavBar()
        hideNavigationBar(NavigationBar: false, BackButton: false)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.hideLoading()
        CancelRequest.currentTask = true
        
    }
    
    //MARK: - APIs
    func getAllValidatConfig() {
        allValidatConfigVM.getAllValidatConfig()
        allValidatConfigVM.userValidationConfig.bind { [weak self]value in
        }
        
        // Set View Model Event Listener
        allValidatConfigVM.errorMsg.bind { [weak self]error in
            DispatchQueue.main.async {
                print(error)
            }
        }
    }

    func getProfileInformation() {
        profileVM.getProfileInfo()
        profileVM.userModel.bind { [weak self]value in
            DispatchQueue.main.async {
                
                self?.profileModel = value
                
                self?.setupData()
                
                if Defaults.imageIsVerified == true {
                    self?.additionalPhotoBtnView.isHidden = false
                }else {
                    self?.additionalPhotoBtnView.isHidden = true
                }
                
                self?.setupDeepLinkInEditProfile()
            }
        }
        
        // Set View Model Event Listener
        profileVM.error.bind { [weak self]error in
            DispatchQueue.main.async {
                self?.hideLoading()
                if error == "Internal Server Error" {
                    self?.HandleInternetConnection()
                }else {
                    DispatchQueue.main.async {
                        self?.view.makeToast(error)
                    }
                    
                }
            }
        }
    }
    
    //MARK: - Helpers
    func updateUserInterface() {
        appDelegate.networkReachability()
        
        switch Network.reachability.status {
        case .unreachable:
            DispatchQueue.main.async {
                NetworkConected.internetConect = false
                self.HandleInternetConnection()
            }
        case .wwan:
            DispatchQueue.main.async {
                NetworkConected.internetConect = true
                DispatchQueue.main.async {
                    self.getAllValidatConfig()
                    
                    DispatchQueue.main.async {
                        self.getAllBestDescrips()
                    }
                    DispatchQueue.main.async {
                        self.getAllPreferTo()
                    }
                }
            }
        case .wifi:
            DispatchQueue.main.async {
                NetworkConected.internetConect = true
                DispatchQueue.main.async {
                    self.getAllValidatConfig()
                    
                    DispatchQueue.main.async {
                        self.getAllBestDescrips()
                    }
                    DispatchQueue.main.async {
                        self.getAllPreferTo()
                    }
                }
            }
        }
        
        print("Reachability Summary")
        print("Status:", Network.reachability.status)
        print("HostName:", Network.reachability.hostname ?? "nil")
        print("Reachable:", Network.reachability.isReachable)
        print("Wifi:", Network.reachability.isReachableViaWiFi)
    }
    
    func setup() {
        nameView.cornerRadiusView(radius: 8)
        additionalPhotoBtn.cornerRadiusView(radius: 8)
        dateView.cornerRadiusView(radius: 8)
        bioTxtView.cornerRadiusView(radius: 8)
        universalCodeView.cornerRadiusView(radius: 8)
        tagsSubView.cornerRadiusView(radius: 8)
        preferToSubView.cornerRadiusView(radius: 8)
        bestDescribesSubView.cornerRadiusView(radius: 8)
        aboutMeView.cornerRadiusView(radius: 8)
        otherGenderSubView.cornerRadiusView(radius: 8)
        logoutBtn.cornerRadiusView(radius: 8)
        logoutBtn.setBorder(color: UIColor.FriendzrColors.primary?.cgColor, width: 1.0)
        profileImg.setBorder(color: UIColor.FriendzrColors.primary?.cgColor, width: 1.0)
        
        
        profileImg.cornerRadiusForHeight()
        bioTxtView.delegate = self
        tagsListView.delegate = self
        bestDescribesListView.delegate = self
        removeNavigationBorder()
        
        nameTxt.addDoneOnKeyboard(withTarget: self, action: #selector(dismissKeyboard))
        dateBirthdayTxt.addDoneOnKeyboard(withTarget: self, action: #selector(dismissKeyboard))
        otherGenderTxt.addDoneOnKeyboard(withTarget: self, action: #selector(dismissKeyboard))
        bioTxtView.addDoneOnKeyboard(withTarget: self, action: #selector(dismissKeyboard))
    }
    
    func setupData() {
        if needUpdateVC {
            nameTxt.text = ""
        }
        else {
            nameTxt.text = profileModel?.userName
            universalCodeTxt.text = profileModel?.universityCode
            
            if profileModel?.bio != "" {
                if profileModel?.bio.count == 1 && profileModel?.bio == "."{
                    bioTxtView.text = ""
                    placeHolderLbl.isHidden = false
                }else {
                    bioTxtView.text = profileModel?.bio
                    placeHolderLbl.isHidden = true
                }
            }
            else {
                bioTxtView.text = ""
                placeHolderLbl.isHidden = false
            }
            
            dateBirthdayTxt.text = profileModel?.birthdate
            
            profileImg.sd_setImage(with: URL(string: profileModel?.userImage ?? "" ), placeholderImage: UIImage(named: "userPlaceHolderImage"))

            //            if Defaults.isFirstLogin == false {
            //                profileImg.sd_setImage(with: URL(string: profileModel?.userImage ?? "" ), placeholderImage: UIImage(named: "userPlaceHolderImage"))
            //                self.attachedImg = true
            //            }
            //            else {
            //                self.attachedImg = false
            //            }
            
            DispatchQueue.main.async {
                self.setupMyProfileTags()
            }
            
            DispatchQueue.main.async {
                self.setupMyIamListProfile()
            }
            DispatchQueue.main.async {
                self.setupMyPrefertoListProfile()
            }
            DispatchQueue.main.async {
                self.setupMyGinderProfile()
            }
            
            DispatchQueue.main.async {
                self.setupMyAdditionalImagesBtn()
            }
            
        }
    }
    
    func onAdditionalPhotosCallBack(_ data: [UIImage], _ value: [String]) -> () {
        print("self.profileImages.cout \(self.profileImages.count)")
        self.profileImages = data
    }
    
    
    // Send Request for Facial Recognition API
    func FacialRecognitionAPI(imageOne:UIImage,imageTwo:UIImage) {
        
        self.ProcessingLbl.isHidden = false
        self.imgTake = 1
        print(imgTake)
        
        let key = "testCompareFaces"
        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: "AKIA5SBX6UH4VP2R7BWK", secretKey:"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")
        let configuration = AWSServiceConfiguration(region:.USEast1, credentialsProvider:credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        AWSRekognition.register(with: configuration!, forKey: key)
        let rekognition = AWSRekognition(forKey: key)
        
        guard let request = AWSRekognitionCompareFacesRequest() else {
            puts("Unable to initialize AWSRekognitionDetectLabelsRequest.")
            return
        }
        
        let sourceImage = AWSRekognitionImage()
        sourceImage!.bytes = imageOne.jpegData(compressionQuality: 0)// Specify your source image
        request.sourceImage = sourceImage
        
        let targetImage = AWSRekognitionImage()
        targetImage!.bytes = imageTwo.jpegData(compressionQuality: 0) // Specify your target image
        request.targetImage = targetImage
        
        let startDate = Date()
        rekognition.compareFaces(request) { (respone, error) in
            if error == nil {
                if let response = respone {
                    print(response)
                    let face1 = response.faceMatches?.first
                    if Double(truncating: face1?.similarity.value ?? 0) > 0.9 {
                        let executionTimeWithSuccessVC1 = Date().timeIntervalSince(startDate)
                        print("executionTimeWithSuccessVC1 \(executionTimeWithSuccessVC1 * 1000) second")
                        
                        DispatchQueue.main.async {
                            self.ProcessingLbl.text = "Matched"
                            self.ProcessingLbl.textColor = .green
//                            self.attachedImg = true
                        }
                        
                        let executionTimeWithSuccessVC2 = Date().timeIntervalSince(startDate)
                        print("executionTimeWithSuccessVC2 \(executionTimeWithSuccessVC2 * 1000) second")
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self.ProcessingLbl.isHidden = true
                            self.ProcessingLbl.text = "Processing...".localizedString
                            self.ProcessingLbl.textColor = .blue
                        }
                        
                        DispatchQueue.main.async {
                            self.profileImg.image = imageOne
                            self.imgTake = 0
                            self.imageIsVerified = true
                            self.additionalPhotoBtnView.isHidden = false
                        }
                    }
                    else {
                        let executionTimeWithSuccessVC1 = Date().timeIntervalSince(startDate)
                        print("executionTimeWithSuccessVC1 \(executionTimeWithSuccessVC1 * 1000) second")
                        
                        DispatchQueue.main.async {
                            self.ProcessingLbl.text = "Not Matched"
                            self.ProcessingLbl.textColor = .red
                            
//                            if Defaults.isFirstLogin == false {
//                                self.attachedImg = true
//                            }
//                            else {
//                                self.attachedImg = false
//                            }
                        }
                        
                        let executionTimeWithSuccessVC2 = Date().timeIntervalSince(startDate)
                        print("executionTimeWithSuccessVC2 \(executionTimeWithSuccessVC2 * 1000) second")
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self.ProcessingLbl.isHidden = true
                            self.ProcessingLbl.text = "Processing...".localizedString
                            self.ProcessingLbl.textColor = .blue
                            self.imgTake = 0
                            
//                            self.profileImg.image = self.faceImgOne
                            self.imageIsVerified = false
                            self.additionalPhotoBtnView.isHidden = true
                        }
                    }
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.ProcessingLbl.text = "Failed".localizedString
                    self.ProcessingLbl.textColor = .red
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.showFailAlert()
                    }
                    
//                    if Defaults.isFirstLogin == false {
//                        self.attachedImg = true
//                    }
//                    else {
//                        self.attachedImg = false
//                    }
                    
//                    self.profileImg.image = self.faceImgOne
                    self.imageIsVerified = false
                    self.additionalPhotoBtnView.isHidden = true

                    self.imgTake = 0
                    let executionTimeWithSuccessVC3 = Date().timeIntervalSince(startDate)
                    print("executionTimeWithSuccessVC3 \(executionTimeWithSuccessVC3 * 1000) second")
                    
                }
                return
            }
        }
    }
    
    func onForgetAddPictureCallBack(_ tapSelected: String) -> () {
        if tapSelected == "UploadAndVerify" {
            self.presentActionSheetImage()
        }
        else if tapSelected == "CompleteLater" {
            self.profileImg.image = UIImage(named: "userPlaceHolderImage")
            self.imageIsVerified = false
            self.imgTake = 0
            self.additionalPhotoBtnView.isHidden = true
            
            DispatchQueue.main.async {
                self.editSaving()
            }
        }
    }
    
    func onVerifyCallBack(_ tapSelected: String) -> () {
        if tapSelected == "verify" {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .camera
                imagePicker.allowsEditing = false
                imagePicker.cameraCaptureMode = .photo
                imagePicker.cameraDevice = .front
                imagePicker.cameraFlashMode = .off
                imagePicker.cameraViewTransform = .identity
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
        else if tapSelected == "skip" {
            self.profileImg.image = self.faceImgOne
            self.imageIsVerified = false
            self.imgTake = 0
            self.additionalPhotoBtnView.isHidden = true
        }
        else if tapSelected == "remove" {
            self.profileImg.image = UIImage(named: "userPlaceHolderImage")
            self.imageIsVerified = false
            self.imgTake = 0
            self.additionalPhotoBtnView.isHidden = true
        }
    }
    
    func HandleInternetConnection() {
        self.view.makeToast("Network is unavailable, please try again!".localizedString)
    }
    
    //Logout
    func logout() {
        logoutAlertView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        logoutAlertView?.titleLbl.text = "Confirm?".localizedString
        logoutAlertView?.detailsLbl.text = "Are you sure you want to logout?".localizedString
        
        logoutAlertView?.HandleConfirmBtn = {
            if NetworkConected.internetConect {
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
                        Router().toOptionsSignUpVC(IsLogout: true)
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
    
    func showDatePicker(){
        //Formate Date
        
        datePicker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        
        datePicker.maximumDate = Date()
        
        //ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker))
        
        doneButton.tintColor = UIColor.FriendzrColors.primary!
        cancelButton.tintColor = UIColor.red
        
        toolbar.setItems([cancelButton,spaceButton,doneButton], animated: false)
        
        dateBirthdayTxt.inputAccessoryView = toolbar
        dateBirthdayTxt.inputView = datePicker
        
    }
    
    @objc func donedatePicker(){
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        dateBirthdayTxt.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
    @objc func cancelDatePicker(){
        self.view.endEditing(true)
    }
    
    //MARK: - Actions
    @IBAction func logoutBtn(_ sender: Any) {
        logout()
    }
    
     func presentActionSheetImage() {
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
    
    @IBAction func editProfileImgBtn(_ sender: Any) {
        presentActionSheetImage()
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
        if NetworkConected.internetConect {
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
        if NetworkConected.internetConect {
            guard let vc = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "IamVC") as? IamVC else {return}
            vc.iamModelArray = self.IamArr
            vc.arrSelectedDataIds = iamid
            vc.arrSelectedDataNames = iamNames
            vc.onIamCallBackResponse = self.OnIamCallBack
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func preferToBtn(_ sender: Any) {
        if NetworkConected.internetConect {
            guard let vc = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "PreferToVC") as? PreferToVC else {return}
            vc.preferToModelArray = self.preferToArr
            vc.arrSelectedDataIds = preferToid
            vc.arrSelectedDataNames = preferToNames
            vc.onPreferToCallBackResponse = self.OnPreferToCallBack
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func additionalPhotoBtn(_ sender: Any) {
        guard let vc = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "AdditionalImagesVC") as? AdditionalImagesVC else {return}
        vc.onAdditionalPhotosCallBackResponse = self.onAdditionalPhotosCallBack
        vc.profileImages = self.profileImages
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: - Extensions UIImagePickerControllerDelegate && UINavigationControllerDelegate
extension EditMyProfileVC : UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    //MARK: - Take Picture
    func openCamera(){
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = false
            imgTake = 1
            print(imgTake)
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    //MARK: - Open Library
    func openLibrary(){
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = false
            imgTake = 1
            print(imgTake)
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if imgTake == 1 {
            let image1 = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            
            let originImg = image1.fixOrientation()
            let cropper = CustomCropperViewController(originalImage: originImg)
            cropper.delegate = self
            self.imgTake = 2
            print(self.imgTake)
            
            self.navigationController?.pushViewController(cropper, animated: true)
            
            picker.dismiss(animated:true, completion: {
                
            })
        }
        else if self.imgTake == 2 {
            let image2 = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            picker.dismiss(animated:true, completion: {
//                self.attachedImg = true
                self.faceImgTwo = image2.fixOrientation()
                self.FacialRecognitionAPI(imageOne: self.faceImgOne, imageTwo: self.faceImgTwo)
            })
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print(imgTake)
        
        self.tabBarController?.tabBar.isHidden = false
        
        picker.dismiss(animated:true, completion: {
//            if Defaults.isFirstLogin == false {
//                self.attachedImg = true
//            }else {
//                self.attachedImg = false
//            }
            self.imgTake = 0
        })
        
//        self.profileImg.image = self.faceImgOne
//        self.imageIsVerified = false
//        self.additionalPhotoBtnView.isHidden = true
    }
}


//MARK: - CropperViewControllerDelegate
extension EditMyProfileVC: CropperViewControllerDelegate {
    
    func aspectRatioPickerDidSelectedAspectRatio(_ aspectRatio: AspectRatio) {
        print("\(String(describing: aspectRatio.dictionary))")
    }
    
    func cropperDidConfirm(_ cropper: CropperViewController, state: CropperState?) {
        cropper.onPopup()
        if let state = state,
           let image = cropper.originalImage.cropped(withCropperState: state) {
            self.faceImgOne = image
//            self.attachedImg = true
            imgTake = 2
            
            guard let popupVC = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "FacialRecognitionPopUpView") as? FacialRecognitionPopUpView else {return}
            popupVC.modalPresentationStyle = .overCurrentContext
            popupVC.modalTransitionStyle = .crossDissolve
            let pVC = popupVC.popoverPresentationController
            pVC?.permittedArrowDirections = .any
            pVC?.delegate = self
            pVC?.sourceRect = CGRect(x: 100, y: 100, width: 1, height: 1)
            popupVC.faceImgOne = self.faceImgOne
            popupVC.onVerifyCallBackResponse = self.onVerifyCallBack
            self.present(popupVC, animated: true, completion: nil)
            
            print(cropper.isCurrentlyInInitialState)
            print(image)
        }
    }
    
    func cropperDidCancel(_ cropper: CropperViewController) {
        cropper.onPopup()
        imgTake = 0

//        if Defaults.isFirstLogin == false {
//            imgTake = 0
//            self.attachedImg = true
//        }else {
//            self.attachedImg = false
//        }
    }
}

//MARK: -  text view delegate
extension EditMyProfileVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeHolderLbl.isHidden = !bioTxtView.text.isEmpty
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (bioTxtView.text as NSString).replacingCharacters(in: range, with: text)
        return newText.count < 300
    }
}

//MARK: -  TagListViewDelegate
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
        imageName = "back_icon"
        let button = UIButton.init(type: .custom)
        let image = UIImage.init(named: imageName)
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        button.setImage(image, for: .normal)
        image?.withTintColor(UIColor.blue)
        button.addTarget(self, action:  #selector(backToInbox), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.leftBarButtonItem = barButton
    }
    
    @objc func backToInbox() {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
        }
    }
    
    //init Add Group Bar Button
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
        hideKeyboard()
        
        print(imgTake)
        //        if self.attachedImg == false {
        //            DispatchQueue.main.async {
        //                self.view.makeToast("Please add a profile image".localizedString)
        //            }
        //            initSaveBarButton(istap: false)
        //            return
        //        }
        //        else {
        if imgTake == 0 {
            if tagsid.isEmpty {
                DispatchQueue.main.async {
                    self.view.makeToast("Please select what you enjoy doing".localizedString)
                }
                initSaveBarButton(istap: false)
                return
            }
            else {
                if iamid.isEmpty {
                    iamid.append(Defaults.iamid)
                }
                
                if preferToid.isEmpty {
                    preferToid.append(Defaults.preferToid)
                }
                
                if bioTxtView.text == "" {
                    bioTxtView.text = "."
                }
                
                if NetworkConected.internetConect {
                    if self.imageIsVerified == false {
                        guard let popupVC = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "ForgetAddPictureVC") as? ForgetAddPictureVC else {return}
                        popupVC.modalPresentationStyle = .overCurrentContext
                        popupVC.modalTransitionStyle = .crossDissolve
                        let pVC = popupVC.popoverPresentationController
                        pVC?.permittedArrowDirections = .any
                        pVC?.delegate = self
                        pVC?.sourceRect = CGRect(x: 100, y: 100, width: 1, height: 1)
                        popupVC.onForgetAddPictureCallBackResponse = self.onForgetAddPictureCallBack
                        self.present(popupVC, animated: true, completion: nil)
                    }
                    else {
                        editSaving()
                    }
                }
            }
        }
        else {
            self.view.makeToast("Please wait a moment while the image comparison process is completed")
        }
        //        }
    }
    
    func updateImagesUser() {
        self.viewmodel.UpdateUserImages(WithAchedImg: true, AndUserImage: self.profileImages) { error, data in
            if let error = error {
                DispatchQueue.main.async {
                    self.view.makeToast(error)
                }
                return
            }
            
            guard data != nil else {return}
            
            DispatchQueue.main.async {
                self.additionalPhotoBtn.isUserInteractionEnabled = true
                
                if Defaults.isWhiteLable {
                    Router().toInbox()
                }else {
                    if Defaults.needUpdate == 1 {
                        return
                    } else {
                        if Defaults.isFirstLogin == false {//toprofile
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                self.onPopup()
                            }
                        }
                        else if Defaults.isFirstLogin == true {//tofeed if socail media login
                            Router().toFeed()
                        }
                        else {//to login
                            Router().toOptionsSignUpVC(IsLogout: true)
                        }
                    }
                }
            }
        }
    }
    
    func editSaving() {
        initSaveBarButton(istap: true)
        self.additionalPhotoBtn.isUserInteractionEnabled = false
        let startDate = Date()
        viewmodel.editProfile(withUserName: nameTxt.text!, AndGender: genderString, AndGeneratedUserName: nameTxt.text!, AndBio: bioTxtView.text!, AndBirthdate: dateBirthdayTxt.text!, OtherGenderName: otherGenderTxt.text!, tagsId: tagsid, attachedImg: self.imageIsVerified, AndUserImage: self.profileImg.image ?? UIImage(), imageIsVerified: self.imageIsVerified,WhatBestDescrips:iamid, preferto: preferToid, universityCode: universalCodeTxt.text!) { error, data in
            
            if let error = error {
                DispatchQueue.main.async {
                    self.view.makeToast(error)
                    self.initSaveBarButton(istap: false)
                    self.additionalPhotoBtn.isUserInteractionEnabled = true
                }
                return
            }
            
            let executionTimeWithSuccessFeed2 = Date().timeIntervalSince(startDate)
            print("executionTimeWithSuccess-edit \(executionTimeWithSuccessFeed2) second")
            
            guard let data = data else {return}
            
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name("updateImageMore"), object: nil, userInfo: nil)
            }
            
            DispatchQueue.main.async {
                if self.imageIsVerified == true || self.profileImages.count != 0 {
                    self.updateImagesUser()
                }
                else {
                    DispatchQueue.main.async {
                        self.additionalPhotoBtn.isUserInteractionEnabled = true
                        
                        if Defaults.isWhiteLable {
                            Router().toInbox()
                        }else {
                            if Defaults.needUpdate == 1 {
                                return
                            } else {
                                if Defaults.isFirstLogin == false {//toprofile
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                        self.onPopup()
                                    }
                                }
                                else if Defaults.isFirstLogin == true {//tofeed if socail media login
                                    Router().toFeed()
                                }
                                else {//to login
                                    Router().toOptionsSignUpVC(IsLogout: true)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

extension EditMyProfileVC {
    func getAllBestDescrips() {
        iamViewModel.getAllIam()
        iamViewModel.IAM.bind { [weak self] value in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                var arr:[IamObj]? = [IamObj]()
                for item in value {
                    arr?.append(item)
                }
                
                for itm in arr ?? [] {
                    if itm.name?.contains("#") == true {
                        Defaults.iamid = itm.id ?? ""
                    }else {
                        self?.IamArr?.append(itm)
                    }
                }
            })
        }
        
        // Set View Model Event Listener
        iamViewModel.error.bind { error in
            DispatchQueue.main.async {
                self.view.makeToast(error)
            }
        }
    }
    
    //MARK: - APIs
    func getAllPreferTo() {
        preferToViewModel.getAllPreferTo()
        preferToViewModel.PreferTo.bind { [weak self] value in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                var arr:[PreferToObj]? = [PreferToObj]()
                for item in value {
                    arr?.append(item)
                }
                
                for itm in arr ?? [] {
                    if itm.name?.contains("#") == true {
                        Defaults.preferToid = itm.id ?? ""
                    }else {
                        self?.preferToArr?.append(itm)
                    }
                }
            })
        }
        
        // Set View Model Event Listener
        preferToViewModel.error.bind { [weak self] error in
            DispatchQueue.main.async {
                DispatchQueue.main.async {
                    self?.view.makeToast(error)
                }
                
            }
        }
    }
}
