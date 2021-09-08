//
//  EditMyProfileVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 16/08/2021.
//

import UIKit

class EditMyProfileVC: UIViewController {
    
    //MARK:- Outlets
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var superView: UIView!
    @IBOutlet weak var nameTxt: UITextField!
    @IBOutlet weak var dateBirthLbl: UILabel!
    @IBOutlet weak var bioTxtView: UITextView!
    @IBOutlet weak var tagsLbl: UILabel!
    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var maleImg: UIImageView!
    @IBOutlet weak var femaleImg: UIImageView!
    @IBOutlet weak var otherImg: UIImageView!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var tagsView: UIView!
    @IBOutlet weak var aboutMeView: UIView!
    @IBOutlet weak var placeHolderLbl: UILabel!
    
    //MARK: - Properties
    lazy var alertView = Bundle.main.loadNibNamed("CalendarView", owner: self, options: nil)?.first as? CalendarView
    var genderString = ""
    let imagePicker = UIImagePickerController()
    var userImg:String = ""
    var viewmodel:EditProfileViewModel = EditProfileViewModel()
    var userModel: ProfileObj? = nil
    var tagsid:[Int] = [Int]()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Edit Profile"
        setup()
        setupDate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initBackButton()
        clearNavigationBar()
    }
    
    //MARK: - Helpers
    func setup() {
        saveBtn.cornerRadiusView(radius: 8)
        nameView.cornerRadiusView(radius: 8)
        dateView.cornerRadiusView(radius: 8)
        bioTxtView.cornerRadiusView(radius: 8)
        tagsView.cornerRadiusView(radius: 8)
        aboutMeView.cornerRadiusView(radius: 8)
        profileImg.cornerRadiusForHeight()
        bioTxtView.delegate = self
    }
    
    func setupDate() {
        nameTxt.text = userModel?.userName
        bioTxtView.text = userModel?.bio
        dateBirthLbl.text = userModel?.birthdate
        profileImg.sd_setImage(with: URL(string: userModel?.userImage ?? "" ), placeholderImage: UIImage(named: "avatar"))

        
        if userModel?.gender == "male" {
            maleImg.image = UIImage(named: "select_ic")
            femaleImg.image = UIImage(named: "unSelect_ic")
            otherImg.image = UIImage(named: "unSelect_ic")
            
            genderString = "male"
        }else if userModel?.gender == "female" {
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
    
    func OnInterestsCallBack(_ data: [Int], _ value: [String]) -> () {
        print(data, value)
        
        var items = ""
        for item in value {
            items = item + " ," + items
        }
        
        tagsid.removeAll()
        for tag in data {
            tagsid.append(tag)
        }
        
        self.tagsLbl.text = String(items.dropLast())
        self.tagsLbl.textColor = .black
    }
    
    //MARK: - Actions
    @IBAction func editProfileImgBtn(_ sender: Any) {
        
        self.profileImg.image = UIImage(named: "bolivia")
        let imageData:Data = self.profileImg.image!.jpeg(.lowest)! as Data
        let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
        self.userImg = strBase64
        print(strBase64)

//        if UIDevice.current.userInterfaceIdiom == .pad {
//            let settingsActionSheet: UIAlertController = UIAlertController(title:nil, message:nil, preferredStyle: .alert)
//
//            settingsActionSheet.addAction(UIAlertAction(title:"Camera".localizedString, style:UIAlertAction.Style.default, handler:{ action in
//                self.openCamera()
//            }))
//            settingsActionSheet.addAction(UIAlertAction(title:"Photo Liberary".localizedString, style:UIAlertAction.Style.default, handler:{ action in
//                self.openLibrary()
//            }))
//            settingsActionSheet.addAction(UIAlertAction(title:"Cancel".localizedString, style:UIAlertAction.Style.cancel, handler:nil))
//
//            present(settingsActionSheet, animated:true, completion:nil)
//
//        }else {
//            let settingsActionSheet: UIAlertController = UIAlertController(title:nil, message:nil, preferredStyle:UIAlertController.Style.actionSheet)
//
//            settingsActionSheet.addAction(UIAlertAction(title:"Camera".localizedString, style:UIAlertAction.Style.default, handler:{ action in
//                self.openCamera()
//            }))
//            settingsActionSheet.addAction(UIAlertAction(title:"Photo Liberary".localizedString, style:UIAlertAction.Style.default, handler:{ action in
//                self.openLibrary()
//            }))
//            settingsActionSheet.addAction(UIAlertAction(title:"Cancel".localizedString, style:UIAlertAction.Style.cancel, handler:nil))
//
//            present(settingsActionSheet, animated:true, completion:nil)
//        }
    }
    
    @IBAction func dateBtn(_ sender: Any) {
        alertView?.frame = CGRect(x: 0, y: -100, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        alertView?.HandleOKBtn = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            self.dateBirthLbl.text = formatter.string(from: (self.alertView?.calendarView.date)!)
            
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
        guard let vc = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "TagsVC") as? TagsVC else {return}
        vc.onInterestsCallBackResponse = self.OnInterestsCallBack
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func integrationInstgramBtn(_ sender: Any) {
    }
    
    @IBAction func integrationSnapchatBtn(_ sender: Any) {
    }
    
    @IBAction func integrationFacebookBtn(_ sender: Any) {
    }
    
    @IBAction func integrationTiktokBtn(_ sender: Any) {
    }

    @IBAction func saveBtn(_ sender: Any) {
        self.showLoading()
        viewmodel.editProfile(withUserName: nameTxt.text!, AndEmail: Defaults.Email, AndGender: genderString, AndGeneratedUserName: nameTxt.text!, AndBio: bioTxtView.text! , AndBirthdate: dateBirthLbl.text!, AndUserImage: userImg,tagsId:tagsid) { error, data in
            self.hideLoading()
            if let error = error {
                self.showAlert(withMessage: error)
                return
            }
            
            guard let _ = data else {return}
            self.showAlert(withMessage: "edit save")
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
            imagePicker.sourceType = UIImagePickerController.SourceType.camera;
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
            
            self.profileImg.image = UIImage(named: "bolivia")
            let imageData:Data = image.jpeg(.lowest)! as Data
            let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
            self.userImg = strBase64
            print(strBase64)
        })
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated:true, completion: nil)
    }
}

extension EditMyProfileVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeHolderLbl.isHidden = !textView.text.isEmpty
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (bioTxtView.text as NSString).replacingCharacters(in: range, with: text)
        return newText.count < 250
    }
}
