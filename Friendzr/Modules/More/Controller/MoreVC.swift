//
//  MoreVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 15/08/2021.
//

import UIKit
import MessageUI
import AuthenticationServices
import Firebase
import FirebaseMessaging

class MoreVC: UIViewController, MFMailComposeViewControllerDelegate,UIGestureRecognizerDelegate,UIPopoverPresentationControllerDelegate {
    
    //MARK:- Outlets
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var showProfileImg: UIButton!
    
    @IBOutlet weak var profileImgH: NSLayoutConstraint!
    @IBOutlet weak var profileImgW: NSLayoutConstraint!
    
    //MARK: - Properties
    let cellID = "MoreTableViewCell"
    var moreList : [(String,UIImage)] = []
    var logoutVM:LogoutViewModel = LogoutViewModel()
    
    lazy var alertView = Bundle.main.loadNibNamed("BlockAlertView", owner: self, options: nil)?.first as? BlockAlertView
    
    var internetConect:Bool = false
    var btnsSelcted:Bool = false
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Defaults.availableVC = "MoreVC"
        print("availableVC >> \(Defaults.availableVC)")

        clearNavigationBar()
        DispatchQueue.main.async {
            self.updateUserInterface()
        }
        
        CancelRequest.currentTask = false
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateMoreTableView), name: Notification.Name("updateMoreTableView"), object: nil)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.hideLoading()
        CancelRequest.currentTask = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    @objc func updateMoreTableView() {
        tableView.reloadData()
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
    @IBAction func showProfileImgBtn(_ sender: Any) {
        guard let popupVC = UIViewController.viewController(withStoryboard: .Main, AndContollerID: "ShowImageVC") as? ShowImageVC else {return}
        popupVC.modalPresentationStyle = .overCurrentContext
        popupVC.modalTransitionStyle = .crossDissolve
        let pVC = popupVC.popoverPresentationController
        pVC?.permittedArrowDirections = .any
        pVC?.delegate = self
        pVC?.sourceRect = CGRect(x: 100, y: 100, width: 1, height: 1)
        popupVC.imgURL = Defaults.Image
        present(popupVC, animated: true, completion: nil)
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
            setupUserData()
        case .wifi:
            internetConect = true
            setupUserData()
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
    
    func setupView() {
        tableView.register(UINib(nibName: cellID, bundle: nil), forCellReuseIdentifier: cellID)
        containerView.setCornerforTop(withShadow: false, cornerMask: [.layerMaxXMinYCorner, .layerMinXMinYCorner], radius: 50)
        
        moreList.append(("My Profile".localizedString, UIImage(named: "Profile_ic")!))
        moreList.append(("My Events".localizedString, UIImage(named: "Events_ic")!))
        moreList.append(("Notifications".localizedString, UIImage(named: "notificationList_ic")!))
        moreList.append(("Share".localizedString, UIImage(named: "Share_ic")!))
        moreList.append(("Settings".localizedString, UIImage(named: "Settings_ic")!))
        moreList.append(("Tips & Guidances".localizedString, UIImage(named: "Settings_ic")!))
        moreList.append(("About Us".localizedString, UIImage(named: "information_ic")!))
        moreList.append(("Terms & Conditions".localizedString, UIImage(named: "Terms_ic")!))
        moreList.append(("Privacy Policy".localizedString, UIImage(named: "privacy_ic")!))
        moreList.append(("Contact Friendzr".localizedString, UIImage(named: "Contactus_ic")!))
        moreList.append(("Help".localizedString, UIImage(named: "Contactus_ic")!))
        moreList.append(("Log Out".localizedString, UIImage(named: "logout_ic")!))
        
        if Defaults.isIPhoneSmall {
            profileImgH.constant = 150
            profileImgW.constant = 150
            profileImg.cornerRadiusView(radius: 75)
        }else {
            profileImgH.constant = 200
            profileImgW.constant = 200
            profileImg.cornerRadiusView(radius: 100)
        }
        
        profileImg.setBorder(color: UIColor.FriendzrColors.primary?.cgColor, width: 2)
    }
    
    func setupUserData() {
        profileImg.sd_setImage(with: URL(string: Defaults.Image), placeholderImage: UIImage(named: "placeHolderApp"))
        nameLbl.text = Defaults.userName
    }
    
    //mail compose controller
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .cancelled:
            print("Mail cancelled")
        case .saved:
            print("Mail saved")
        case .sent:
            print("Mail sent")
        case .failed:
            print("Mail sent failure: \(error?.localizedDescription ?? "")")
        default:
            break
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func shareApp() {
        // Setting description
        let firstActivityItem = ""
        
        // Setting url
        let secondActivityItem : NSURL = NSURL(string: "https://friendzr.com/about-us/")!
        
        // If you want to use an image
        let image : UIImage = UIImage(named: "Share_ic")!
        
        let activityViewController : UIActivityViewController = UIActivityViewController(
            activityItems: [firstActivityItem, secondActivityItem, image], applicationActivities: nil)
        
        // This lines is for the popover you need to show in iPad
        activityViewController.popoverPresentationController?.sourceView = activityViewController.view
        
        // This line remove the arrow of the popover to show in iPad
        activityViewController.popoverPresentationController?.permittedArrowDirections =  UIPopoverArrowDirection.down
        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)
        
        // Pre-configuring activity items
        activityViewController.activityItemsConfiguration = [
            UIActivity.ActivityType.message
        ] as? UIActivityItemsConfigurationReading
        
        // Anything you want to exclude
        activityViewController.excludedActivityTypes = [
            UIActivity.ActivityType.postToWeibo,
            UIActivity.ActivityType.print,
            UIActivity.ActivityType.assignToContact,
            UIActivity.ActivityType.saveToCameraRoll,
            UIActivity.ActivityType.addToReadingList,
            UIActivity.ActivityType.postToFlickr,
            UIActivity.ActivityType.postToVimeo,
            UIActivity.ActivityType.postToTencentWeibo,
            UIActivity.ActivityType.postToFacebook
        ]
        
        activityViewController.isModalInPresentation = true
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    
    func logout() {
        alertView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        alertView?.titleLbl.text = "Confirm?".localizedString
        alertView?.detailsLbl.text = "Are you sure you want to logout?".localizedString
        
        alertView?.HandleConfirmBtn = {
            self.updateUserInterface()
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
                    
                    // For the purpose of this demo app, delete the user identifier that was previously stored in the keychain.
                    KeychainItem.deleteUserIdentifierFromKeychain()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3 , execute: {
                        Router().toOptionsSignUpVC()
                    })
                }
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
}
//MARK: - Extensions
extension MoreVC : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return moreList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? MoreTableViewCell else {return UITableViewCell()}
        cell.imgView.image = moreList[indexPath.row].1
        cell.titleLbl.text = moreList[indexPath.row].0
        cell.imgView.image?.withTintColor(UIColor.setColor(lightColor: .black, darkColor: .white))
        
        if indexPath.row == 2 {
            if Defaults.badgeNumber == 0 {
                cell.badgeView.isHidden = true
            }else {
                cell.badgeLbl.text = "\(Defaults.badgeNumber)"
                cell.badgeView.isHidden = false
            }
        }else {
            cell.badgeView.isHidden = true
        }
        
        return cell
    }
}

