//
//  LoginVC.swift
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
import Firebase
import FirebaseAnalytics


class LoginVC: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var facebookView: UIView!
    @IBOutlet weak var googleView: UIView!
    @IBOutlet weak var appleView: UIView!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var showPasswordBtn: UIButton!
    @IBOutlet weak var loginBtnView: GradientView2!
    
    //MARK: - Properties
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
    
    let socialMediaVM: SocialMediaLoginViewModel = SocialMediaLoginViewModel()
    var loginVM:LoginViewModel = LoginViewModel()
    var allValidatConfigVM:AllValidatConfigViewModel = AllValidatConfigViewModel()

    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        clearNavigationBar()
        removeNavigationBorder()
        
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: nil
        )
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Defaults.availableVC = "LoginVC"
        print("availableVC >> \(Defaults.availableVC)")
        
        hideNavigationBar(NavigationBar: false, BackButton: false)
        CancelRequest.currentTask = false
        
        DispatchQueue.main.async {
            self.updateUserInterface()
        }
        
        NotificationCenter.default.post(name: Notification.Name("registrationFCM"), object: nil, userInfo: nil)
                
        recordScreenView()
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [AnalyticsParameterItemID : "id-\(Defaults.availableVC)",AnalyticsParameterItemName: Defaults.availableVC, AnalyticsParameterContentType: "cont"])
        
        if Defaults.isDeeplinkDirectionalLogin {
            initBackToFeedButton()
            Defaults.isDeeplinkDirectionalLogin = false
        }else{
            initBackButton()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.hideLoading()
        CancelRequest.currentTask = true
    }
    
    func recordScreenView() {
        // These strings must be <= 36 characters long in order for setScreenName:screenClass: to succeed.
        
        let screenName = Defaults.availableVC
        let screenClass = classForCoder.description()
        
        // [START set_current_screen]
        Analytics.logEvent(AnalyticsEventScreenView,
                           parameters: [AnalyticsParameterScreenName: screenName,
                                       AnalyticsParameterScreenClass: screenClass])
        // [END set_current_screen]
        
        print("screenName = \(screenName)")
        print("screenClass = \(screenClass)")
    }

    //MARK: - APIs
    func getAllValidatConfig() {
        allValidatConfigVM.getAllValidatConfig()
        allValidatConfigVM.userValidationConfig.bind { [weak self]value in
            DispatchQueue.main.async {
                Defaults.initValidationConfig(validate: value)
            }
        }
        
        // Set View Model Event Listener
        allValidatConfigVM.errorMsg.bind { [weak self]error in
            DispatchQueue.main.async {
                print(error)
            }
        }
    }
    
    func loginUser() {
        loginVM.LoginUser(withEmail: emailTxt.text!, password: passwordTxt.text!) { error, data in
            self.hideLoading()
            if let error = error {
                DispatchQueue.main.async {
                    self.view.makeToast(error)
                }
                return
            }
            guard let data = data else {return}
            Defaults.initUser(user: data)
            
            DispatchQueue.main.async {
                if Defaults.isWhiteLable {
//                    Router().toInbox()
//                    self.view.makeToast("")
                }else {
                    if Defaults.needUpdate == 1 {
                        Defaults.isFirstLogin = true
                        Router().toSTutorialScreensOneVC()
                    }else {
                        Defaults.isFirstLogin = false
                        Router().toFeed()
                    }
                }
            }
        }
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
                if Defaults.isWhiteLable {
//                    Router().toInbox()
                }else {
                    if Defaults.needUpdate == 1 {
                        Defaults.isFirstLogin = true
                        Router().toSTutorialScreensOneVC()
                    }else {
                            Defaults.isFirstLogin = false
                            Router().toFeed()
                    }
                }

            }
        }
    }
    
    //MARK: - Actions
    @IBAction func loginBtn(_ sender: Any) {
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: nil
        )
        
        hideKeyboard()
        if NetworkConected.internetConect {
            self.showLoading()
            loginUser()
        }else{
            return
        }
    }
    
    @IBAction func registerBtn(_ sender: Any) {
        guard let vc = UIViewController.viewController(withStoryboard: .Register, AndContollerID: "RegisterVC") as? RegisterVC else {return}
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func showPasswordBtn(_ sender: Any) {
        passwordTxt.isSecureTextEntry = !passwordTxt.isSecureTextEntry
        self.showPasswordBtn.isSelected = !self.showPasswordBtn.isSelected
    }
    
    @IBAction func forgetPasswordBtn(_ sender: Any) {
        guard let vc = UIViewController.viewController(withStoryboard: .Login, AndContollerID: "ForgetPasswordVC") as? ForgetPasswordVC else {return}
        self.navigationController?.pushViewController(vc, animated: true)
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
        }else{
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
    
    // - Tag: perform_appleid_password_request
    /// Prompts the user if an existing iCloud Keychain credential or Apple ID credential is found.
    func performExistingAccountSetupFlows() {
        // Prepare requests for both Apple ID and password providers.
        let requests = [ASAuthorizationAppleIDProvider().createRequest(),
                        ASAuthorizationPasswordProvider().createRequest()]
        
        // Create an authorization controller with the given requests.
        let authorizationController = ASAuthorizationController(authorizationRequests: requests)
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    //MARK: - Helper
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
    
    func setup() {
        emailView.setBorder(color: UIColor.color("#DDDFDD")?.cgColor, width: 1)
        passwordView.setBorder(color: UIColor.color("#DDDFDD")?.cgColor, width: 1)
        
        emailView.cornerRadiusView(radius: 6)
        passwordView.cornerRadiusView(radius: 6)
        facebookView.cornerRadiusView(radius: 6)
        googleView.cornerRadiusView(radius: 6)
        appleView.cornerRadiusView(radius: 6)
        googleView.setBorder()
        loginBtn.cornerRadiusView(radius: 8)
        loginBtnView.cornerRadiusView(radius: 8)
        
        emailTxt.addDoneOnKeyboard(withTarget: self, action: #selector(dismissKeyboard))
        passwordTxt.addDoneOnKeyboard(withTarget: self, action: #selector(dismissKeyboard))

    }
}

extension LoginVC {
    
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
extension LoginVC: ASAuthorizationControllerDelegate {
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
            print("Unable to save userIdentifier to keychain.")
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
extension LoginVC: ASAuthorizationControllerPresentationContextProviding {
    /// - Tag: provide_presentation_anchor
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    func initBackToFeedButton() {
        var imageName = ""
        imageName = "back_icon"
        let button = UIButton.init(type: .custom)
        let image = UIImage.init(named: imageName)
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        button.setImage(image, for: .normal)
        image?.withTintColor(UIColor.blue)
        button.addTarget(self, action:  #selector(goToWelcomeVC), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.leftBarButtonItem = barButton
    }
    
    @objc func goToWelcomeVC() {
        Router().toFeed()
    }

}
