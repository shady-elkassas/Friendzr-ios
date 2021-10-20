//
//  EditEventsVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 16/08/2021.
//

import UIKit

class EditEventsVC: UIViewController {
    
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
    @IBOutlet weak var datesView: UIView!
    @IBOutlet weak var datesViewHeight: NSLayoutConstraint!
    @IBOutlet weak var startDateBtn: UIButton!
    @IBOutlet weak var endDateBtn: UIButton!
    @IBOutlet weak var startTimeBtn: UIButton!
    @IBOutlet weak var endTimeBtn: UIButton!
    @IBOutlet weak var categoryNameLbl: UILabel!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var timeStack: UIStackView!
    
    
    //MARK: - Properties
    lazy var dateAlertView = Bundle.main.loadNibNamed("EventCalendarView", owner: self, options: nil)?.first as? EventCalendarView
    lazy var timeAlertView = Bundle.main.loadNibNamed("EventTimeCalenderView", owner: self, options: nil)?.first as? EventTimeCalenderView
    
    lazy var deleteAlertView = Bundle.main.loadNibNamed("BlockAlertView", owner: self, options: nil)?.first as? BlockAlertView

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
    var internetConect:Bool = false

    var eventImage:String = ""
    var eventModel:EventObj? = nil
    var viewmodel:EditEventViewModel = EditEventViewModel()
    var deleteEventVM:DeleteEventViewModel = DeleteEventViewModel()
    
    var minimumDate:Date = Date()
    var maximumDate:Date = Date()

    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Edit Event".localizedString
        setup()
        initBackButton()
        setupData()
        initDeleteEventButton(btnColor: .red)
        
        DispatchQueue.main.async {
            self.updateUserInterface()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupNavBar()
    }
    
