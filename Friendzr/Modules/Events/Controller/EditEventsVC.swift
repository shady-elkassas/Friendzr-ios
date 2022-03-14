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
//    @IBOutlet weak var timeStack: UIStackView!
    
    @IBOutlet weak var timesview: UIView!
    @IBOutlet weak var attendeesView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var attendeesViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var hideTypesView: UIView!
    @IBOutlet weak var eventTypeLbl: UILabel!
    @IBOutlet weak var selectFriendsView: UIView!
    @IBOutlet weak var selectFriendsTopView: UIView!
    @IBOutlet weak var selectFriendsViewHeight: NSLayoutConstraint!
    @IBOutlet weak var topFriendsViewLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomFriendsViewLayoutConstaint: NSLayoutConstraint!
    @IBOutlet weak var eventTypesView: UIView!
    @IBOutlet weak var eventTypesTV: UITableView!

    
    //MARK: - Properties
    lazy var dateAlertView = Bundle.main.loadNibNamed("EventCalendarView", owner: self, options: nil)?.first as? EventCalendarView
    lazy var timeAlertView = Bundle.main.loadNibNamed("EventTimeCalenderView", owner: self, options: nil)?.first as? EventTimeCalenderView
    
    lazy var deleteAlertView = Bundle.main.loadNibNamed("BlockAlertView", owner: self, options: nil)?.first as? BlockAlertView
    
    let attendeesCellID = "AttendeesTableViewCell"
    let footerCellID = "SeeMoreTableViewCell"
    let eventTypeCellId = "ProblemTableViewCell"

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
    
    var eventTypeID = ""
    var eventTypeName = ""

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
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        hideTypesView?.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Defaults.availableVC = "EditEventsVC"
        print("availableVC >> \(Defaults.availableVC)")

        CancelRequest.currentTask = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
