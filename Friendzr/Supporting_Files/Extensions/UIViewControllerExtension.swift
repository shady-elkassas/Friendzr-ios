//
//  UIViewControllerExtension.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 10/08/2021.
//

import Foundation
import UIKit

let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as! SceneDelegate
let appDelegate = UIApplication.shared.delegate as! AppDelegate

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
    
    func initBackButton() {
        
        var imageName = ""
        if Language.currentLanguage() == "ar" {
            imageName = "back_icon"
        }else {
            imageName = "back_icon"
        }
        
        let button = UIButton.init(type: .custom)
        let image = UIImage.init(named: imageName)
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        button.setImage(image, for: .normal)
        image?.withTintColor(UIColor.blue)
        //        button.tintColor = UIColor.setColor(lightColor: .white, darkColor: .white)
        button.addTarget(self, action:  #selector(onPopup), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.leftBarButtonItem = barButton
    }
    
    func initCloseBarButton() {
        let button = UIButton.init(type: .custom)
        let image = UIImage(named: "close_ic")?.withRenderingMode(.alwaysTemplate)
        
        button.setImage(image, for: .normal)
        button.tintColor = UIColor.setColor(lightColor: UIColor.black, darkColor: UIColor.white)
        button.addTarget(self, action: #selector(onDismiss), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.leftBarButtonItem = barButton
    }
    
    func initProfileBarButton(_ color: UIColor? = .white) {
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        let imgView = UIImageView()
        imgView.sd_setImage(with: URL(string: Defaults.Image), placeholderImage: UIImage(named: "placeholder"))
        imgView.frame = view.bounds
        imgView.contentMode = .scaleToFill
        imgView.cornerRadiusView(radius: 20)
        
        let btn = UIButton(type: .custom)
        btn.addTarget(self, action: #selector(goToMyProfile), for: .touchUpInside)
        btn.frame = view.bounds
        btn.tintColor = .clear
        
        view.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        imgView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        btn.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        view.addSubview(imgView)
        view.addSubview(btn)
        
        let barButton = UIBarButtonItem(customView: view)
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
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Montserrat-SemiBold", size: 14) ?? "",NSAttributedString.Key.foregroundColor: UIColor.setColor(lightColor: UIColor.color("#241332")!, darkColor: .white)]
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.backgroundColor = .clear
    }
    
    func setupNavBar() {
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Montserrat-SemiBold", size: 14) ?? "",NSAttributedString.Key.foregroundColor: UIColor.setColor(lightColor: UIColor.color("#241332")!, darkColor: .white)]
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.barTintColor = UIColor.setColor(lightColor: .white, darkColor: .black)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage() , for:UIBarMetrics.default)
        self.navigationController?.navigationBar.backgroundColor = .clear
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
    
    func initSkipBarButton() {
        let skipBtn = UIButton()
        skipBtn.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        skipBtn.tintColor = .white
        skipBtn.setTitle("Skip".localizedString, for: .normal)
        skipBtn.addTarget(self, action: #selector(handleSkipBtn), for: .touchUpInside)
        let skipButton = UIBarButtonItem(customView: skipBtn)
        self.navigationItem.leftBarButtonItem = skipButton
    }
    
    func updateTitleView(title: String, subtitle: String?, baseColor: UIColor = .white) {
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: -2, width: 0, height: 0))
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.textColor = baseColor
        titleLabel.font = UIFont.init(name: "Montserrat-Medium", size: 12)
        titleLabel.text = title
        titleLabel.textAlignment = .center
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.sizeToFit()
        
        let subtitleLabel = UILabel(frame: CGRect(x: 0, y: 18, width: 0, height: 0))
        subtitleLabel.textColor = baseColor.withAlphaComponent(0.95)
        subtitleLabel.font = UIFont.init(name: "Montserrat-Medium", size: 12)
        subtitleLabel.text = subtitle
        subtitleLabel.textAlignment = .center
        subtitleLabel.adjustsFontSizeToFitWidth = true
        subtitleLabel.sizeToFit()
        
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: max(titleLabel.frame.size.width, subtitleLabel.frame.size.width), height: 30))
        titleView.addSubview(titleLabel)
        if subtitle != nil {
            titleView.addSubview(subtitleLabel)
        } else {
            titleLabel.frame = titleView.frame
        }
        let widthDiff = subtitleLabel.frame.size.width - titleLabel.frame.size.width
        if widthDiff < 0 {
            let newX = widthDiff / 2
            subtitleLabel.frame.origin.x = abs(newX)
        } else {
            let newX = widthDiff / 2
            titleLabel.frame.origin.x = newX
        }
        
        navigationItem.titleView = titleView
    }
    
    
    func updateTitleView(image: String, subtitle: String?) {
        

        let imageUser = UIImageView(frame: CGRect(x: 0, y: -5, width: 25, height: 25))
        imageUser.backgroundColor = UIColor.clear
        imageUser.image = UIImage(named: image)
        imageUser.contentMode = .scaleToFill
        imageUser.cornerRadiusView(radius: 12.5)
        imageUser.sd_setImage(with: URL(string: image), placeholderImage: UIImage(named: "placeholder"))
        
        let subtitleLabel = UILabel(frame: CGRect(x: 0, y: 20, width: 0, height: 0))
        subtitleLabel.textColor = UIColor.setColor(lightColor: UIColor.black, darkColor: UIColor.white)
        subtitleLabel.font = UIFont.init(name: "Montserrat-Medium", size: 12)
        subtitleLabel.text = subtitle
        subtitleLabel.textAlignment = .center
        subtitleLabel.adjustsFontSizeToFitWidth = true
        subtitleLabel.sizeToFit()
        
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: max(imageUser.frame.size.width, subtitleLabel.frame.size.width), height: 30))
        titleView.addSubview(imageUser)
        if subtitle != nil {
            titleView.addSubview(subtitleLabel)
        } else {
            imageUser.frame = titleView.frame
        }
        let widthDiff = subtitleLabel.frame.size.width - imageUser.frame.size.width
        if widthDiff < 0 {
            let newX = widthDiff / 2
            subtitleLabel.frame.origin.x = abs(newX)
        } else {
            let newX = widthDiff / 2
            imageUser.frame.origin.x = newX
        }
        