    //MARK: - Helper
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
        self.view.makeToast("No avaliable newtwok ,Please try again!".localizedString)
    }
    
    func setup() {
        eventImg.cornerRadiusView(radius: 6)
        saveBtn.cornerRadiusView(radius: 6)
        limitUsersView.cornerRadiusView(radius: 5)
        descriptionTxtView.cornerRadiusView(radius: 5)
        descriptionTxtView.delegate = self
        switchAllDays.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
    }
    
    func initDeleteEventButton(btnColor: UIColor? = .red) {
        let button = UIButton.init(type: .custom)
        button.setTitle("Delete Event", for: .normal)
        button.setTitleColor(btnColor, for: .normal)
        button.titleLabel?.font = UIFont(name: "Montserrat-Medium", size: 12)
        button.addTarget(self, action:  #selector(handleDeleteEvent), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    @objc func handleDeleteEvent() {
        
        updateUserInterface()
        
        if internetConect == true {
            
            deleteAlertView?.frame = CGRect(x: 0, y: -100, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            
            deleteAlertView?.titleLbl.text = "Confirm?".localizedString
            deleteAlertView?.detailsLbl.text = "Are you sure you want to delete your event?".localizedString
            
            deleteAlertView?.HandleConfirmBtn = {
                self.showLoading()
                self.deleteEventVM.deleteEvent(ByEventid: self.eventModel?.id ?? "") { error, data in
                    self.hideLoading()
                    if let error = error {
                        self.showAlert(withMessage: error)
                        return
                    }
                    
                    guard let _ = data else {return}
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3 , execute: {
                        Router().toFeed()
                    })
                }
                
                // handling code
                UIView.animate(withDuration: 0.3, animations: {
                    self.deleteAlertView?.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
                    self.deleteAlertView?.alpha = 0
                }) { (success: Bool) in
                    self.deleteAlertView?.removeFromSuperview()
                    self.deleteAlertView?.alpha = 1
                    self.deleteAlertView?.transform = CGAffineTransform.init(scaleX: 1, y: 1)
                }
            }
            
            self.view.addSubview((deleteAlertView)!)
        }else {
            return
        }
    }
    
    func setupData() {
        eventImg.sd_setImage(with: URL(string: eventModel?.image ?? "" ), placeholderImage: UIImage(named: "placeholder"))
        categoryNameLbl.text = eventModel?.categorie
        addTitleTxt.text = eventModel?.title
        
        if eventModel?.allday == true {
            switchAllDays.isOn = true
            timeStack.isHidden = true
        }else {
            switchAllDays.isOn = false
            timeStack.isHidden = false
        }
        
        startDayLbl.text = eventModel?.eventdate
        endDayLbl.text = eventModel?.eventdateto
        startTimeLbl.text = eventModel?.timefrom
        endTimeLbl.text = eventModel?.timeto
        
        if eventModel?.descriptionEvent == "" {
            hiddenLbl.isHidden = false
        }else {
            descriptionTxtView.text = eventModel?.descriptionEvent
            hiddenLbl.isHidden = true
        }
        
        limitUsersTxt.text = "\(eventModel?.totalnumbert ?? 0)"

        startDate = eventModel?.eventdate ?? ""
        endDate = eventModel?.eventdateto ?? ""
        startTime = eventModel?.timefrom ?? ""
        endTime = eventModel?.timeto ?? ""
    }
    
    //MARK: - Actions
    
    @IBAction func saveBtn(_ sender: Any) {
        updateUserInterface()
        if internetConect == true {
            self.showLoading()
            viewmodel.editEvent(withID: "\(eventModel?.id ?? "")", AndTitle: addTitleTxt.text!, AndDescription: descriptionTxtView.text!, AndStatus: "creator", AndCategory: "\(1)" , lang: eventModel?.lang ?? "", lat: eventModel?.lat ?? "", totalnumbert: limitUsersTxt.text!, allday: switchAllDays.isOn, eventdateFrom: startDate, eventDateto: endDate, eventfrom: startTime, eventto: endTime,attachedImg: self.attachedImg,AndImage: eventImg.image!) { error, data in
                
                self.hideLoading()
                if let error = error {
                    self.showAlert(withMessage: error)
                    return
                }
                
                guard let _ = data else {return}
                self.showAlert(withMessage: "Edit Save successfully")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.onPopup()
                }
                
//                NotificationCenter.default.post(name: Notification.Name("refreshAllEvents"), object: nil, userInfo: nil)
            }
        }else {
            return
        }
    }
    
    @IBAction func addImgBtn(_ sender: Any) {
        if UIDevice.current.userInterfaceIdiom == .pad {
            let settingsActionSheet: UIAlertController = UIAlertController(title:nil, message:nil, preferredStyle: .alert)
            
            settingsActionSheet.addAction(UIAlertAction(title:"Camera".localizedString, style:UIAlertAction.Style.default, handler:{ action in
                self.openCamera()
            }))
            settingsActionSheet.addAction(UIAlertAction(title:"Photo Liberary".localizedString, style:UIAlertAction.Style.default, handler:{ action in
                self.openLibrary()
            }))
            settingsActionSheet.addAction(UIAlertAction(title:"Cancel".localizedString, style:UIAlertAction.Style.cancel, handler:nil))
            
            present(settingsActionSheet, animated:true, completion:nil)
            
        }else {
            let settingsActionSheet: UIAlertController = UIAlertController(title:nil, message:nil, preferredStyle:UIAlertController.Style.actionSheet)
            
            settingsActionSheet.addAction(UIAlertAction(title:"Camera".localizedString, style:UIAlertAction.Style.default, handler:{ action in
                self.openCamera()
            }))
            settingsActionSheet.addAction(UIAlertAction(title:"Photo Liberary".localizedString, style:UIAlertAction.Style.default, handler:{ action in
                self.openLibrary()
            }))
            settingsActionSheet.addAction(UIAlertAction(title:"Cancel".localizedString, style:UIAlertAction.Style.cancel, handler:nil))
            
            present(settingsActionSheet, animated:true, completion:nil)
        }
        
//        self.eventImg.image = UIImage(named: "bolivia")
//        self.attachedImg = true
    }
    
    @IBAction func switchAllDaysBtn(_ sender: Any) {
        if switchAllDays.isOn == true {
            timeStack.isHidden = true
        }else {
            timeStack.isHidden = false
        }
    }
    
    @IBAction func startDayBtn(_ sender: Any) {
        dateAlertView?.frame = CGRect(x: 0, y: -100, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        self.dateAlertView?.calenderView.addTarget(self, action: #selector(self.dateChanged(_:)), for: .valueChanged)
        
        dateAlertView?.HandleOKBtn = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            self.startDayLbl.text = formatter.string(from: (self.dateAlertView?.calenderView.date)!)
            
            let formatter2 = DateFormatter()
            formatter2.dateFormat = "yyyy-MM-dd"
            self.startDate = formatter2.string(from: (self.dateAlertView?.calenderView.date)!)
            
            
            var comps2:DateComponents = DateComponents()
            comps2.month = 1
            comps2.day = -1
            
            self.minimumDate = (self.dateAlertView?.calenderView.date)!
            self.maximumDate = (self.dateAlertView?.calenderView.calendar.date(byAdding: comps2, to: self.minimumDate))!
            
            print(formatter2.string(from: self.minimumDate),formatter2.string(from: self.maximumDate))

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
        
        self.dateAlertView?.calenderView.maximumDate = self.maximumDate
        
        dateAlertView?.HandleOKBtn = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
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
        
        var comps2:DateComponents = DateComponents()
        comps2.day = -1

        self.timeAlertView?.timeView.minimumDate = self.timeAlertView?.timeView.calendar.date(from: comps2)
        
        timeAlertView?.HandleOKBtn = {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            self.startTimeLbl.text = formatter.string(from: (self.timeAlertView?.timeView.date)!)
            
            let formatter2 = DateFormatter()
            formatter2.dateFormat = "HH:mm"
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
        
        var comps2:DateComponents = DateComponents()
        comps2.day = -1
        self.timeAlertView?.timeView.minimumDate = self.timeAlertView?.timeView.calendar.date(from: comps2)

        timeAlertView?.HandleOKBtn = {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            self.endTimeLbl.text = formatter.string(from: (self.timeAlertView?.timeView.date)!)
            
            let formatter2 = DateFormatter()
            formatter2.dateFormat = "HH:mm"
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
    
    @IBAction func attendeesBtn(_ sender: Any) {
        guard let vc = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "AttendeesVC") as? AttendeesVC else {return}
        vc.eventID = eventModel?.id ?? ""
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func tryAgainBtn(_ sender: Any) {
        updateUserInterface()
    }
}


//MARK: - Extensions
extension EditEventsVC : UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        hiddenLbl.isHidden = !textView.text.isEmpty
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (descriptionTxtView.text as NSString).replacingCharacters(in: range, with: text)
        return newText.count < 250
    }
}

extension EditEventsVC {
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

extension EditEventsVC : UIImagePickerControllerDelegate,UINavigationControllerDelegate {
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
            self.eventImg.image = image
            self.attachedImg = true
        })
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated:true, completion: nil)
    }
}
