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
import QCropper
import Network
import SafariServices
import AWSRekognition

class EditMyProfileVC: UIViewController,UIPopoverPresentationControllerDelegate , SFSafariViewControllerDelegate{
    
    //MARK:- Outlets
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var superView: UIView!
    @IBOutlet weak var nameTxt: UITextField!
    @IBOutlet weak var dateBirthdayTxt: UITextField!
    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var maleImg: UIImageView!
    @IBOutlet weak var femaleImg: UIImageView!
    @IBOutlet weak var otherImg: UIImageView!
    @IBOutlet weak var saveBtn: UIButton!
    
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

    //MARK: - Properties
    
    lazy var logoutAlertView = Bundle.main.loadNibNamed("BlockAlertView", owner: self, options: nil)?.first as? BlockAlertView
    lazy var calendarView = Bundle.main.loadNibNamed("CalendarView", owner: self, options: nil)?.first as? CalendarView
    lazy var verifyFaceView = Bundle.main.loadNibNamed("VerifyFaceRegistrationAlertView", owner: self, options: nil)?.first as? VerifyFaceRegistrationAlertView
    
    
    var genderString = ""
    let imagePicker = UIImagePickerController()
    var viewmodel:EditProfileViewModel = EditProfileViewModel()
    var profileModel:ProfileObj? = nil
    var logoutVM:LogoutViewModel = LogoutViewModel()
    var faceRecognitionVM:FaceRecognitionViewModel = FaceRecognitionViewModel()
    
    var allValidatConfigVM:AllValidatConfigViewModel = AllValidatConfigViewModel()

    var tagsid:[String] = [String]()
    var tagsNames:[String] = [String]()
    var iamid:[String] = [String]()
    var iamNames:[String] = [String]()

    var preferToid:[String] = [String]()
    var preferToNames:[String] = [String]()

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
    var firstLogin:Int? = 0
    var imgTake: Int = 0
    
    let datePicker = UIDatePicker()

    
    var infoLinksMap: [Int:String] = [1000:""]
    var rekognitionObject:AWSRekognition?

    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Edit Profile".localizedString
        setup()
        setupDate()
        
        DispatchQueue.main.async {
            self.updateUserInterface()
        }
        
        showDatePicker()
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
    
