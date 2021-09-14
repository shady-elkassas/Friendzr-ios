//
//  MoreVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 15/08/2021.
//

import UIKit
import MessageUI

class MoreVC: UIViewController, MFMailComposeViewControllerDelegate {
    
    //MARK:- Outlets
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - Properties
    let cellID = "MoreTableViewCell"
    var moreList : [(String,UIImage)] = []
    var logoutVM:LogoutViewModel = LogoutViewModel()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    override func viewWillAppear(_ animated: Bool) {
        clearNavigationBar()
        setupUserData()
    }
    
    //MARK: - Helper
    func setup() {
        tableView.register(UINib(nibName: cellID, bundle: nil), forCellReuseIdentifier: cellID)
        containerView.setCornerforTop(withShadow: false, cornerMask: [.layerMaxXMinYCorner, .layerMinXMinYCorner], radius: 50)
        moreList.append(("Profile".localizedString, UIImage(named: "Profile_ic")!))
        moreList.append(("Events".localizedString, UIImage(named: "Events_ic")!))
        moreList.append(("Notifications".localizedString, UIImage(named: "notificationList_ic")!))
        moreList.append(("Settings".localizedString, UIImage(named: "Settings_ic")!))
        moreList.append(("Block List".localizedString, UIImage(named: "blocked_ic")!))
        moreList.append(("Contact Us".localizedString, UIImage(named: "Contactus_ic")!))
        moreList.append(("About Us".localizedString, UIImage(named: "information_ic")!))
        moreList.append(("Terms & Conditions".localizedString, UIImage(named: "Terms_ic")!))
        moreList.append(("Share".localizedString, UIImage(named: "Share_ic")!))
        moreList.append(("Log Out".localizedString, UIImage(named: "logout_ic")!))
        
    }
    
    func setupUserData() {
        profileImg.setBorder(color: UIColor.FriendzrColors.primary?.cgColor, width: 2)
        profileImg.cornerRadiusForHeight()
        profileImg.sd_setImage(with: URL(string: Defaults.Image), placeholderImage: UIImage(named: "avatar"))
        nameLbl.text = Defaults.userName
    }
    
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
        return cell
    }
}

extension MoreVC : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0: //profile
            guard let vc = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "MyProfileVC") as? MyProfileVC else {return}
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case 1: //Events
            guard let vc = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "EventsVC") as? EventsVC else {return}
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case 2://notificationList
            break
        case 3: //settings
            guard let vc = UIViewController.viewController(withStoryboard: .More, AndContollerID: "SettingsVC") as? SettingsVC else {return}
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case 4: //block list
            break
        case 5: //contactus
            let emailTitle = ""
            let messageBody = ""
            let toRecipents = ["friend@stackoverflow.com"]
            let mc: MFMailComposeViewController = MFMailComposeViewController()
            mc.mailComposeDelegate = self
            mc.setSubject(emailTitle)
            mc.setMessageBody(messageBody, isHTML: false)
            mc.setToRecipients(toRecipents)
            self.present(mc, animated: true, completion: nil)
            break
        case 6://aboutus
            guard let vc = UIViewController.viewController(withStoryboard: .More, AndContollerID: "TermsAndConditionsVC") as? TermsAndConditionsVC else {return}
            vc.titleVC = "About Us"
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case 7://terms
            guard let vc = UIViewController.viewController(withStoryboard: .More, AndContollerID: "TermsAndConditionsVC") as? TermsAndConditionsVC else {return}
            vc.titleVC = "Terms & Conditions"
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case 8://share
            // Setting description
            let firstActivityItem = "Description you want.."
            
            // Setting url
            let secondActivityItem : NSURL = NSURL(string: "http://your-url.com/")!
            
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
            break
        case 9://logout
            self.showLoading()
            logoutVM.logoutRequest { error, data in
                self.hideLoading()
                if let error = error {
                    self.showAlert(withMessage: error)
                    return
                }
                
                guard let _ = data else {return}
                
                Defaults.deleteUserData()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3 , execute: {
                    Router().toLogin()
                })
            }
            break
        default:
            break
        }
    }
}
