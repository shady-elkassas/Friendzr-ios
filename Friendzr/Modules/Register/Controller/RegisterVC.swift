//
//  RegisterVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 11/08/2021.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn
import AuthenticationServices
import Network

class RegisterVC: UIViewController {
    
    //MARK:- Outlets
    @IBOutlet weak var userNameView: UIView!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var confirmPasswordView: UIView!
    @IBOutlet weak var userNameTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var confirmPasswordTxt: UITextField!
    @IBOutlet weak var facebookView: UIView!
    @IBOutlet weak var googleView: UIView!
    @IBOutlet weak var appleView: UIView!
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var showConfirmPasswordBtn: UIButton!
    @IBOutlet weak var showPasswordBtn: UIButton!
    @IBOutlet weak var termsLbl: UILabel!
    @IBOutlet weak var registerBtnView: GradientView2!
    
    //MARK: - Properties
    lazy var alertView = Bundle.main.loadNibNamed("BlockAlertView", owner: self, options: nil)?.first as? BlockAlertView
    
    var checkUserNameVM:CheckUserNameViewModel = CheckUserNameViewModel()
    var registerVM:RegisterViewModel = RegisterViewModel()
    let socialMediaVM: SocialMediaLoginViewModel = SocialMediaLoginViewModel()
    
    let signInConfig = GIDConfiguration.init(clientID: "43837105804-he5jci75mbf7jrhush4cps45plripdvp.apps.googleusercontent.com")
    var UserFBID = ""
    var UserFBMobile = ""
    var UserFBEmail = ""
    var UserFBFirstName = ""
    var UserFBLastName = ""
    var userFace_BookAccessToken = ""
    var UserFBUserName = ""
    var UserFBImage = ""
    
    var UserG_mailID = ""
    var UserG_mailEmail = ""
    var UserG_mailFirstName = ""
    var UserG_mailLastName = ""
    var userG_mailAccessToken = ""
    var UserG_userName = ""
    var socialMediaImge = ""
    
    var myString:String = "By clicking ‘Sign up’, you agree to our terms of usage see more".localizedString
    var myMutableString = NSMutableAttributedString()
    