    //MARK: - Helpers
    func updateUserInterface() {
        let monitor = NWPathMonitor()
        
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                DispatchQueue.main.async {
                    self.internetConect = true
                    DispatchQueue.main.async {
                        self.getAllValidatConfig()
                    }
                    
                    DispatchQueue.main.async {
                        self.setupDate()
                    }
                }
            }else {
                DispatchQueue.main.async {
                    self.internetConect = false
                    self.HandleInternetConnection()
                }
            }
        }
        
        let queue = DispatchQueue(label: "Network")
        monitor.start(queue: queue)
    }
    
    func HandleInternetConnection() {
        self.view.makeToast("Network is unavailable, please try again!".localizedString)
    }
    
    func setup() {
        saveBtn.cornerRadiusView(radius: 8)
        nameView.cornerRadiusView(radius: 8)
        dateView.cornerRadiusView(radius: 8)
        bioTxtView.cornerRadiusView(radius: 8)
        tagsSubView.cornerRadiusView(radius: 8)
        preferToSubView.cornerRadiusView(radius: 8)
        bestDescribesSubView.cornerRadiusView(radius: 8)
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

    func getAllValidatConfig() {
        allValidatConfigVM.getAllValidatConfig()
        allValidatConfigVM.userValidationConfig.bind { [unowned self]value in
        }
        
        // Set View Model Event Listener
        allValidatConfigVM.errorMsg.bind { [unowned self]error in
            DispatchQueue.main.async {
                print(error)
            }
        }
    }
    
    func setupDate() {
        if needUpdateVC {
            nameTxt.text = Defaults.userName
        }
        else {
            nameTxt.text = profileModel?.userName
            
            if profileModel?.bio != "" {
                bioTxtView.text = profileModel?.bio
                placeHolderLbl.isHidden = true
            }
            else {
                bioTxtView.text = ""
                placeHolderLbl.isHidden = false
            }
            
            dateBirthdayTxt.text = profileModel?.birthdate
            
            if profileModel?.userImage != "" {
                profileImg.sd_setImage(with: URL(string: profileModel?.userImage ?? "" ), placeholderImage: UIImage(named: "placeHolderApp"))
                self.attachedImg = true
            }
            else {
                self.attachedImg = false
            }
            
            tagsListView.removeAllTags()
            tagsid.removeAll()
            tagsNames.removeAll()
            for itm in profileModel?.listoftagsmodel ?? [] {
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
            iamid.removeAll()
            iamNames.removeAll()
            for itm in profileModel?.iamList ?? [] {
                bestDescribesListView.addTag(tagId: itm.tagID, title: "#\(itm.tagname)")
                iamid.append(itm.tagID)
                iamNames.append(itm.tagname)
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
            
            
            
            preferToListView.removeAllTags()
            preferToNames.removeAll()
            preferToid.removeAll()
            for itm in profileModel?.prefertoList ?? [] {
                preferToListView.addTag(tagId: itm.tagID, title: "#\(itm.tagname)")
                preferToid.append(itm.tagID)
                preferToNames.append(itm.tagname)
            }
            
            if preferToListView.rows == 0 {
                preferToViewHeight.constant = 45
                selectPreferToLbl.isHidden = false
                selectPreferToLbl.textColor = .lightGray
            }else {
                preferToViewHeight.constant = CGFloat(preferToListView.rows * 25) + 25
                selectPreferToLbl.isHidden = true
                
                print("bestViewHeight.constant >> \(preferToViewHeight.constant)")
            }
            
            preferToListView.textFont = UIFont(name: "Montserrat-Regular", size: 10)!
            
            if preferToListView.rows == 0 {
                preferToTopSpaceLayout.constant = 5
                preferToBottomSpaceLayout.constant = 5
            }else if preferToListView.rows == 1 {
                preferToTopSpaceLayout.constant = 25
                preferToBottomSpaceLayout.constant = 5
            }else if preferToListView.rows == 2 {
                preferToTopSpaceLayout.constant = 16
                preferToBottomSpaceLayout.constant = 5
            }else if preferToListView.rows == 3 {
                preferToTopSpaceLayout.constant = 10
                preferToBottomSpaceLayout.constant = 5
            }else if preferToListView.rows == 4 {
                preferToTopSpaceLayout.constant = 10
                preferToBottomSpaceLayout.constant = 17
            }
            
            
            
            if profileModel?.gender == "male" {
                maleImg.image = UIImage(named: "select_ic")
                femaleImg.image = UIImage(named: "unSelect_ic")
                otherImg.image = UIImage(named: "unSelect_ic")
                otherGenderView.isHidden = true
                otherGenderTxt.text = ""
                
                genderString = "male"
            }else if profileModel?.gender == "female" {
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
                otherGenderTxt.text = profileModel?.otherGenderName
                
                genderString = "other"
            }
            
        }
    }
    
    func OnInterestsCallBack(_ data: [String], _ value: [String]) -> () {
        print(data, value)
        
        selectTagsLbl.isHidden = true
        tagsListView.removeAllTags()
        tagsNames.removeAll()
        for item in value {
            tagsListView.addTag(tagId: "", title: "#" + (item).capitalizingFirstLetter())
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
        }else {
            tagsTopSpaceLayout.constant = 8
            tagsBottomSpaceLayout.constant = 20
        }
        
    }
    
    func OnIamCallBack(_ data: [String], _ value: [String]) -> () {
        print(data, value)
        
        selectbestDescribesLbl.isHidden = true
        bestDescribesListView.removeAllTags()
        iamNames.removeAll()
        for item in value {
            bestDescribesListView.addTag(tagId: "", title: "#" + (item).capitalizingFirstLetter())
            iamNames.append(item)
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
        
        iamid.removeAll()
        for itm in data {
            iamid.append(itm)
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
        }else {
            bestDescribessTopSpaceLayout.constant = 8
            bestDescribesBottomSpaceLayout.constant = 20
        }
        
    }

    func OnPreferToCallBack(_ data: [String], _ value: [String]) -> () {
        print(data, value)
        
        selectPreferToLbl.isHidden = true
        preferToListView.removeAllTags()
        preferToNames.removeAll()
        for item in value {
            preferToListView.addTag(tagId: "", title: "#" + (item).capitalizingFirstLetter())
            preferToNames.append(item)
        }
        
        if preferToListView.rows == 0 {
            preferToViewHeight.constant = 45
            selectPreferToLbl.isHidden = false
            selectPreferToLbl.textColor = .lightGray
        }else {
            preferToViewHeight.constant = CGFloat(preferToListView.rows * 25) + 25
            selectPreferToLbl.isHidden = true
        }
        
        print("bestViewHeight.constant >> \(bestDescribesViewHeight.constant)")
        
        preferToid.removeAll()
        for itm in data {
            preferToid.append(itm)
        }
        
        if preferToListView.rows == 0 {
            preferToTopSpaceLayout.constant = 5
            preferToBottomSpaceLayout.constant = 5
        }else if preferToListView.rows == 1 {
            preferToTopSpaceLayout.constant = 25
            preferToBottomSpaceLayout.constant = 5
        }else if preferToListView.rows == 2 {
            preferToTopSpaceLayout.constant = 16
            preferToBottomSpaceLayout.constant = 5
        }else if preferToListView.rows == 3 {
            preferToTopSpaceLayout.constant = 10
            preferToBottomSpaceLayout.constant = 5
        }else if preferToListView.rows == 4 {
            preferToTopSpaceLayout.constant = 10
            preferToBottomSpaceLayout.constant = 17
        }else {
            preferToTopSpaceLayout.constant = 8
            preferToBottomSpaceLayout.constant = 20
        }
        
    }

    func onOkCallBack(_ okBtn: Bool) -> () {
        if UIDevice.current.userInterfaceIdiom == .pad {
            let settingsActionSheet: UIAlertController = UIAlertController(title:nil, message:nil, preferredStyle: .alert)
            
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

            present(settingsActionSheet, animated:true, completion:nil)
            
        }else {
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
                            self.attachedImg = true
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
                        }
                    } else {
                        let executionTimeWithSuccessVC1 = Date().timeIntervalSince(startDate)
                        print("executionTimeWithSuccessVC1 \(executionTimeWithSuccessVC1 * 1000) second")

                        DispatchQueue.main.async {
                            self.ProcessingLbl.text = "Not Matched"
                            self.ProcessingLbl.textColor = .green
                            self.attachedImg = true
                        }

                        let executionTimeWithSuccessVC2 = Date().timeIntervalSince(startDate)
                        print("executionTimeWithSuccessVC2 \(executionTimeWithSuccessVC2 * 1000) second")

                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self.ProcessingLbl.isHidden = true
                            self.ProcessingLbl.text = "Processing...".localizedString
                            self.ProcessingLbl.textColor = .blue
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
                    
                    let executionTimeWithSuccessVC3 = Date().timeIntervalSince(startDate)
                    print("executionTimeWithSuccessVC3 \(executionTimeWithSuccessVC3 * 1000) second")

                }
                return
            }
        }

//        faceRecognitionVM.compare(withImage1: imageOne, AndImage2: imageTwo) { error, data in
//
//            if error != nil {
//                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                    self.ProcessingLbl.text = "Failed".localizedString
//                    self.ProcessingLbl.textColor = .red
//
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                        self.showFailAlert()
//                    }
//                }
//                return
//            }
//
//            guard let data = data else {return}
//            print(data)
//
//            self.imgTake = 0
//            print(self.imgTake)
//
//            if data == "Matched" {
//                DispatchQueue.main.async {
//                    self.ProcessingLbl.text = "Matched"
//                    self.ProcessingLbl.textColor = .green
//                    self.attachedImg = true
//                }
//
//                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                    self.ProcessingLbl.isHidden = true
//                    self.ProcessingLbl.text = "Processing...".localizedString
//                    self.ProcessingLbl.textColor = .blue
//                }
//
//                DispatchQueue.main.async {
//                    self.profileImg.image = imageOne
//                }
//            } else {
//                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                    self.ProcessingLbl.text = data
//                    self.ProcessingLbl.textColor = .red
//                    self.attachedImg = false
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                        //                        self.showFailAlert()
//                        self.ProcessingLbl.isHidden = true
//                        self.ProcessingLbl.text = "Processing...".localizedString
//                        self.ProcessingLbl.textColor = .blue
//                    }
//                }
//            }
//        }
    }
    
    func onVerifyCallBack(_ okBtn: Bool) -> () {
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
    
    func logout() {
        logoutAlertView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        logoutAlertView?.titleLbl.text = "Confirm?".localizedString
        logoutAlertView?.detailsLbl.text = "Are you sure you want to logout?".localizedString
        
        logoutAlertView?.HandleConfirmBtn = {
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
        //        guard let popupVC = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "FacialRecognitionPopUpView") as? FacialRecognitionPopUpView else {return}
        //        popupVC.modalPresentationStyle = .overCurrentContext
        //        popupVC.modalTransitionStyle = .crossDissolve
        //        let pVC = popupVC.popoverPresentationController
        //        pVC?.permittedArrowDirections = .any
        //        pVC?.delegate = self
        //        pVC?.sourceRect = CGRect(x: 100, y: 100, width: 1, height: 1)
        //        popupVC.onOkCallBackResponse = self.onOkCallBack
        //        present(popupVC, animated: true, completion: nil)
        
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            let settingsActionSheet: UIAlertController = UIAlertController(title:nil, message:nil, preferredStyle: .alert)
            
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
            
            present(settingsActionSheet, animated:true, completion:nil)
            
        }else {
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

    func showDatePicker(){
        //Formate Date
        datePicker.datePickerMode = .date
//        datePicker.calendar = .Component
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
        
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        
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
        if internetConect {
            guard let vc = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "IamVC") as? IamVC else {return}
            vc.arrSelectedDataIds = iamid
            vc.arrSelectedDataNames = iamNames
            vc.onIamCallBackResponse = self.OnIamCallBack
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    @IBAction func preferToBtn(_ sender: Any) {
        if internetConect {
            guard let vc = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "PreferToVC") as? PreferToVC else {return}
            vc.arrSelectedDataIds = preferToid
            vc.arrSelectedDataNames = preferToNames
            vc.onPreferToCallBackResponse = self.OnPreferToCallBack
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func saveBtn(_ sender: Any) {
        print(imgTake)
        if imgTake == 0 {
            if self.attachedImg == false {
                DispatchQueue.main.async {
                    self.view.makeToast("Please add a profile image".localizedString)
                }
                return
            }
            else {
                if tagsid.isEmpty {
                    DispatchQueue.main.async {
                        self.view.makeToast("Please select what you enjoy doing".localizedString)
                    }
                    return
                }else if iamid.isEmpty {
                    DispatchQueue.main.async {
                        self.view.makeToast("Please select what best describes you".localizedString)
                    }
                    return
                }else if preferToid.isEmpty {
                    DispatchQueue.main.async {
                        self.view.makeToast("Please select what you prefer to do".localizedString)
                    }
                    return
                }
                else {
                    if internetConect {
                        self.saveBtn.setTitle("Saving...", for: .normal)
                        self.saveBtn.isUserInteractionEnabled = false
                        
                        viewmodel.editProfile(withUserName: nameTxt.text!, AndGender: genderString, AndGeneratedUserName: nameTxt.text!, AndBio: bioTxtView.text!, AndBirthdate: dateBirthdayTxt.text!, OtherGenderName: otherGenderTxt.text!, tagsId: tagsid, attachedImg: self.attachedImg, AndUserImage: self.profileImg.image ?? UIImage(),WhatBestDescrips:iamid, preferto: preferToid) { error, data in
                            
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
                                    if FirstLoginApp.isFirst == 0 {//toprofile
//                                        NotificationCenter.default.post(name: Notification.Name("updateMyProfile"), object: nil, userInfo: nil)
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                            self.onPopup()
                                        }
                                    }else if FirstLoginApp.isFirst == 1 {//tofeed if socail media login
                                        Router().toFeed()
                                    }else {//to login
                                        Router().toOptionsSignUpVC()
                                    }
                                }
                            }
                        }
                    }
                }
            }

        }
        else {
            self.view.makeToast("Please wait a moment while the image comparison process is completed")
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
            imgTake = 1
            print(imgTake)
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
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
        
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
      
//        let originImg = image.fixOrientation()
//        self.profileImg.image = image
//        self.imgTake = 0
//        self.attachedImg = true
                
//        let cropper = CropperViewController(originalImage: originImg)
//         let cropper = CustomCropperViewController(originalImage: originImg)
//        cropper.delegate = self
//
//        self.navigationController?.pushViewController(cropper, animated: true)
//
//        picker.dismiss(animated: true) {
////            self.present(cropper, animated: true, completion: nil)
////            setupNavBar()
////            hideNavigationBar(NavigationBar: false, BackButton: false)
//        }
        
        
        if imgTake == 1 {
            let image1 = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            picker.dismiss(animated:true, completion: {
                
                self.faceImgOne = image1
                self.imgTake = 2
                print(self.imgTake)
                
                guard let popupVC = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "FacialRecognitionPopUpView2") as? FacialRecognitionPopUpView2 else {return}
                popupVC.modalPresentationStyle = .overCurrentContext
                popupVC.modalTransitionStyle = .crossDissolve
                let pVC = popupVC.popoverPresentationController
                pVC?.permittedArrowDirections = .any
                pVC?.delegate = self
                pVC?.sourceRect = CGRect(x: 100, y: 100, width: 1, height: 1)
                popupVC.faceImgOne = self.faceImgOne
                popupVC.onVerifyCallBackResponse = self.onVerifyCallBack
                self.present(popupVC, animated: true, completion: nil)
            })
        }else if self.imgTake == 2 {
            let image2 = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            picker.dismiss(animated:true, completion: {
                self.attachedImg = true
                self.faceImgTwo = image2.fixOrientation()
                

                self.FacialRecognitionAPI(imageOne: self.faceImgOne, imageTwo: self.faceImgTwo)
            })
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imgTake = 0
        print(imgTake)
        self.attachedImg = false
        self.tabBarController?.tabBar.isHidden = false
        picker.dismiss(animated:true, completion: nil)
    }
}

extension EditMyProfileVC: CropperViewControllerDelegate {
    
    func aspectRatioPickerDidSelectedAspectRatio(_ aspectRatio: AspectRatio) {
        print("\(String(describing: aspectRatio.dictionary))")
    }
    
    func cropperDidConfirm(_ cropper: CropperViewController, state: CropperState?) {
        cropper.onPopup()
        if let state = state,
            let image = cropper.originalImage.cropped(withCropperState: state) {
            profileImg.image = image
            self.attachedImg = true
            
            imgTake = 0
            print(cropper.isCurrentlyInInitialState)
            print(image)
        }
    }
    
    func cropperDidCancel(_ cropper: CropperViewController) {
        cropper.onPopup()
    }
}
//(20.0, 274.0, 388.0, 291.0)
//text view delegate
extension EditMyProfileVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeHolderLbl.isHidden = !bioTxtView.text.isEmpty
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            let newText = (bioTxtView.text as NSString).replacingCharacters(in: range, with: text)
        return newText.count < 300
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
        imageName = "back_icon"
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

//extension EditMyProfileVC {
//    //MARK: - AWS Methods
//    func sendImageToRekognition(celebImageData: Data){
//
//        //Delete older labels or buttons
//        DispatchQueue.main.async {
//            [weak self] in
//            for subView in (self?.profileImg.subviews)! {
//                subView.removeFromSuperview()
//            }
//        }
//
//        rekognitionObject = AWSRekognition.default()
//        let celebImageAWS = AWSRekognitionImage()
//        celebImageAWS?.bytes = celebImageData
//        let celebRequest = AWSRekognitionRecognizeCelebritiesRequest()
//        celebRequest?.image = celebImageAWS
//
//        rekognitionObject?.recognizeCelebrities(celebRequest!){
//            (result, error) in
//            if error != nil{
//                print(error!)
//                return
//            }
//
//            //1. First we check if there are any celebrities in the response
//            if ((result!.celebrityFaces?.count)! > 0){
//
//                //2. Celebrities were found. Lets iterate through all of them
//                for (index, celebFace) in result!.celebrityFaces!.enumerated(){
//
//                    //Check the confidence value returned by the API for each celebirty identified
//                    if(celebFace.matchConfidence!.intValue > 50){ //Adjust the confidence value to whatever you are comfortable with
//
//                        //We are confident this is celebrity. Lets point them out in the image using the main thread
//                        DispatchQueue.main.async {
//                            [weak self] in
//
//                            //Create an instance of Celebrity. This class is availabe with the starter application you downloaded
//                            let celebrityInImage = Celebrity()
//
//                            celebrityInImage.scene = (self?.profileImg)!
//
//                            //Get the coordinates for where this celebrity face is in the image and pass them to the Celebrity instance
//                            celebrityInImage.boundingBox = ["height":celebFace.face?.boundingBox?.height, "left":celebFace.face?.boundingBox?.left, "top":celebFace.face?.boundingBox?.top, "width":celebFace.face?.boundingBox?.width] as? [String : CGFloat]
//
//                            //Get the celebrity name and pass it along
//                            celebrityInImage.name = celebFace.name!
//                            //Get the first url returned by the API for this celebrity. This is going to be an IMDb profile link
//                            if (celebFace.urls!.count > 0){
//                                celebrityInImage.infoLink = celebFace.urls![0]
//                            }
//                            //If there are no links direct them to IMDB search page
//                            else{
//                                celebrityInImage.infoLink = "https://www.imdb.com/search/name-text?bio="+celebrityInImage.name
//                            }
//                            //Update the celebrity links map that we will use next to create buttons
//                            self?.infoLinksMap[index] = "https://"+celebFace.urls![0]
//
//                            //Create a button that will take users to the IMDb link when tapped
//                            let infoButton:UIButton = celebrityInImage.createInfoButton()
//                            infoButton.tag = index
//                            infoButton.addTarget(self, action: #selector(self?.handleTap), for: .touchUpInside)
//                            self?.profileImg.addSubview(infoButton)
//                        }
//                    }
//                }
//            }
//            //If there were no celebrities in the image, lets check if there were any faces (who, granted, could one day become celebrities)
//            else if ((result!.unrecognizedFaces?.count)! > 0){
//                //Faces are present. Point them out in the Image (left as an exercise for the reader)
//                /**/
//            }
//            else{
//                //No faces were found (presumably no people were found either)
//                print("No faces in this pic")
//            }
//        }
//
//    }
//
//    @objc func handleTap(sender:UIButton){
//        print("tap recognized")
//        let celebURL = URL(string: self.infoLinksMap[sender.tag]!)
//        let safariController = SFSafariViewController(url: celebURL!)
//        safariController.delegate = self
//        self.present(safariController, animated:true)
//    }
//}