//        let button = UIButton(frame: CGRect(x: 0, y: 0, width: max(imageUser.frame.size.width, subtitleLabel.frame.size.width), height: 30))
        
//        button.addSubview(titleView)
//        button.backgroundColor = .red
//        button.addTarget(self, action: #selector(handleSkipBtn), for: .allEvents)
        
        navigationItem.titleView = titleView
    }
    
    @objc func handleSkipBtn(){
        Router().toFeed()
    }
    
    func estimatedHeightOfLabel(width:Int,text: String) -> CGFloat {
        
        let size = CGSize(width: width - 16, height: 1000)
        
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        let attributes = [NSAttributedString.Key.font: UIFont(name: "Montserrat-Medium", size: 17)]
        
        let rectangleHeight = String(text).boundingRect(with: size, options: options, attributes: attributes as [NSAttributedString.Key : Any], context: nil).height
        
        return rectangleHeight
    }
    
    func estimatedWidthOfLabel(height:Int,text: String) -> CGFloat {
        
        let size = CGSize(width: 200, height: height)
        
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        let attributes = [NSAttributedString.Key.font: UIFont(name: "Montserrat-Medium", size: 12)]
        
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
    
    
    //    func updateTextField(iView:UIView,txtField:SkyFloatingLabelTextField,placeholder:String,titleLbl:String) {
    //        txtField.placeholder = placeholder
    //        txtField.title = titleLbl
    //        txtField.backgroundColor = .clear
    //        txtField.placeholderFont = UIFont(name: "Montserrat-Medium", size: 14)!
    //        txtField.textColor = UIColor.color("#141414")
    //        txtField.titleFont = UIFont(name: "Montserrat-Medium", size: 16)!
    //        txtField.lineView = UIView()
    //        txtField.selectedTitleColor = UIColor.FriendzrColors.primary!
    //        iView.addSubview(txtField)
    //    }
}