    var allValidatConfigVM:AllValidatConfigViewModel = AllValidatConfigViewModel()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initBackButton()
        setup()
        clearNavigationBar()
        removeNavigationBorder()
        userNameTxt.addTarget(self, action: #selector(handleCheckUserName), for: .allEvents)
        
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: nil
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Defaults.availableVC = "RegisterVC"
        print("availableVC >> \(Defaults.availableVC)")
        
        hideNavigationBar(NavigationBar: false, BackButton: false)
        CancelRequest.currentTask = false
        
        DispatchQueue.main.async {
            self.updateUserInterface()
        }
        
        NotificationCenter.default.post(name: Notification.Name("registrationFCM"), object: nil, userInfo: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.hideLoading()
        CancelRequest.currentTask = true
    }
    
    func getAllValidatConfig() {
        allValidatConfigVM.getAllValidatConfig()
        allValidatConfigVM.userValidationConfig.bind { [unowned self]value in
            DispatchQueue.main.async {
                Defaults.initValidationConfig(validate: value)
            }
        }
        
        // Set View Model Event Listener
        allValidatConfigVM.errorMsg.bind { [unowned self]error in
            DispatchQueue.main.async {
                print(error)
            }
        }
    }
    
    func registerUser() {
        self.showLoading()
        registerVM.RegisterNewUser(withUserName: userNameTxt.text!, AndEmail: emailTxt.text!, password: passwordTxt.text!,confirmPassword:confirmPasswordTxt.text!) { error, data in
            self.hideLoading()
            if let error = error {
                DispatchQueue.main.async {
                    self.view.makeToast(error)
                }
                return
            }
            
            guard let _ = data else {return}
            
            DispatchQueue.main.async {
                //                self.view.makeToast("Please check your email".localizedString)
                self.showVerificationEmailAlert()
                
            }
        }
    }
    
    func showVerificationEmailAlert() {
        alertView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        alertView?.titleLbl.text = "Confirm?".localizedString
        alertView?.detailsLbl.text = "Your verification email should arrive straight away. Can’t see it? Check your Junk folder and add hello@friendzr.com to your safe senders’ list.".localizedString
        alertView?.unConfirmBtn.isHidden = true
        
        alertView?.HandleConfirmBtn = {
            DispatchQueue.main.async {
                Router().toLogin()
            }
            
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
    
    func socialMediaLoginUser( _ socialMediaId:String, _ email:String) {
        self.showLoading()
        self.socialMediaVM.socialMediaLoginUser(withSocialMediaId: socialMediaId, AndEmail: email) { (error, data) in
            self.hideLoading()
            if let error = error {
                DispatchQueue.main.async {
                    self.view.makeToast(error)
                }
                return
            }
            
            guard let data = data else {return}
            Defaults.token = data.token
            Defaults.initUser(user: data)
            
            DispatchQueue.main.async {
                if Defaults.needUpdate == 1 {
                    Defaults.isFirstLogin = true
                    Router().toSplachOne()
                }else {
                    Defaults.isFirstLogin = false
                    Router().toFeed()
                }
            }
        }
    }
    
    @objc func handleCheckUserName() {
        checkUserNameVM.checkUserName(withUserName: userNameTxt.text!) { error, data in
            
            if let error = error {
                self.view.makeToast(error)
                return
            }
            
            guard let _ = data else {return}
        }
    }
    
    //MARK: - Actions
    
    
    @IBAction func registerBtn(_ sender: Any) {
        hideKeyboard()
        if NetworkConected.internetConect {
            registerUser()
        }else {
            return
        }
    }
    
    @IBAction func termsBtn(_ sender: Any) {
        guard let vc = UIViewController.viewController(withStoryboard: .More, AndContollerID: "TermsAndConditionsVC") as? TermsAndConditionsVC else {return}
        vc.titleVC = "Terms & Conditions".localizedString
        vc.urlString = "https://friendzr.com/wp-content/uploads/2021/10/EULAOct2021.pdf"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func showPasswordBtn(_ sender: Any) {
        passwordTxt.isSecureTextEntry = !passwordTxt.isSecureTextEntry
        self.showPasswordBtn.isSelected = !self.showPasswordBtn.isSelected
    }
    
    @IBAction func showConfirmPasswordBtn(_ sender: Any) {
        confirmPasswordTxt.isSecureTextEntry = !confirmPasswordTxt.isSecureTextEntry
        self.showConfirmPasswordBtn.isSelected = !self.showConfirmPasswordBtn.isSelected
    }
    
    @IBAction func facebookBtn(_ sender: Any) {
        if NetworkConected.internetConect {
            if let token = AccessToken.current,
               !token.isExpired {
                // User is logged in, do work such as go to next view controller.
                getFBUserData()
            }
            else {
                let fbLoginManager : LoginManager = LoginManager()
                
                fbLoginManager.logIn(permissions: ["email"], from: self) { (result, error) -> Void in
                    
                    if (error == nil) {
                        //                let fbloginresult : LoginManagerLoginResult = result!
                        // if user cancel the login
                        if error != nil {
                            //                        print("Process error")
                        }else if (result?.isCancelled)!{
                            return
                        }else {
                            self.getFBUserData()
                        }
                    }
                }
            }
        }else {
            return
        }
        
    }
    
    @IBAction func googleBtn(_ sender: Any) {
        if NetworkConected.internetConect {
            GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: self) { user, error in
                guard error == nil else { return }
                // If sign in succeeded, display the app's main content View.
                
                if let error = error {
                    print("\(error.localizedDescription)")
                } else {
                    // Perform any operations on signed in user here.
                    if let user = user {
                        self.UserG_mailID = user.userID ?? ""      // For client-side use only!
                        self.UserG_mailFirstName = user.profile?.givenName ?? ""
                        self.UserG_mailLastName = (user.profile?.familyName) ?? ""
                        self.UserG_mailEmail = user.profile?.email ?? ""
                        self.userG_mailAccessToken = user.authentication.idToken ?? ""
                        self.UserG_userName = self.UserG_mailFirstName + " " + self.UserG_mailLastName
                        //            user.profile = user.profile.hasImage
                        //                    let img = user.profile?.imageURL(withDimension: 200)?.absoluteString
                        
                        print("\(self.UserG_mailID),\(self.UserG_mailEmail),\(self.UserG_userName)")
                        self.socialMediaLoginUser(self.UserG_mailID, self.UserG_mailEmail)
                    }
                    
                }
            }
        }else {
            return
        }
        
    }
    
    @IBAction func appleBtn(_ sender: Any) {
        if NetworkConected.internetConect {
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()
            
        }else {
            return
        }
    }
    
    //MARK: - Helper
    func setup() {
        userNameView.setBorder(color: UIColor.color("#DDDFDD")?.cgColor, width: 1)
        emailView.setBorder(color: UIColor.color("#DDDFDD")?.cgColor, width: 1)
        passwordView.setBorder(color: UIColor.color("#DDDFDD")?.cgColor, width: 1)
        confirmPasswordView.setBorder(color: UIColor.color("#DDDFDD")?.cgColor, width: 1)
        
        userNameView.cornerRadiusView(radius: 6)
        emailView.cornerRadiusView(radius: 6)
        passwordView.cornerRadiusView(radius: 6)
        confirmPasswordView.cornerRadiusView(radius: 6)
        
        facebookView.cornerRadiusView(radius: 6)
        googleView.cornerRadiusView(radius: 6)
        appleView.cornerRadiusView(radius: 6)
        googleView.setBorder()
        registerBtn.cornerRadiusView(radius: 8)
        registerBtnView.cornerRadiusView(radius: 8)
        
        myMutableString = NSMutableAttributedString(string: myString, attributes: [NSAttributedString.Key.font:UIFont(name: "Montserrat-Regular", size: 12.0)!])
        myMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.FriendzrColors.primary!, range: NSRange(location:55,length:8))
        // set label Attribute
        termsLbl.attributedText = myMutableString
    }
    
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
            }
        case .wifi:
            DispatchQueue.main.async {
                NetworkConected.internetConect = true
            }
        }
        
