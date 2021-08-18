//
//  UIViewControllerExtension.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 10/08/2021.
//

import Foundation
import UIKit
import SkyFloatingLabelTextField

let appDelegate = UIApplication.shared.connectedScenes.first?.delegate as! SceneDelegate

extension UIViewController {
    
    class func viewController(withStoryboard storyboard: StoryBoard , AndContollerID id: String? = nil) -> UIViewController? {
        
        let storyboard = UIStoryboard(name: storyboard.rawValue, bundle: .main)
        let controller: UIViewController?
        if let contollerID  = id {
            controller = storyboard.instantiateViewController(withIdentifier: contollerID)
        } else {
            controller = storyboard.instantiateInitialViewController()
        }
        return controller
    }
    
    func showAlert(withTitle title: String? = "", withMessage message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "OK".localizedString, style: .default, handler: { action in
        })
        alert.addAction(cancel)
        DispatchQueue.main.async(execute: {
            self.present(alert, animated: true)
        })
    }
    
    func animateChangingImage (imageView:UIImageView,toImage:UIImage) {
        UIView.transition(with: imageView,
                          duration:0.5,
                          options: .curveEaseOut,
                          animations: { imageView.image = toImage },
                          completion: nil)
    }
    
    func timeString(time:TimeInterval) -> String {
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time)
        return String(format:"%02i:%02i", minutes, seconds)
    }
    
    func initBackButton(btnColor: UIColor? = .black) {
        var imageName = ""
        if Language.currentLanguage() == "ar" {
            imageName = "back_icon"
        }else {
            imageName = "back_icon"
        }
        
        let image = UIImage.init(named: imageName)
        let btn = UIBarButtonItem.init(image: image, style: .plain, target: self, action: #selector(onPopup))
        btn.tintColor = btnColor ?? .black
        navigationItem.leftBarButtonItem = btn
    }
    
    func initCloseBarButton(_ color: UIColor? = .black) {
        let button = UIButton.init(type: .custom)
        let image = UIImage(named: "close_ic")?.withRenderingMode(.alwaysTemplate)
        
        button.setImage(image, for: .normal)
        button.tintColor = color
        button.addTarget(self, action: #selector(onDismiss), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.leftBarButtonItem = barButton
    }
    
    func initProfileBarButton(_ color: UIColor? = .white) {
        let button = UIButton.init(type: .custom)
        let image = UIImage(named: "avatar")?.withRenderingMode(.alwaysOriginal)
        
        button.setImage(image, for: .normal)
        button.tintColor = color
        button.addTarget(self, action: #selector(goToMyProfile), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.leftBarButtonItem = barButton
    }
    
    @objc func goToMyProfile() {
        guard let vc = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "MyProfileVC") as? MyProfileVC else {return}
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func SetImageTitleNavigationBar(imageItem : String? = "logoooo") {
        let image = UIImage(named: imageItem!)
        let imageView = UIImageView(frame: CGRect(x: 20, y: 0, width: 0, height: 40))
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        self.navigationItem.titleView = imageView
    }
    
    func setNavigationBarTitle(title: String, color: UIColor? = .black) {
        let lbl1 = UILabel()
        lbl1.text = title
        lbl1.textColor = color ?? .black
        lbl1.font = UIFont(name: "Montserrat-SemiBold", size: 14)
        lbl1.textAlignment = .center
        
        self.parent?.navigationItem.title = title
    }
    
    func clearNavigationBar() {
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Montserrat-SemiBold", size: 14) ?? "",NSAttributedString.Key.foregroundColor: UIColor.color("#241332")!]
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .white
    }
        
    func setupNavBar() {
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Montserrat-SemiBold", size: 14) ?? "",NSAttributedString.Key.foregroundColor: UIColor.color("#241332")!]
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = .white
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage() , for:UIBarMetrics.default)
    }
    
    func hideNavigationBar(NavigationBar: Bool,BackButton: Bool) {
        self.navigationController?.isNavigationBarHidden = NavigationBar
        self.navigationItem.hidesBackButton = BackButton
    }
    
    func removeNavigationBorder() {
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.layoutIfNeeded()
    }
    
    @objc func onDismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func onPopup() {
        self.navigationController?.popViewController(animated: true)
    }
    
    // error show
    func initWorningTitleBarButton(_ text : String) {
        self.title = ""
        let button = UIButton.init(type: .custom)
        button.setTitle(text, for: .normal)
        button.titleLabel?.font = UIFont(name: "Tajawal-Medium", size: 12)
        button.setTitleColor( .white, for: .normal)
        navigationController?.navigationBar.tintColor = .red
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.leftBarButtonItem = barButton
    }
    
    func initSkipBarButton() {
        let skipBtn = UIButton()
        skipBtn.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        skipBtn.tintColor = .white
        skipBtn.setTitle("Skip".localizedString, for: .normal)
        skipBtn.addTarget(self, action: #selector(handleSkipBtn), for: .touchUpInside)
        let skipButton = UIBarButtonItem(customView: skipBtn)
        self.navigationItem.leftBarButtonItem = skipButton
    }
    
    
    @objc func handleSkipBtn(){
        Router().toHome()
    }
    
    func estimatedHeightOfLabel(width:Int,text: String) -> CGFloat {
        
        let size = CGSize(width: width - 16, height: 1000)
        
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        let attributes = [NSAttributedString.Key.font: UIFont(name: "Tajawal-Medium", size: 17)]
        
        let rectangleHeight = String(text).boundingRect(with: size, options: options, attributes: attributes as [NSAttributedString.Key : Any], context: nil).height
        
        return rectangleHeight
    }
    
    func estimatedWidthOfLabel(height:Int,text: String) -> CGFloat {
        
        let size = CGSize(width: 200, height: height)
        
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        let attributes = [NSAttributedString.Key.font: UIFont(name: "Tajawal-Medium", size: 12)]
        
        let rectangleWidth = String(text).boundingRect(with: size, options: options, attributes: attributes as [NSAttributedString.Key : Any], context: nil).width
        
        return rectangleWidth
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    func updateTextField(iView:UIView,txtField:SkyFloatingLabelTextField,placeholder:String,titleLbl:String) {
        txtField.placeholder = placeholder
        txtField.title = titleLbl
        txtField.backgroundColor = .clear
        txtField.placeholderFont = UIFont(name: "Montserrat-Medium", size: 14)!
        txtField.textColor = UIColor.color("#141414")
        txtField.titleFont = UIFont(name: "Montserrat-Medium", size: 16)!
        txtField.lineView = UIView()
        txtField.selectedTitleColor = UIColor.FriendzrColors.primary!
        iView.addSubview(txtField)
    }
}