//        self.hideLoading()
        CancelRequest.currentTask = true
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
        self.view.makeToast("Network is unavailable, please try again!".localizedString)
    }
    
    func setup() {
        eventImg.cornerRadiusView(radius: 6)
        saveBtn.cornerRadiusView(radius: 6)
        limitUsersView.cornerRadiusView(radius: 5)
        descriptionTxtView.cornerRadiusView(radius: 5)
        descriptionTxtView.delegate = self
        switchAllDays.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        tableView.register(UINib(nibName: attendeesCellID, bundle: nil), forCellReuseIdentifier: attendeesCellID)
        tableView.register(UINib(nibName: footerCellID, bundle: nil), forHeaderFooterViewReuseIdentifier: footerCellID)
        
        eventTypesView.setCornerforTop( withShadow: false, cornerMask: [.layerMaxXMinYCorner, .layerMinXMinYCorner], radius: 21)
        eventTypesTV.register(UINib(nibName: eventTypeCellId, bundle: nil), forCellReuseIdentifier: eventTypeCellId)
    }
    
    func initDeleteEventButton(btnColor: UIColor? = .red) {
        let button = UIButton.init(type: .custom)
        button.setTitle("Delete Event".localizedString, for: .normal)
        button.setTitleColor(btnColor, for: .normal)
        button.titleLabel?.font = UIFont(name: "Montserrat-Medium", size: 12)
        button.addTarget(self, action:  #selector(handleDeleteEvent), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    @objc func handleDeleteEvent() {
        
        updateUserInterface()
        
        if internetConect == true {
            
            deleteAlertView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            
            deleteAlertView?.titleLbl.text = "Confirm?".localizedString
            deleteAlertView?.detailsLbl.text = "Are you sure you want to delete your event?".localizedString
            
            deleteAlertView?.HandleConfirmBtn = {
                self.deleteEventVM.deleteEvent(ByEventid: self.eventModel?.id ?? "") { error, data in
                    if let error = error {
                        DispatchQueue.main.async {
                            self.view.makeToast(error)
                        }
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
        eventImg.sd_setImage(with: URL(string: eventModel?.image ?? "" ), placeholderImage: UIImage(named: "placeHolderApp"))
        categoryNameLbl.text = eventModel?.categorie
        addTitleTxt.text = eventModel?.title
        
        if eventModel?.allday == false {
            switchAllDays.isOn = false
            timesview.isHidden = false
            startTimeBtn.isHidden = false
            endTimeBtn.isHidden = false
        }else {
            switchAllDays.isOn = true
            timesview.isHidden = true
            startTimeBtn.isHidden = true
            endTimeBtn.isHidden = true
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
        
        
        if eventModel?.attendees?.count == 0 {
            attendeesViewHeight.constant = 0
        }else if eventModel?.attendees?.count == 1 {
            attendeesViewHeight.constant = CGFloat(60)
        }else if eventModel?.attendees?.count == 2 {
            attendeesViewHeight.constant = CGFloat(160)
        }else {
            attendeesViewHeight.constant = CGFloat(220)
        }
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        hideTypesView.isHidden = true
        eventTypesView.isHidden = true
    }

    func onStartDateCallBack(_ dayDate: String, _ date: String,_ minimumDate:Date,_ maximumDate:Date) -> () {
        self.startDayLbl.text = dayDate
        self.startDate = date
        self.minimumDate = minimumDate
        self.maximumDate = maximumDate
    }
    
    func onEndDateCallBack(_ dayDate: String, _ date: String,_ minimumDate:Date,_ maximumDate:Date) -> () {
        self.endDayLbl.text = dayDate
        self.endDate = date
    }
    
    func onStartTimeCallBack(_ timeDateLbl: String, _ timeDate: String) -> () {
        self.startTimeLbl.text = timeDateLbl
        self.startTime = timeDate
    }
    
    func onEndTimeCallBack(_ timeDateLbl: String, _ timeDate: String) -> () {
        self.endTimeLbl.text = timeDateLbl
        self.endTime = timeDate
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    //MARK: - Actions
    
    @IBAction func selectEventTypeBtn(_ sender: Any) {
        hideTypesView.isHidden = false
        eventTypesView.isHidden = false
    }
    
    @IBAction func selectEventAttendeesBtn(_ sender: Any) {
        if let controller = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "SelectFriendsNC") as? UINavigationController, let _ = controller.viewControllers.first as? SelectFriendsVC {
            self.present(controller, animated: true)
        }
    }
    
    @IBAction func saveBtn(_ sender: Any) {
        updateUserInterface()
        if internetConect == true {
            self.saveBtn.setTitle("Saving...", for: .normal)
            self.saveBtn.isUserInteractionEnabled = false
            viewmodel.editEvent(withID: "\(eventModel?.id ?? "")", AndTitle: addTitleTxt.text!, AndDescription: descriptionTxtView.text!, AndStatus: "creator", AndCategory: "\(1)" , lang: eventModel?.lang ?? "", lat: eventModel?.lat ?? "", totalnumbert: limitUsersTxt.text!, allday: switchAllDays.isOn, eventdateFrom: startDate, eventDateto: endDate, eventfrom: startTime, eventto: endTime,attachedImg: self.attachedImg,AndImage: eventImg.image!) { error, data in
                
                if let error = error {
                    DispatchQueue.main.async {
                        self.view.makeToast(error)
                    }
                    return
                }
                
                guard let _ = data else {return}
                
                DispatchQueue.main.async {
                    self.saveBtn.setTitle("Save", for: .normal)
                    self.saveBtn.isUserInteractionEnabled = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.onPopup()
                }
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
            settingsActionSheet.addAction(UIAlertAction(title:"Photo Library".localizedString, style:UIAlertAction.Style.default, handler:{ action in
                self.openLibrary()
            }))
            settingsActionSheet.addAction(UIAlertAction(title:"Cancel".localizedString, style:UIAlertAction.Style.cancel, handler:nil))
            
            present(settingsActionSheet, animated:true, completion:nil)
            
        }else {
            let settingsActionSheet: UIAlertController = UIAlertController(title:nil, message:nil, preferredStyle:UIAlertController.Style.actionSheet)
            
            settingsActionSheet.addAction(UIAlertAction(title:"Camera".localizedString, style:UIAlertAction.Style.default, handler:{ action in
                self.openCamera()
            }))
            settingsActionSheet.addAction(UIAlertAction(title:"Photo Library".localizedString, style:UIAlertAction.Style.default, handler:{ action in
                self.openLibrary()
            }))
            settingsActionSheet.addAction(UIAlertAction(title:"Cancel".localizedString, style:UIAlertAction.Style.cancel, handler:nil))
            
            present(settingsActionSheet, animated:true, completion:nil)
        }
    }
    
    @IBAction func switchBtn(_ sender: UISwitch) {
        
        if switchAllDays.isOn == false {
            timesview.isHidden = false
            startTimeBtn.isHidden = false
            endTimeBtn.isHidden = false
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            self.startDayLbl.text = formatter.string(from: (self.dateAlertView?.calenderView.date)!)
            self.endDayLbl.text = formatter.string(from: (self.dateAlertView?.calenderView.date)!)
            
            let formattrTime = DateFormatter()
            formattrTime.dateFormat = "HH:mm"
            self.startTimeLbl.text = formattrTime.string(from: (self.timeAlertView?.timeView.date)!)
            self.endTimeLbl.text = formattrTime.string(from: (self.timeAlertView?.timeView.date)!)
        }else {
            timesview.isHidden = true
            startTimeBtn.isHidden = true
            endTimeBtn.isHidden = true
        }
    }
    
    @IBAction func startDayBtn(_ sender: Any) {
        guard let popupVC = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "EventCalendarVC") as? EventCalendarVC else {return}
        popupVC.modalPresentationStyle = .overCurrentContext
        popupVC.modalTransitionStyle = .crossDissolve
        let pVC = popupVC.popoverPresentationController
        pVC?.permittedArrowDirections = .any
        pVC?.delegate = self
        pVC?.sourceRect = CGRect(x: 100, y: 100, width: 1, height: 1)
        popupVC.eventModel = eventModel
        popupVC.onDateCallBackResponse = self.onStartDateCallBack
        present(popupVC, animated: true, completion: nil)
    }
    
    @IBAction func endDayBtn(_ sender: Any) {
        guard let popupVC = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "EventCalendarVC") as? EventCalendarVC else {return}
        popupVC.modalPresentationStyle = .overCurrentContext
        popupVC.modalTransitionStyle = .crossDissolve
        let pVC = popupVC.popoverPresentationController
        pVC?.permittedArrowDirections = .any
        pVC?.delegate = self
        pVC?.sourceRect = CGRect(x: 100, y: 100, width: 1, height: 1)
        popupVC.onDateCallBackResponse = self.onEndDateCallBack
        present(popupVC, animated: true, completion: nil)

    }

    @IBAction func startTimeBtn(_ sender: Any) {
        guard let popupVC = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "EventTimeVC") as? EventTimeVC else {return}
        popupVC.modalPresentationStyle = .overCurrentContext
        popupVC.modalTransitionStyle = .crossDissolve
        let pVC = popupVC.popoverPresentationController
        pVC?.permittedArrowDirections = .any
        pVC?.delegate = self
        pVC?.sourceRect = CGRect(x: 100, y: 100, width: 1, height: 1)
        popupVC.onTimeCallBackResponse = self.onStartTimeCallBack
        present(popupVC, animated: true, completion: nil)

    }
    
    @IBAction func endTimeBtn(_ sender: Any) {
        guard let popupVC = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "EventTimeVC") as? EventTimeVC else {return}
        popupVC.modalPresentationStyle = .overCurrentContext
        popupVC.modalTransitionStyle = .crossDissolve
        let pVC = popupVC.popoverPresentationController
        pVC?.permittedArrowDirections = .any
        pVC?.delegate = self
        pVC?.sourceRect = CGRect(x: 100, y: 100, width: 1, height: 1)
        popupVC.onTimeCallBackResponse = self.onEndTimeCallBack
        present(popupVC, animated: true, completion: nil)

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
        return newText.count < 150
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
                dayname = "Sun".localizedString
                break
            case 2:
                dayname = "Mon".localizedString
                break
            case 3:
                dayname = "Tue".localizedString
                break
            case 4:
                dayname = "Wed".localizedString
                break
            case 5:
                dayname = "Thu".localizedString
                break
            case 6:
                dayname = "Fri".localizedString
                break
            case 7:
                dayname = "Sat".localizedString
                break
            default:
                break
            }
            
            switch month {
            case 1:
                monthname = "Jan".localizedString
                
                break
            case 2:
                monthname = "Feb".localizedString
                break
            case 3:
                monthname = "Mar".localizedString
                break
            case 4:
                monthname = "Apr".localizedString
                break
            case 5:
                monthname = "May".localizedString
                break
            case 6:
                monthname = "Jun".localizedString
                break
            case 7:
                monthname = "Jul".localizedString
                break
            case 8:
                monthname = "Aug".localizedString
                break
            case 9:
                monthname = "Sep".localizedString
                break
            case 10:
                monthname = "Oct".localizedString
                break
            case 11:
                monthname = "Nov".localizedString
                break
            case 12:
                monthname = "Dec".localizedString
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
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        picker.dismiss(animated:true, completion: {
            let size = CGSize(width: screenW, height: screenW)
            let img = image.crop(to: size)
            self.eventImg.image = img
            self.attachedImg = true
        })
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated:true, completion: nil)
    }
}

extension EditEventsVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == eventTypesTV {
            return 2
        }
        else {
            return eventModel?.attendees?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == eventTypesTV {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: eventTypeCellId, for: indexPath) as? ProblemTableViewCell else {return UITableViewCell()}
            if indexPath.row == 0 {
                cell.titleLbl.text = "Friendzr Event"
            }else {
                cell.titleLbl.text = "Private Event"
                cell.bottomView.isHidden = true
            }
            return cell
        }
        else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: attendeesCellID, for: indexPath) as? AttendeesTableViewCell else {return UITableViewCell()}
            let model = eventModel?.attendees?[indexPath.row]
            cell.dropDownBtn.isHidden = true
            cell.joinDateLbl.isHidden = true
            cell.friendNameLbl.text = model?.userName
            cell.friendImg.sd_setImage(with: URL(string: model?.image ?? "" ), placeholderImage: UIImage(named: "placeHolderApp"))
            
            if indexPath.row == (eventModel?.attendees?.count ?? 0) - 1 {
                cell.underView.isHidden = true
            }else {
                cell.underView.isHidden = false
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if tableView == eventTypesTV {
            return UIView()
        }
        else {
            guard let footerView = Bundle.main.loadNibNamed(footerCellID, owner: self, options: nil)?.first as? SeeMoreTableViewCell else { return UIView()}
            
            footerView.HandleSeeMoreBtn = {
                guard let vc = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "AttendeesVC") as? AttendeesVC else {return}
                vc.eventID = self.eventModel?.id ?? ""
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
            return footerView
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if tableView == eventTypesTV {
            return 0
        }
        else {
            if (eventModel?.attendees?.count ?? 0) > 1 {
                return 40
            }else {
                return 0
            }
        }
    }
}