        print("Reachability Summary")
        print("Status:", Network.reachability.status)
        print("HostName:", Network.reachability.hostname ?? "nil")
        print("Reachable:", Network.reachability.isReachable)
        print("Wifi:", Network.reachability.isReachableViaWiFi)
    }
    
    func HandleInternetConnection() {
        self.view.makeToast("Network is unavailable, please try again!".localizedString)
    }
}

extension RegisterVC {
    func getFBUserData(completion:@escaping (_ : [String: Any]?,_ : Error?) -> Void) {
        
        GraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email, phone"]).start { (connection, response, error)  in
            
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
            
            let request = GraphRequest(graphPath: "/me", parameters: ["fields": "id, picture.type(large), name,email"], httpMethod: HTTPMethod(rawValue: "GET"))
            request.start { (connection, result, error) in
                
                
                if let error = error {
                    print("\(error.localizedDescription)")
                } else{
                    let userInfo = result as! [String : AnyObject]
                    
                    self.UserFBID = userInfo["id"] as? String ?? ""
                    self.UserFBMobile = userInfo["phone"] as? String ?? ""
                    self.UserFBUserName = userInfo["name"] as? String ?? ""
                    self.UserFBEmail = userInfo["email"] as? String ?? ""
                    self.userFace_BookAccessToken = AccessToken.current?.tokenString ?? ""
                    //                    let img = userInfo["picture"] as! [String:AnyObject]
                    //                    self.UserFBImage = img["data"]!["url"] as? String ?? ""
                    //                    if let imgurL = img["data"] as? [String:AnyObject] {
                    //                        self.UserFBImage = imgurL["url"] as? String ?? ""
                    //                    }
                    
                    print("\(self.UserFBID),\(self.UserFBUserName),\(self.UserFBEmail)")
                    self.socialMediaLoginUser(self.UserFBID, self.UserFBEmail)
                }
            }
        }
    }
}

@available(iOS 13.0, *)
extension RegisterVC: ASAuthorizationControllerDelegate {
    /// - Tag: did_complete_authorization
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            
            // Create an account in your system.
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            
            // For the purpose of this demo app, store the `userIdentifier` in the keychain.
            self.saveUserInKeychain(userIdentifier)
            if fullName?.givenName == nil || email == nil && userIdentifier != "" {
                let appleIDProvider = ASAuthorizationAppleIDProvider()
                appleIDProvider.getCredentialState(forUserID: userIdentifier) {  (credentialState, error) in
                    switch credentialState {
                    case .authorized:
                        print("The Apple ID credential is valid.")
                        break
                    case .revoked:
                        print("The Apple ID credential is revoked.")
                        break
                    case .notFound:
                        print(" No credential was found, so show the sign-in UI.")
                    default:
                        break
                    }
                }
            }
            // For the purpose of this demo app, show the Apple ID credential information in the `ResultViewController`.
            self.showResultViewController(userIdentifier: userIdentifier, fullName: fullName, email: email)
            
        case let passwordCredential as ASPasswordCredential:
            
            // Sign in using an existing iCloud Keychain credential.
            let username = passwordCredential.user
            let password = passwordCredential.password
            
            // For the purpose of this demo app, show the password credential as an alert.
            DispatchQueue.main.async {
                self.showPasswordCredentialAlert(username: username, password: password)
            }
            
        default:
            break
        }
    }
    
    private func saveUserInKeychain(_ userIdentifier: String) {
        do {
            try KeychainItem(service: "com.FriendzSocialMediaLimited.Friendzr-ios", account: "userIdentifier").saveItem(userIdentifier)
        } catch {
            //            print("Unable to save userIdentifier to keychain.")
        }
    }
    
    private func showResultViewController(userIdentifier: String, fullName: PersonNameComponents?, email: String?) {
        
        var usernameApple = "Apple User"
        var useremailApple = userIdentifier
        
        
        DispatchQueue.main.async {
            if let givenName = fullName?.givenName {
                usernameApple = givenName
            }
            
            if let email = email {
                useremailApple = email
            }
            
            self.socialMediaLoginUser(userIdentifier, useremailApple)
        }
    }
    
    private func showPasswordCredentialAlert(username: String, password: String) {
        let message = "The app has received your selected credential from the keychain. \n\n Username: \(username)\n Password: \(password)"
        let alertController = UIAlertController(title: "Keychain Credential Received",
                                                message: message,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    /// - Tag: did_complete_error
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        //        self.showAlert(withMessage: error.localizedDescription)
    }
}

@available(iOS 13.0, *)
extension RegisterVC: ASAuthorizationControllerPresentationContextProviding {
    /// - Tag: provide_presentation_anchor
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
