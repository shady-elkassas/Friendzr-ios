//
//  OptionsSignUpVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 11/08/2021.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn
import AuthenticationServices

class OptionsSignUpVC: UIViewController,UIGestureRecognizerDelegate {

    //MARK:- Outlets
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var facebookView: UIView!
    @IBOutlet weak var appleView: UIView!
    @IBOutlet weak var googleView: UIView!
    
    @IBOutlet weak var termsLbl: UILabel!
    
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

//    var socailMediaRegisterVM:SocialMediaRegisterViewModel = SocialMediaRegisterViewModel()
    let socialMediaLoginVM: SocialMediaLoginViewModel = SocialMediaLoginViewModel()

    var internetConect:Bool = false

    var myString:String = "By clicking ‘Sign up’, you agree to our terms of usage see more".localizedString
    var myMutableString = NSMutableAttributedString()

    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: nil
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Defaults.availableVC = "OptionsSignUpVC"
        print("availableVC >> \(Defaults.availableVC)")

        hideNavigationBar(NavigationBar: true, BackButton: true)
        CancelRequest.currentTask = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.hideLoading()
        CancelRequest.currentTask = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        performExistingAccountSetupFlows()
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    //MARK: - Helper
    func setupView() {
        emailView.cornerRadiusView(radius: 6)
        facebookView.cornerRadiusView(radius: 6)
        appleView.cornerRadiusView(radius: 6)
        googleView.cornerRadiusView(radius: 6)
        googleView.setBorder()
        
        myMutableString = NSMutableAttributedString(string: myString, attributes: [NSAttributedString.Key.font:UIFont(name: "Montserrat-Regular", size: 12.0)!])
        myMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.FriendzrColors.primary!, range: NSRange(location:55,length:8))
        // set label Attribute
        termsLbl.attributedText = myMutableString
    }
    

    func updateUserInterface() {
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
        self.view.makeToast("Network is unavailable, please try again!".localizedString)
    }

    //MARK: - Actions
    @IBAction func termsBtn(_ sender: Any) {
        guard let vc = UIViewController.viewController(withStoryboard: .More, AndContollerID: "TermsAndConditionsVC") as? TermsAndConditionsVC else {return}
        vc.titleVC = "Terms & Conditions".localizedString
        vc.urlString = "https://friendzr.com/wp-content/uploads/2021/10/EULAOct2021.pdf"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func loginBtn(_ sender: Any) {
        guard let vc = UIViewController.viewController(withStoryboard: .Login, AndContollerID: "LoginVC") as? LoginVC else {return}
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func emailBtn(_ sender: Any) {
        guard let vc = UIViewController.viewController(withStoryboard: .Register, AndContollerID: "RegisterVC") as? RegisterVC else {return}
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func facebookBtn(_ sender: Any) {
        updateUserInterface()
        if internetConect {
            if let token = AccessToken.current,
               !token.isExpired {
                // User is logged in, do work such as go to next view controller.
                getFBUserData()
            }
            else {
                let fbLoginManager : LoginManager = LoginManager()
                fbLoginManager.logIn(permissions: ["public_profile","email"], from: self) { (result, error) -> Void in
                    
                    if (error == nil) {
                        if error != nil {
                        }else if (result?.isCancelled)!{
                            return
                        }else {
                            self.getFBUserData()
                        }
                    }
                }
            }
        }else{
            return
        }

    }
    
    @IBAction func googleBtn(_ sender: Any) {
        updateUserInterface()
        if internetConect {
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
                        self.UserG_mailLastName = (user.profile?.familyName)!
                        self.UserG_mailEmail = user.profile?.email ?? ""
                        self.userG_mailAccessToken = user.authentication.idToken ?? ""
                        self.UserG_userName = self.UserG_mailFirstName + " " + self.UserG_mailLastName
                        //            user.profile = user.profile.hasImage
                        //                    let img = user.profile?.imageURL(withDimension: 200)?.absoluteString
                        
                        print("\(self.UserG_mailID),\(self.UserG_mailEmail),\(self.UserG_userName)")
                        
                        self.showLoading()
                        self.socialMediaLoginVM.socialMediaLoginUser(withSocialMediaId: self.UserG_mailID, AndEmail: self.UserG_mailEmail, username: self.UserG_userName, completion: { (error, data) in
                            self.hideLoading()
                            if let error = error {
//                                self.showAlert(withMessage: error)
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
                                    Router().toSplachOne()
                                }else {
                                    Router().toFeed()
                                }
                            }
                        })
                    }
                }
            }
        }else{
            
        }

    }
    
    @IBAction func appleBtn(_ sender: Any) {
        updateUserInterface()
        if internetConect {
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
}

//extension for fb register
extension OptionsSignUpVC {
    
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
            
            let request = GraphRequest(graphPath: "/me", parameters: ["fields": "id, picture.type(large), name,email"], httpMethod: .get)
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
                    
                    self.showLoading()
                    self.socialMediaLoginVM.socialMediaLoginUser(withSocialMediaId: self.UserFBID, AndEmail: self.UserFBEmail, username: self.UserFBUserName, completion: { (error, data) in
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
                                Router().toSplachOne()
                            }else {
                                Router().toFeed()
                            }
                        }
                    })
                }
            }
        }
    }
}

@available(iOS 13.0, *)
extension OptionsSignUpVC: ASAuthorizationControllerDelegate {
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
            
            self.showLoading()
            self.socialMediaLoginVM.socialMediaLoginUser(withSocialMediaId: userIdentifier, AndEmail: useremailApple,username:usernameApple) { (error, data) in
                self.hideLoading()
                if let error = error {
//                    self.showAlert(withMessage: error)
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
                        Router().toSplachOne()
                    }else {
                        Router().toFeed()
                    }
                }
            }
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
extension OptionsSignUpVC: ASAuthorizationControllerPresentationContextProviding {
    /// - Tag: provide_presentation_anchor
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