extension EditEventsVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == eventTypesTV {
            return 50
        }else {
            return 60
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == eventTypesTV {
            if indexPath.row == 0 {
                eventTypeLbl.text = "Friendzr Event"
                eventTypeName = "Friendzr Event"
                selectFriendsView.isHidden = true
                topFriendsViewLayoutConstraint.constant = 0
                bottomFriendsViewLayoutConstaint.constant = 0
                selectFriendsViewHeight.constant = 0
                selectFriendsTopView.isHidden = true
            }else {
                eventTypeLbl.text = "Private Event"
                eventTypeName = "Private Event"
                selectFriendsView.isHidden = false
                topFriendsViewLayoutConstraint.constant = 10
                bottomFriendsViewLayoutConstaint.constant = 10
                selectFriendsViewHeight.constant = 40
                selectFriendsTopView.isHidden = false
            }
            
            hideTypesView.isHidden = true
            eventTypesView.isHidden = true
        }
        else {
            let model = eventModel?.attendees?[indexPath.row]
            
            if model?.myEventO == true {
                guard let vc = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "MyProfileViewController") as? MyProfileViewController else {return}
                self.navigationController?.pushViewController(vc, animated: true)
            }else {
                guard let vc = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "FriendProfileViewController") as? FriendProfileViewController else {return}
                vc.userID = model?.userId ?? ""
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}

extension EditEventsVC : UIPopoverPresentationControllerDelegate{
    
}
