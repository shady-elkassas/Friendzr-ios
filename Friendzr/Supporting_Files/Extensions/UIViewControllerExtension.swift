//
//  UIViewControllerExtension.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 10/08/2021.
//

import Foundation
import UIKit
import IQKeyboardManager
import Photos

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
        imageName = "back_icon"
        let button = UIButton.init(type: .custom)
        let image = UIImage.init(named: imageName)
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        button.setImage(image, for: .normal)
        image?.withTintColor(UIColor.blue)
        button.addTarget(self, action:  #selector(onPopup), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.leftBarButtonItem = barButton
    }
    
    func initBackColorButton() {
        
        var imageName = ""
        //        if Language.currentLanguage() == "ar" {
        imageName = "backWhite_icon"
        //        }else {
        //            imageName = "backWhite_icon"
        //        }
        
        let button = UIButton.init(type: .custom)
        let image = UIImage.init(named: imageName)
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        button.setImage(image, for: .normal)
        image?.withTintColor(UIColor.blue)
        button.backgroundColor = UIColor.FriendzrColors.primary?.withAlphaComponent(0.5)
        button.cornerRadiusForHeight()
        button.addTarget(self, action:  #selector(onPopup), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.leftBarButtonItem = barButton
    }
    
    func initCloseBarButton() {
        let button = UIButton.init(type: .custom)
        let image = UIImage(named: "close_ic")?.withRenderingMode(.alwaysTemplate)
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        button.setImage(image, for: .normal)
        button.tintColor = UIColor.setColor(lightColor: UIColor.black, darkColor: UIColor.white)
        button.addTarget(self, action: #selector(onDismiss), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.leftBarButtonItem = barButton
    }
    
    func initShareBarButton() {
        let button = UIButton.init(type: .custom)
        let image = UIImage(named: "share_ic")?.withRenderingMode(.alwaysTemplate)
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        button.setImage(image, for: .normal)
        button.tintColor = UIColor.FriendzrColors.primary
        button.addTarget(self, action: #selector(onDismiss), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    func initCancelBarButton() {
        let button = UIButton.init(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        button.setTitle("Cancel".localizedString, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont(name: "Montserrat-Medium", size: 12)
        button.setTitleColor(UIColor.setColor(lightColor: UIColor.black, darkColor: UIColor.white), for: .normal)
        button.addTarget(self, action: #selector(onDismiss), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.leftBarButtonItem = barButton
    }
    
    func initProfileBarButton(didTap:Bool) {
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        
        let imgView = UIImageView()
        imgView.sd_setImage(with: URL(string: Defaults.Image), placeholderImage: UIImage(named: "userPlaceHolderImage"))
        imgView.contentMode = .scaleAspectFill
        imgView.frame = view.bounds
        imgView.cornerRadiusView(radius: 22)
        
        let btn = UIButton(type: .custom)
        btn.isUserInteractionEnabled = didTap
        btn.addTarget(self, action: #selector(goToMyProfile), for: .touchUpInside)
        btn.frame = view.bounds
        btn.tintColor = .clear
        btn.cornerRadiusView(radius: 22)
        
        view.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        imgView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        btn.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        
        view.addSubview(imgView)
        view.addSubview(btn)
        
        let barButton = UIBarButtonItem(customView: view)
        self.navigationItem.leftBarButtonItem = barButton
    }
    
    @objc func goToMyProfile() {
        guard let vc = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "MyProfileViewController") as? MyProfileViewController else {return}
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func initFavoriteBarButton() {
        let button = UIButton.init(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        button.setImage(UIImage(named: "FavoritePage_ic"), for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont(name: "Montserrat-Medium", size: 12)
        button.addTarget(self, action: #selector(goToMyFavEvents), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.leftBarButtonItem = barButton
    }
    
    @objc func goToMyFavEvents() {
        guard let vc = UIViewController.viewController(withStoryboard: .Favorite, AndContollerID: "FavoriteVC") as? FavoriteVC else {return}
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
    
    func clearNavigationBar(size:CGFloat? = 14) {
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Montserrat-SemiBold", size: size ?? 14) ?? "",NSAttributedString.Key.foregroundColor: UIColor.setColor(lightColor: UIColor.color("#241332")!, darkColor: .white)]
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.backgroundColor = .clear
    }
    
    func setupNavBar() {
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Montserrat-SemiBold", size: 14) ?? "",NSAttributedString.Key.foregroundColor: UIColor.setColor(lightColor: UIColor.color("#241332")!, darkColor: .white)]
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.barTintColor = UIColor.setColor(lightColor: .white, darkColor: .black)
        self.navigationController?.navigationBar.shadowImage = UIColor.black.as1ptImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIColor.white.as1ptImage(), for: .default)
        self.navigationController?.navigationBar.backgroundColor = .white
        self.view.backgroundColor = .white
        self.navigationController?.navigationBar.layoutIfNeeded()
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
    
    func hideKeyboard() {
        view.endEditing(true)
    }
    
    
    func convertToImage(imagURL:String) -> UIImage {
        var image: UIImage? = UIImage()
        
        let imgURL = URL(string: imagURL) ?? URL(string: placeholderString)!
        do {
            let imgData = try NSData(contentsOf: imgURL, options: NSData.ReadingOptions())
            image = UIImage(data: imgData as Data)
        } catch {
        }
        
        return image!
    }
    
    
    func getAssetThumbnail(asset: PHAsset) -> UIImage {
        var img: UIImage?
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.version = .original
        options.isSynchronous = true
        manager.requestImageData(for: asset, options: options) { data, _, _, _ in
            
            if let data = data {
                img = UIImage(data: data)
            }
        }
        return img!
    }
    
    func showToast(message:String, font:UIFont? = UIFont(name: "Montserrat-Medium", size: 12)) {
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font ??  UIFont(name: "Montserrat-Medium", size: 12)
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    func getDate(isoDate:String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "dd-MM-yyyy'T'HH:mm:ssZ"
        let date = dateFormatter.date(from:isoDate)!
        return date
    }
    
    
    
    
    //create alert when user not access location
    func createSettingsAlertController(title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel".localizedString, style: .cancel)
        let settingsAction = UIAlertAction(title: NSLocalizedString("Settings".localizedString, comment: ""), style: .default) { (UIAlertAction) in
            if CLLocationManager.locationServicesEnabled() {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)! as URL, options: [:], completionHandler: nil)
            }else {
                UIApplication.shared.open(URL(string: "App-prefs:LOCATION_SERVICES")!)
            }
        }
        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)
        self.present(alertController, animated: true, completion: nil)
        
    }
    
//    func createSettingsAlertControllerLoctionService(title: String, message: String) {
//
//        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
//
//        let cancelAction = UIAlertAction(title: "Cancel".localizedString, style: .cancel)
//        let settingsAction = UIAlertAction(title: NSLocalizedString("Settings".localizedString, comment: ""), style: .default) { (UIAlertAction) in
//            UIApplication.shared.open(URL(string: "App-prefs:LOCATION_SERVICES")!)
//        }
//        alertController.addAction(cancelAction)
//        alertController.addAction(settingsAction)
//        self.present(alertController, animated: true, completion: nil)
//
//    }
}
