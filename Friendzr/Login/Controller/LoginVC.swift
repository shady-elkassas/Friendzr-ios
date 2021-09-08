//
//  LoginVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 11/08/2021.
//

import UIKit
//import SkyFloatingLabelTextField
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn
import AuthenticationServices


class LoginVC: UIViewController {
    
    //MARK:- Outlets
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var loginBtnView: UIView!
    @IBOutlet weak var facebookView: UIView!
    @IBOutlet weak var googleView: UIView!
    @IBOutlet weak var appleView: UIView!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var showPasswordBtn: UIButton!
    
    let signInConfig = GIDConfiguration.init(clientID: "926947993090-o1kcsgkbqvd4h5d2lhlkprsuk91jeo03.apps.googleusercontent.com")
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
    
    var UserTwitterID = ""
    var UserTwitterEmail = ""
    var UserTwitterName = ""
    var UserTwitterToken = ""
    
//    let socialMediaVM: SocialMediaLoginViewModel = SocialMediaLoginViewModel()
    var loginVM:LoginViewModel = LoginViewModel()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initBackButton()
        setup()
        clearNavigationBar()
        removeNavigationBorder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        hideNavigationBar(NavigationBar: false, BackButton: false)
    }
    
    //MARK: - Actions
    @IBAction func loginBtn(_ sender: Any) {
        self.showLoading()
        loginVM.LoginUser(withEmail: emailTxt.text!, password: passwordTxt.text!) { error, data in
            self.hideLoading()
            if let error = error {
                self.showAlert(withMessage: error)
                return
            }
            guard let data = data else {return}
            Defaults.initUser(user: data)
            
            DispatchQueue.main.async {
                Router().toHome()
            }
        }
    }
    
    @IBAction func registerBtn(_ sender: Any) {
        guard let vc = UIViewController.viewController(withStoryboard: .Register, AndContollerID: "RegisterVC") as? RegisterVC else {return}
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func showPasswordBtn(_ sender: Any) {
        passwordTxt.isSecureTextEntry = !passwordTxt.isSecureTextEntry
    }
    
    @IBAction func forgetPasswordBtn(_ sender: Any) {
        guard let vc = UIViewController.viewController(withStoryboard: .Login, AndContollerID: "ForgetPasswordVC") as? ForgetPasswordVC else {return}
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func facebookBtn(_ sender: Any) {
        
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
    
    @IBAction func googleBtn(_ sender: Any) {
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
                    let img = user.profile?.imageURL(withDimension: 200)?.absoluteString
                    
                    print("\(self.UserG_mailID),\(self.UserG_mailEmail),\(self.UserG_userName)")
                }
                
            }
        }
    }
    
    @IBAction func appleBtn(_ sender: Any) {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    //MARK: - Helper
    func setup() {
        emailView.setBorder(color: UIColor.color("#DDDFDD")?.cgColor, width: 1)
        passwordView.setBorder(color: UIColor.color("#DDDFDD")?.cgColor, width: 1)
        
        emailView.cornerRadiusView(radius: 6)
        passwordView.cornerRadiusView(radius: 6)
        
//        updateTextField(iView: emailView, txtField: emailTxt, placeholder: "Email", titleLbl: "Email")
//        updateTextField(iView: passwordView, txtField: passwordTxt, placeholder: "Password", titleLbl: "Password")

        facebookView.cornerRadiusView(radius: 6)
        googleView.cornerRadiusView(radius: 6)
        appleView.cornerRadiusView(radius: 6)
        googleView.setBorder()
        
        
        let fistColor = UIColor.color("#7BE495")!
        let lastColor = UIColor.color("#329D9C")!
        let gradient = CAGradientLayer(start: .topLeft, end: .bottomRight, colors: [fistColor.cgColor,lastColor.cgColor], type: .radial)
        gradient.frame = loginBtn.frame
        loginBtn.layer.addSublayer(gradient)
        loginBtn.cornerRadiusView(radius: 8)
        loginBtnView.cornerRadiusView(radius: 8)
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
            request.start (completionHandler: { (connection, result, error) in
                
                
                if let error = error {
                    //                    print("\(error.localizedDescription)")
                } else{
                    let userInfo = result as! [String : AnyObject]
                    
                    self.UserFBID = userInfo["id"] as! String
                    self.UserFBMobile = userInfo["phone"] as? String ?? ""
                    self.UserFBUserName = userInfo["name"] as! String
                    self.UserFBEmail = userInfo["email"] as? String ?? ""
                    self.userFace_BookAccessToken = AccessToken.current!.tokenString
                    let img = userInfo["picture"] as! [String:AnyObject]
                    //                    self.UserFBImage = img["data"]!["url"] as? String ?? ""
                    if let imgurL = img["data"] as? [String:AnyObject] {
                        self.UserFBImage = imgurL["url"] as? String ?? ""
                    }
                    
                    print("\(self.UserFBID),\(self.UserFBUserName),\(self.UserFBEmail)")
                }
            })
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
            try KeychainItem(service: "com.Alef.coupouns-ios", account: "userIdentifier").saveItem(userIdentifier)
        } catch {
            //            print("Unable to save userIdentifier to keychain.")
        }
    }
    
    private func showResultViewController(userIdentifier: String, fullName: PersonNameComponents?, email: String?) {
        
//        DispatchQueue.main.async {
//            self.showLoading()
//            self.socialMediaVM.SocialMediaLogin(BySocialMediaId: userIdentifier) { (error, data) in
//                if let error = error {
//                    var usernameApple = "Apple User"
//                    var useremailApple = userIdentifier
//                    if let givenName = fullName?.givenName {
//                        usernameApple = givenName
//                    }
//
//                    if let email = email {
//                        useremailApple = email
//                    }
//                    self.socialMediaVM.SocialMediaRegisteration(withUserName:  usernameApple, AndMobile: "", AndSocialMediaId:  userIdentifier , AndSocialMediaType: "APPLE", imgURL: "", email:  useremailApple) { (error, data) in
//                        self.hideLoading()
//                        if error != nil && error != "" {
//                            self.showAlert(withMessage: error!)
//                        }
//                        guard let data = data else {return}
//                        Defaults.token = data.token
//                        Defaults.initUser(user: data)
//                        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: nil)
//                        if data.user?.isVerified == false {
//                            Router().toVerification(code:data.smsToken)
//                        }else {
//                            Router().toHome()
//                        }
//                        return
//                    }
//
//                    return
//                }
//
//                guard let data = data else {return}
//                Defaults.token = data.token
//                Defaults.initUser(user: data)
//                NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: nil)
//                self.hideLoading()
//                if data.user?.isVerified == false {
//                    Router().toVerification(code:data.smsToken)
//                }else {
//                    Router().toHome()
//                }
//                //                        }
//            }
//
//        }
        
        
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
}
