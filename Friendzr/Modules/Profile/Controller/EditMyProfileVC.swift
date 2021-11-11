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
import InstagramLogin


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
    @IBOutlet weak var selectTagsLbl: UILabel!
    @IBOutlet weak var hideView: UIView!
    
    
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
                hideView.isHidden = true
                setupDate()
            }
        }
        
        // Set View Model Event Listener
        profileVM.error.bind { [unowned self]error in
            DispatchQueue.main.async {
                self.hideLoading()
                if error == "Internal Server Error" {
                    HandleInternetConnection()
                }
                //                else if error == "Unauthorized" {
                //                    Router().toOptionsSignUpVC()
                //                }
                else {
                    self.showAlert(withMessage: error)
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
        
        if model?.birthdate == "" {
            dateBirthLbl.text = "Select your birthdate"
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
            tagsListView.addTag(itm.tagname)
            tagsid.append(itm.tagID)
        }
        
        if tagsListView.rows == 0 {
            tagsViewHeight.constant = 45
            selectTagsLbl.isHidden = false
            selectTagsLbl.textColor = .lightGray
        }else {
            tagsViewHeight.constant = CGFloat(tagsListView.rows * 30) + 10
            selectTagsLbl.isHidden = true
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
        
        selectTagsLbl.isHidden = true
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
        //
        //        guard let vc = UIViewController.viewController(withStoryboard: .FaceRecognition, AndContollerID: "FaceRecognitionVC") as? FaceRecognitionVC else {return}
        //        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func dateBtn(_ sender: Any) {
        alertView?.frame = CGRect(x: 0, y: -100, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        alertView?.HandleOKBtn = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            self.dateBirthLbl.text = formatter.string(from: (self.alertView?.calendarView.date)!)
            self.birthDay = formatter.string(from: (self.alertView?.calendarView.date)!)
            self.dateBirthLbl.textColor = .black
            
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
        updateUserInterface2()
        if internetConect {
            guard let vc = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "TagsVC") as? TagsVC else {return}
            vc.onInterestsCallBackResponse = self.OnInterestsCallBack
            self.navigationController?.pushViewController(vc, animated: true)
        }else {
            return
        }
    }
    
    var instagramLogin: InstagramLoginViewController!
    var clientId:String = "284152480286634"
    var redirectUri:String = "https://friendzr.com/"
    
    @IBAction func integrationInstgramBtn(_ sender: Any) {
        instagramLogin = InstagramLoginViewController(clientId: clientId, redirectUri: redirectUri)
        instagramLogin.delegate = self
        instagramLogin.scopes = [.all]
        present(UINavigationController(rootViewController: instagramLogin), animated: true)
    }
    
    
    @objc func dismissLoginViewController() {
        instagramLogin.dismiss(animated: true)
    }

    @objc func refreshPage() {
        instagramLogin.reloadPage()
    }
    
    @IBAction func integrationSnapchatBtn(_ sender: Any) {
        //        SCSDKLoginClient.login(from: self, completion: { success, error in
        //
        //            if let error = error {
        //                print(error.localizedDescription)
        //                return
        //            }
        //
        //            if success {
        //                self.fetchSnapUserInfo() //used in the demo app to get user info
        //            }
        //        })
    }
    
    //    private func fetchSnapUserInfo(){
    //        let graphQLQuery = "{me{displayName, bitmoji{avatar}}}"
    //
    //        SCSDKLoginClient
    //            .fetchUserData(
    //                withQuery: graphQLQuery,
    //                variables: nil,
    //                success: { userInfo in
    //
    //                    if let userInfo = userInfo,
    //                       let data = try? JSONSerialization.data(withJSONObject: userInfo, options: .prettyPrinted),
    //                       let userEntity = try? JSONDecoder().decode(UserEntity.self, from: data) {
    //
    //                        DispatchQueue.main.async {
    //                            self.goToLoginConfirm(userEntity)
    //                        }
    //                    }
    //                }) { (error, isUserLoggedOut) in
    //                    print(error?.localizedDescription ?? "")
    //                }
    //    }
    
    @IBAction func integrationFacebookBtn(_ sender: Any) {
        updateUserInterface2()
        if internetConect {
            let fbLoginManager : LoginManager = LoginManager()
            
            fbLoginManager.logIn(permissions: ["email"], from: self) { (result, error) -> Void in
                
                if (error == nil) {
                    // if user cancel the login
                    if error != nil {
                    }else if (result?.isCancelled)!{
                        return
                    }else {
                        self.getFBUserData()
                    }
                }
            }
        }
    }

    @IBAction func integrationTiktokBtn(_ sender: Any) {
//        TikTokOpenSDKApplicationDelegate.sharedInstance().logDelegate = self
//
//        let scopes = ["user.info.basic","video.list"] // list your scopes
//        let scopesSet = NSOrderedSet(array:scopes)
//        let request = TikTokOpenSDKAuthRequest()
//        request.permissions = scopesSet
//
//        request.send(self, completion: { resp -> Void in
//            /* STEP 3 */
//
//            if resp.errCode.rawValue == 0 {
//                /* STEP 3.a */
//                let clientKey = "awq4czdodvu3iy4y" // you will receive this once you register in the Developer Portal
//                let clientSecretKey = "64eabf5c9ae2cc2c5b15ea4897227bb3"
//                let responseCode = resp.code ?? ""
//
//                // replace this baseURLstring with your own wrapper API
//                let baseURlString = "https://open-api.tiktok.com/oauth/access_token/?client_key=\(clientKey)&client_secret=\(clientSecretKey)&grant_type=authorization_code&code=\(responseCode)"
//
//                //                let baseURlString = "https://open-api.tiktok.com/demoapp/callback/?code=\(responseCode)&client_key=\(clientKey)"
//
//                let url = NSURL(string: baseURlString)
//
//                /* STEP 3.b */
//                let session = URLSession(configuration: .default)
//                let urlRequest = NSMutableURLRequest(url: url! as URL)
//                let task = session.dataTask(with: urlRequest as URLRequest) { (data, response, error) -> Void in
//                    /* STEP 3.c */
//                    //                print(response)
//                    //                print(data)
//                }
//                task.resume()
//            } else {
//                // handle error
//            }
//        })
    }
    
    @IBAction func saveBtn(_ sender: Any) {
        //        updateUserInterface()
        
        updateUserInterface2()
        if self.attachedImg == false {
            self.showAlert(withMessage: "Please add profile image")
            return
        }else {
            if internetConect {
                self.showLoading()
                viewmodel.editProfile(withUserName: nameTxt.text!, AndGender: genderString, AndGeneratedUserName: nameTxt.text!, AndBio: bioTxtView.text!, AndBirthdate: dateBirthLbl.text!, tagsId: tagsid, attachedImg: self.attachedImg, AndUserImage: self.profileImg.image ?? UIImage()) { error, data in
                    
                    self.hideLoading()
                    if let error = error {
                        self.showAlert(withMessage: error)
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
            }else {
                return
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
            
            self.profileImg.image = image
            self.attachedImg = true
        })
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated:true, completion: nil)
    }
}

//text view delegate
extension EditMyProfileVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeHolderLbl.isHidden = !textView.text.isEmpty
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (bioTxtView.text as NSString).replacingCharacters(in: range, with: text)
        return newText.count < 150
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

//tiktok integration
//extension EditMyProfileVC : TikTokOpenSDKLogDelegate {
//
//    func onLog(_ logInfo: String) {
//        print(logInfo)
//    }
//
//}

//facebook integration
extension EditMyProfileVC {
    func getFBUserData(completion:@escaping (_ : [String: Any]?,_ : Error?) -> Void) {
        
        GraphRequest(graphPath: "me", parameters: ["fields": "id,user_name,name, first_name, last_name, picture.type(large), email, phone"]).start { (connection, response, error)  in
            
            if error != nil {
                //                print(error?.localizedDescription ?? "")
                completion(nil, error)
                return
            }
            completion(response as? [String : Any], nil)
        }
    }
    
    func getFBUserData(){
        if((AccessToken.current) != nil){
            
            let request = GraphRequest(graphPath: "/me", parameters: ["fields": "id,user_name, picture.type(large), name,email"], httpMethod: HTTPMethod(rawValue: "GET"))
            request.start { (connection, result, error) in
                
                if let error = error {
                    print("\(error.localizedDescription)")
                } else{
                    let userInfo = result as! [String : AnyObject]
                    
                    self.UserFBID = userInfo["id"] as! String
                    self.UserFBMobile = userInfo["phone"] as? String ?? ""
                    self.UserFBUserName = userInfo["name"] as? String ?? ""
                    self.UserFBEmail = userInfo["email"] as? String ?? ""
                    self.userFace_BookAccessToken = AccessToken.current!.tokenString
                    let img = userInfo["picture"] as! [String:AnyObject]
                    //                    self.UserFBImage = img["data"]!["url"] as? String ?? ""
                    if let imgurL = img["data"] as? [String:AnyObject] {
                        self.UserFBImage = imgurL["url"] as? String ?? ""
                    }
                    
                    print("\(self.UserFBID),\(self.UserFBUserName),\(self.UserFBEmail)")
                    
                    self.facebookLink = "https://www.facebook.com/\(self.UserFBID)"
                }
            }
        }
    }
}

// MARK: - InstagramLoginViewControllerDelegate

extension EditMyProfileVC: InstagramLoginViewControllerDelegate {

    func instagramLoginDidFinish(accessToken: String?, error: InstagramError?) {
        dismissLoginViewController()
        
        if accessToken != nil {
            self.showAlert(withMessage:  "Successfully logged in! 👍")
        } else {
            self.showAlert(withMessage: "\(error!.localizedDescription) 👎")
        }
    }
}
