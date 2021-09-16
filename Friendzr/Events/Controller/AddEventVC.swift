//
//  AddEventVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 17/08/2021.
//

import Foundation
import UIKit

class AddEventVC: UIViewController {
    
    //MARK:- Outlets
    @IBOutlet weak var eventImg: UIImageView!
    @IBOutlet weak var addImg: UIButton!
    @IBOutlet weak var addTitleTxt: UITextField!
    @IBOutlet weak var switchAllDays: UISwitch!
    @IBOutlet weak var startDayLbl: UILabel!
    @IBOutlet weak var endDayLbl: UILabel!
    @IBOutlet weak var startTimeLbl: UILabel!
    @IBOutlet weak var endTimeLbl: UILabel!
    @IBOutlet weak var hiddenLbl: UILabel!
    @IBOutlet weak var descriptionTxtView: UITextView!
    @IBOutlet weak var limitUsersView: UIView!
    @IBOutlet weak var limitUsersTxt: UITextField!
    @IBOutlet weak var categoryLbl: UILabel!
    @IBOutlet weak var chooseCatBtn: UIButton!
    @IBOutlet weak var datesView: UIView!
    @IBOutlet weak var datesViewHeight: NSLayoutConstraint!
    @IBOutlet weak var startDateBtn: UIButton!
    @IBOutlet weak var endDateBtn: UIButton!
    @IBOutlet weak var startTimeBtn: UIButton!
    @IBOutlet weak var endTimeBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    
    //MARK: - Properties
    lazy var dateAlertView = Bundle.main.loadNibNamed("EventCalendarView", owner: self, options: nil)?.first as? EventCalendarView
    lazy var timeAlertView = Bundle.main.loadNibNamed("EventTimeCalenderView", owner: self, options: nil)?.first as? EventTimeCalenderView
    
    lazy var catsAlertView = Bundle.main.loadNibNamed("CategoriesView", owner: self, options: nil)?.first as? CategoriesView
    
    var dayname = ""
    var monthname = ""
    var nday = ""
    var nyear = ""
    
    var startDate = ""
    var endDate = ""
    var startTime = ""
    var endTime = ""
    
    let imagePicker = UIImagePickerController()
    var attachedImg = false
    