extension MoreVC : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        updateUserInterface()
        switch indexPath.row {
        case 0: //my profile
            if internetConect {
                guard let vc = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "MyProfileViewController") as? MyProfileViewController else {return}
                self.navigationController?.pushViewController(vc, animated: true)
            }
            break
        case 1: //Events
            if internetConect {
                guard let vc = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "EventsVC") as? EventsVC else {return}
                self.navigationController?.pushViewController(vc, animated: true)
            }
            break
        case 2://notificationList
            if internetConect {
                guard let vc = UIViewController.viewController(withStoryboard: .More, AndContollerID: "NotificationsVC") as? NotificationsVC else {return}
                UIApplication.shared.applicationIconBadgeNumber = 0
                Defaults.badgeNumber = 0
                self.tableView.reloadData()
                self.navigationController?.pushViewController(vc, animated: true)
            }
            break
        case 3: //share
            if internetConect {
                shareApp()
            }
            break
        case 4: //settings
            if internetConect {
                guard let vc = UIViewController.viewController(withStoryboard: .More, AndContollerID: "SettingsVC") as? SettingsVC else {return}
                self.navigationController?.pushViewController(vc, animated: true)
            }
            break
        case 5://Tips& Guides
            if internetConect {
                guard let vc = UIViewController.viewController(withStoryboard: .More, AndContollerID: "TermsAndConditionsVC") as? TermsAndConditionsVC else {return}
                vc.titleVC = "Tips & Guides".localizedString
                vc.urlString = "https://friendzr.com/blog-tips-guidance/"
                self.navigationController?.pushViewController(vc, animated: true)
            }
            break
        case 6://aboutus
            if internetConect {
                guard let vc = UIViewController.viewController(withStoryboard: .More, AndContollerID: "TermsAndConditionsVC") as? TermsAndConditionsVC else {return}
                vc.titleVC = "About Us".localizedString
                vc.urlString = "https://friendzr.com/about-us/"
                self.navigationController?.pushViewController(vc, animated: true)
            }
            break
        case 7://terms
            if internetConect {
                guard let vc = UIViewController.viewController(withStoryboard: .More, AndContollerID: "TermsAndConditionsVC") as? TermsAndConditionsVC else {return}
                vc.titleVC = "Terms & Conditions".localizedString
                vc.urlString = "https://friendzr.com/wp-content/uploads/2021/10/EULAOct2021.pdf"
                self.navigationController?.pushViewController(vc, animated: true)
            }
            break
        case 8://Privacy Policy
            if internetConect {
                guard let vc = UIViewController.viewController(withStoryboard: .More, AndContollerID: "TermsAndConditionsVC") as? TermsAndConditionsVC else {return}
                vc.titleVC = "Privacy Policy".localizedString
                vc.urlString = "https://friendzr.com/wp-content/uploads/2021/10/Friendzr-Privacy-Policy.pdf"
                self.navigationController?.pushViewController(vc, animated: true)
            }
            break
        case 9: //contactus
            if internetConect {
                let subjectTitle = "Suggestions"
                let messageBody = ""
                let toRecipents = ["support@friendzr.com"]
                let mc: MFMailComposeViewController = MFMailComposeViewController()
                mc.mailComposeDelegate = self
                mc.setSubject(subjectTitle)
                mc.setMessageBody(messageBody, isHTML: false)
                mc.setToRecipients(toRecipents)
                self.present(mc, animated: true, completion: nil)
            }
            break
        case 10://help
            break
        case 11://logout
            logout()
            break
        default:
            break
        }
    }
}