    var viewmodel:AddEventViewModel = AddEventViewModel()
    var locationLat:Double = 0.0
    var locationLng:Double = 0.0
    var catsVM:AllCategoriesViewModel = AllCategoriesViewModel()
    var cats:[CategoryObj] = [CategoryObj]()
    var catID = ""
    var catName = ""
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Add Event".localizedString
        setupView()
        initBackButton()
        getCats()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupNavBar()
    }
    
    
    //MARK:- APIs
    func getCats() {
        catsVM.getAllCategories()
        catsVM.cats.bind { [unowned self] value in
            DispatchQueue.main.async {
                cats = value
            }
        }
        
        // Set View Model Event Listener
        catsVM.error.bind { [unowned self]error in
            DispatchQueue.main.async {
                self.hideLoading()
                self.showAlert(withMessage: error)
            }
        }
    }
    
    //MARK: - Actions
    @IBAction func addImgBtn(_ sender: Any) {
        self.eventImg.image = UIImage(named: "costa rica")
        self.attachedImg = true
        
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
    
    @IBAction func chooseCatBtn(_ sender: Any) {
        catsAlertView?.frame = CGRect(x: 0, y: -100, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        catsAlertView?.parentVC = self
        catsAlertView?.catsModel = cats
        catsAlertView?.tableViewHeight.constant = CGFloat(cats.count * 50)
        catsAlertView?.onCategoryCallBackResponse = OnCategoryCallBack
        self.view.addSubview((catsAlertView)!)
    }
    
    @IBAction func switchAllDaysBtn(_ sender: Any) {
    }
    
    @IBAction func startDayBtn(_ sender: Any) {
        dateAlertView?.frame = CGRect(x: 0, y: -100, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        self.dateAlertView?.calenderView.addTarget(self, action: #selector(self.dateChanged(_:)), for: .valueChanged)
        
        dateAlertView?.HandleOKBtn = {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE, MMM d,yyyy"
            self.startDayLbl.text = formatter.string(from: (self.dateAlertView?.calenderView.date)!)
            
            let formatter2 = DateFormatter()
            formatter2.dateFormat = "yyyy-MM-dd"
            self.startDate = formatter2.string(from: (self.dateAlertView?.calenderView.date)!)
            
            
            UIView.animate(withDuration: 0.3, animations: {
                self.dateAlertView?.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
                self.dateAlertView?.alpha = 0
            }) { (success: Bool) in
                self.dateAlertView?.removeFromSuperview()
                self.dateAlertView?.alpha = 1
                self.dateAlertView?.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            }
        }
        
        dateAlertView?.HandleCancelBtn = {
            // handling code
            UIView.animate(withDuration: 0.3, animations: {
                self.dateAlertView?.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
                self.dateAlertView?.alpha = 0
            }) { (success: Bool) in
                self.dateAlertView?.removeFromSuperview()
                self.dateAlertView?.alpha = 1
                self.dateAlertView?.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            }
        }
        
        self.view.addSubview((dateAlertView)!)
    }
    
    @IBAction func endDayBtn(_ sender: Any) {
        dateAlertView?.frame = CGRect(x: 0, y: -100, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        self.dateAlertView?.calenderView.addTarget(self, action: #selector(self.dateChanged(_:)), for: .valueChanged)
        
        dateAlertView?.HandleOKBtn = {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE, MMM d,yyyy"
            self.endDayLbl.text = formatter.string(from: (self.dateAlertView?.calenderView.date)!)
            
            let formatter2 = DateFormatter()
            formatter2.dateFormat = "yyyy-MM-dd"
            self.endDate = formatter2.string(from: (self.dateAlertView?.calenderView.date)!)
            
            UIView.animate(withDuration: 0.3, animations: {
                self.dateAlertView?.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
                self.dateAlertView?.alpha = 0
            }) { (success: Bool) in
                self.dateAlertView?.removeFromSuperview()
                self.dateAlertView?.alpha = 1
                self.dateAlertView?.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            }
        }
        
        dateAlertView?.HandleCancelBtn = {
            // handling code
            UIView.animate(withDuration: 0.3, animations: {
                self.dateAlertView?.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
                self.dateAlertView?.alpha = 0
            }) { (success: Bool) in
                self.dateAlertView?.removeFromSuperview()
                self.dateAlertView?.alpha = 1
                self.dateAlertView?.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            }
        }
        
        self.view.addSubview((dateAlertView)!)
    }
    
    
    @IBAction func startTimeBtn(_ sender: Any) {
        timeAlertView?.frame = CGRect(x: 0, y: -100, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        timeAlertView?.HandleOKBtn = {
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            self.startTimeLbl.text = formatter.string(from: (self.timeAlertView?.timeView.date)!)
            
            let formatter2 = DateFormatter()
            formatter2.dateFormat = "h:mm"
            self.startTime = formatter2.string(from: (self.timeAlertView?.timeView.date)!)
            
            UIView.animate(withDuration: 0.3, animations: {
                self.timeAlertView?.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
                self.timeAlertView?.alpha = 0
            }) { (success: Bool) in
                self.timeAlertView?.removeFromSuperview()
                self.timeAlertView?.alpha = 1
                self.timeAlertView?.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            }
        }
        
        timeAlertView?.HandleCancelBtn = {
            // handling code
            UIView.animate(withDuration: 0.3, animations: {
                self.timeAlertView?.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
                self.timeAlertView?.alpha = 0
            }) { (success: Bool) in
                self.timeAlertView?.removeFromSuperview()
                self.timeAlertView?.alpha = 1
                self.timeAlertView?.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            }
        }
        
        self.view.addSubview((timeAlertView)!)
    }
    
    @IBAction func endTimeBtn(_ sender: Any) {
        timeAlertView?.frame = CGRect(x: 0, y: -100, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        timeAlertView?.HandleOKBtn = {
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            self.endTimeLbl.text = formatter.string(from: (self.timeAlertView?.timeView.date)!)
            
            let formatter2 = DateFormatter()
            formatter2.dateFormat = "h:mm"
            self.endTime = formatter2.string(from: (self.timeAlertView?.timeView.date)!)
            
            UIView.animate(withDuration: 0.3, animations: {
                self.timeAlertView?.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
                self.timeAlertView?.alpha = 0
            }) { (success: Bool) in
                self.timeAlertView?.removeFromSuperview()
                self.timeAlertView?.alpha = 1
                self.timeAlertView?.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            }
        }
        
        timeAlertView?.HandleCancelBtn = {
            // handling code
            UIView.animate(withDuration: 0.3, animations: {
                self.timeAlertView?.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
                self.timeAlertView?.alpha = 0
            }) { (success: Bool) in
                self.timeAlertView?.removeFromSuperview()
                self.timeAlertView?.alpha = 1
                self.timeAlertView?.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            }
        }
        
        self.view.addSubview((timeAlertView)!)
    }
    
    @IBAction func saveBtn(_ sender: Any) {
        self.showLoading()
        viewmodel.addNewEvent(withTitle: addTitleTxt.text!, AndDescription: descriptionTxtView.text!, AndStatus: "creator", AndCategory: catID , lang: locationLng, lat: locationLat, totalnumbert: limitUsersTxt.text!, allday: switchAllDays.isOn, eventdateFrom: startDate, eventDateto: endDate , eventfrom: startTime, eventto: endTime, attachedImg: attachedImg, AndImage: eventImg.image ?? UIImage()) { error, data in
            self.hideLoading()
            if let error = error {
                self.showAlert(withMessage: error)
                return
            }
            
            guard let _ = data else {return}
            
            DispatchQueue.main.async {
                self.showAlert(withMessage: "Your event added successfully")
            }
            
            NotificationCenter.default.post(name: Notification.Name("refreshAllEvents"), object: nil, userInfo: nil)
        }
    }
    
    //MARK: - Helper
    func setupView() {
        eventImg.cornerRadiusView(radius: 6)
        saveBtn.cornerRadiusView(radius: 6)
        limitUsersView.cornerRadiusView(radius: 5)
        descriptionTxtView.cornerRadiusView(radius: 5)
        descriptionTxtView.delegate = self
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d,yyyy"
        self.startDayLbl.text = formatter.string(from: (self.dateAlertView?.calenderView.date)!)
        self.endDayLbl.text = formatter.string(from: (self.dateAlertView?.calenderView.date)!)
        
        let formattrTime = DateFormatter()
        formattrTime.dateFormat = "HH:mm a"
        self.startTimeLbl.text = formattrTime.string(from: (self.timeAlertView?.timeView.date)!)
        self.endTimeLbl.text = formattrTime.string(from: (self.timeAlertView?.timeView.date)!)
        
        //        if switchAllDays.isOn {
        ////            datesView.isHidden = true
        ////            datesViewHeight.constant = 0
        //            startDateBtn.isHidden = true
        //            endDateBtn.isHidden = true
        //            startTimeBtn.isHidden = true
        //            endTimeBtn.isHidden = true
        //        }else {
        ////            datesView.isHidden = false
        ////            datesViewHeight.constant = 70
        //            startDateBtn.isHidden = false
        //            endDateBtn.isHidden = false
        //            startTimeBtn.isHidden = false
        //            endTimeBtn.isHidden = false
        //        }
    }
    
    func OnCategoryCallBack(_ data: String, _ value: String) -> () {
        print(data, value)
        categoryLbl.text = value
        catID = data
        catName = value
    }
}

//MARK: - Extensions
extension AddEventVC : UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        hiddenLbl.isHidden = !textView.text.isEmpty
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (descriptionTxtView.text as NSString).replacingCharacters(in: range, with: text)
        return newText.count < 250
    }
}

extension AddEventVC {
    @objc func dateChanged(_ sender: UIDatePicker) {
        let components = Calendar.current.dateComponents([.year, .month, .weekday,.day], from: sender.date)
        if let weekday = components.weekday, let month = components.month, let year = components.year ,let day = components.day {
            print("\(day) \(weekday) \(month) \(year)")
            
            nday = "\(day)"
            nyear = "\(year)"
            
            switch weekday {
            case 1:
                dayname = "Sun"
                break
            case 2:
                dayname = "Mon"
                break
            case 3:
                dayname = "Tue"
                break
            case 4:
                dayname = "Wed"
                break
            case 5:
                dayname = "Thu"
                break
            case 6:
                dayname = "Fri"
                break
            case 7:
                dayname = "Sat"
                break
            default:
                break
            }
            
            switch month {
            case 1:
                monthname = "Jan"
                
                break
            case 2:
                monthname = "Feb"
                break
            case 3:
                monthname = "Mar"
                break
            case 4:
                monthname = "Apr"
                break
            case 5:
                monthname = "May"
                break
            case 6:
                monthname = "Jun"
                break
            case 7:
                monthname = "Jul"
                break
            case 8:
                monthname = "Aug"
                break
            case 9:
                monthname = "Sep"
                break
            case 10:
                monthname = "Oct"
                break
            case 11:
                monthname = "Nov"
                break
            case 12:
                monthname = "Dec"
                break
            default:
                break
            }
            
            dateAlertView?.dayLbl.text = dayname + ", " + monthname + " " + nday
            dateAlertView?.yearLbl.text = nyear
        }
    }
}

extension AddEventVC : UIImagePickerControllerDelegate,UINavigationControllerDelegate {
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
    //MARK:- Open Library
    func openLibrary(){
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image = info[.originalImage] as! UIImage
        picker.dismiss(animated:true, completion: {
            self.eventImg.image = image
            self.attachedImg = true
        })
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated:true, completion: nil)
    }
}
