//
//  AddEventVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 17/08/2021.
//

import Foundation
import UIKit
import QCropper
import Network

class AddEventVC: UIViewController {
    
    //MARK:- Outlets
    @IBOutlet weak var eventImg: UIImageView!
    @IBOutlet weak var addImg: UIButton!
    @IBOutlet weak var addTitleTxt: UITextField!
    @IBOutlet weak var switchAllDays: UISwitch!
    //    @IBOutlet weak var startDayLbl: UILabel!
    //    @IBOutlet weak var endDayLbl: UILabel!
    //    @IBOutlet weak var startTimeLbl: UILabel!
    //    @IBOutlet weak var endTimeLbl: UILabel!
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
    @IBOutlet weak var timeView: UIView!
    @IBOutlet weak var categoriesSuperView: UIView!
    @IBOutlet weak var categoriesView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var saveCategoryBtn: UIButton!
    @IBOutlet weak var hideView: UIView!
    
    @IBOutlet weak var eventTypeLbl: UILabel!
    @IBOutlet weak var selectFriendsView: UIView!
    @IBOutlet weak var selectFriendsTopView: UIView!
    @IBOutlet weak var selectFriendsViewHeight: NSLayoutConstraint!
    @IBOutlet weak var selectFirendsBtn: UIButton!
    @IBOutlet weak var topFriendsViewLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomFriendsViewLayoutConstaint: NSLayoutConstraint!
    
    @IBOutlet weak var showAttendeesViewHeight: NSLayoutConstraint!
    @IBOutlet weak var showAttendeesBtn: UIButton!
    @IBOutlet weak var showAttendeesFriendsTopView: UIView!
    @IBOutlet weak var topShowAttendeesViewLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomShowAttendeesViewLayoutConstaint: NSLayoutConstraint!
    
    @IBOutlet weak var showAttendeesTopView: UIView!
    @IBOutlet weak var eventTypesView: UIView!
    @IBOutlet weak var eventTypesTV: UITableView!
    //    @IBOutlet weak var saveEventTypeBtn: UIButton!
    
    
    @IBOutlet weak var selectStartDateTxt: UITextField!
    @IBOutlet weak var selectEndDateTxt: UITextField!
    @IBOutlet weak var selectStartTimeTxt: UITextField!
    @IBOutlet weak var selectEndTimeTxt: UITextField!
    
    //MARK: - Properties
    lazy var dateAlertView = Bundle.main.loadNibNamed("EventCalendarView", owner: self, options: nil)?.first as? EventCalendarView
    lazy var timeAlertView = Bundle.main.loadNibNamed("EventTimeCalenderView", owner: self, options: nil)?.first as? EventTimeCalenderView
    
    private var layout: UICollectionViewFlowLayout!
    
    var dayname = ""
    var monthname = ""
    var nday = ""
    var nyear = ""
    
    var startDate = ""
    var endDate = ""
    var startTime = ""
    var endTime = ""
    
    var minimumDate:Date = Date()
    var maximumDate:Date = Date()
    
    let imagePicker = UIImagePickerController()
    var attachedImg = false
    
    var viewmodel:AddEventViewModel = AddEventViewModel()
    var locationLat:Double = 0.0
    var locationLng:Double = 0.0
    
    let cellId = "CategoryCollectionViewCell"
    let eventTypeCellId = "ProblemTableViewCell"
    var catsVM:AllCategoriesViewModel = AllCategoriesViewModel()
    var typesVM:EventTypeViewModel = EventTypeViewModel()
    var allValidatConfigVM:AllValidatConfigViewModel = AllValidatConfigViewModel()

    var catID = ""
    var catselectedID:String = ""
    var catSelectedName:String = ""
    var listFriendsIDs:[String] = [String]()
    
    var eventTypeID = ""
    var eventTypeName = ""
    
    var internetConect:Bool = false
    
    let datePicker1 = UIDatePicker()
    let datePicker2 = UIDatePicker()
    let timePicker1 = UIDatePicker()
    let timePicker2 = UIDatePicker()
    
    
    var showAttendeesForAll:Bool = false
    
    private let formatterDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    private let formatterTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Add Event".localizedString
        setupView()
        initBackButton()
        
        DispatchQueue.main.async {
            self.updateUserInterface()
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        categoriesSuperView?.addGestureRecognizer(tap)
        
        //        setupDatePickerForEndDate()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Defaults.availableVC = "AddEventVC"
        print("availableVC >> \(Defaults.availableVC)")
        
        hideNavigationBar(NavigationBar: false, BackButton: false)
        CancelRequest.currentTask = false
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.hideLoading()
        CancelRequest.currentTask = true
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        self.categoriesSuperView.isHidden = true
        categoriesView.isHidden = true
        eventTypesView.isHidden = true
    }
    
    //MARK: - APIs
    func getCats() {
        hideView.isHidden = false
        catsVM.getAllCategories()
        catsVM.cats.bind { [unowned self] value in
            DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.2) {
                self.hideView.isHidden = true
                self.collectionView.dataSource = self
                self.collectionView.delegate = self
                self.collectionView.reloadData()
                
                self.layout = TagsLayout()
            }
        }
        
        // Set View Model Event Listener
        catsVM.error.bind { [unowned self]error in
            DispatchQueue.main.async {
                DispatchQueue.main.async {
                    self.view.makeToast(error)
                }
                
            }
        }
    }
    
    func getEventTypes() {
        hideView.isHidden = false
        typesVM.getAllEventType()
        typesVM.types.bind { [unowned self] value in
            DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.2) {
                self.hideView.isHidden = true
                self.eventTypesTV.dataSource = self
                self.eventTypesTV.delegate = self
                self.eventTypesTV.reloadData()
            }
        }
        
        // Set View Model Event Listener
        typesVM.error.bind { [unowned self]error in
            DispatchQueue.main.async {
                DispatchQueue.main.async {
                    self.view.makeToast(error)
                }
                
            }
        }
    }
    
    //MARK: - Actions
    
    @IBAction func showAttendeesAllBtn(_ sender: Any) {
        showAttendeesBtn.isSelected = !showAttendeesBtn.isSelected
        
        if showAttendeesBtn.isSelected {
            showAttendeesForAll = true
        }else {
            showAttendeesForAll = false
        }
        
        print("showAttendeesForAll >>> \(showAttendeesForAll)")
    }
    
    @IBAction func addImgBtn(_ sender: Any) {
        if UIDevice.current.userInterfaceIdiom == .pad {
            let settingsActionSheet: UIAlertController = UIAlertController(title:nil, message:nil, preferredStyle: .alert)
            
            let cameraBtn = UIAlertAction(title: "Camera", style: .default) {_ in
                self.openCamera()
            }
            let libraryBtn = UIAlertAction(title: "Photo Library", style: .default) {_ in
                self.openLibrary()
            }
            
            let cancelBtn = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            cameraBtn.setValue(UIColor.FriendzrColors.primary, forKey: "titleTextColor")
            libraryBtn.setValue(UIColor.FriendzrColors.primary, forKey: "titleTextColor")
            cancelBtn.setValue(UIColor.red, forKey: "titleTextColor")
            
            settingsActionSheet.addAction(cameraBtn)
            settingsActionSheet.addAction(libraryBtn)
            settingsActionSheet.addAction(cancelBtn)
            
            present(settingsActionSheet, animated:true, completion:nil)
            
        }else {
            let settingsActionSheet: UIAlertController = UIAlertController(title:nil, message:nil, preferredStyle:UIAlertController.Style.actionSheet)
            
            let cameraBtn = UIAlertAction(title: "Camera", style: .default) {_ in
                self.openCamera()
            }
            let libraryBtn = UIAlertAction(title: "Photo Library", style: .default) {_ in
                self.openLibrary()
            }
            
            let cancelBtn = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            cameraBtn.setValue(UIColor.FriendzrColors.primary, forKey: "titleTextColor")
            libraryBtn.setValue(UIColor.FriendzrColors.primary, forKey: "titleTextColor")
            cancelBtn.setValue(UIColor.red, forKey: "titleTextColor")
            
            settingsActionSheet.addAction(cameraBtn)
            settingsActionSheet.addAction(libraryBtn)
            settingsActionSheet.addAction(cancelBtn)
            
            present(settingsActionSheet, animated: true, completion: nil)
        }
    }
    
    @IBAction func selectEventTypeBtn(_ sender: Any) {
        DispatchQueue.main.async {
            self.categoriesSuperView.isHidden = false
            self.eventTypesView.isHidden = false
        }
    }
    
    @IBAction func selectFriendsBtn(_ sender: Any) {
        if let controller = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "SelectFriendsNC") as? UINavigationController, let vc = controller.viewControllers.first as? SelectFriendsVC {
            vc.selectedIDs = self.listFriendsIDs
            vc.selectedFriends = self.selectFriends
            vc.selectedNames = self.listNamesSelected
            vc.onListFriendsCallBackResponse = self.onListFriendsCallBack
            self.present(controller, animated: true)
        }
    }
    
    //    @IBAction func saveEventTypeBtn(_ sender: Any) {
    //        eventTypeLbl.text = eventTypeName
    //        categoriesSuperView.isHidden = true
    //        eventTypesView.isHidden = true
    //    }
    
    @IBAction func saveCategoryBtn(_ sender: Any) {
        categoryLbl.text = catSelectedName
        catID = catselectedID
        categoriesSuperView.isHidden = true
        categoriesView.isHidden = true
    }
    
    @IBAction func chooseCatBtn(_ sender: Any) {
        categoriesSuperView.isHidden = false
        categoriesView.isHidden = false
    }
    
    @IBAction func switchAllDaysBtn(_ sender: Any) {
        if switchAllDays.isOn == true {
            timeView.isHidden = true
            startTimeBtn.isHidden = true
            endTimeBtn.isHidden = true
        }else {
            timeView.isHidden = false
            startTimeBtn.isHidden = false
            endTimeBtn.isHidden = false
        }
    }
    
    @IBAction func startDayBtn(_ sender: Any) {
        dateAlertView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        self.dateAlertView?.calenderView.addTarget(self, action: #selector(self.dateChanged(_:)), for: .valueChanged)
        
        dateAlertView?.HandleOKBtn = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            //            self.startDayLbl.text = formatter.string(from: (self.dateAlertView?.calenderView.date)!)
            
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
        dateAlertView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        self.dateAlertView?.calenderView.addTarget(self, action: #selector(self.dateChanged(_:)), for: .valueChanged)
        
        self.dateAlertView?.calenderView.maximumDate = self.maximumDate
        
        dateAlertView?.HandleOKBtn = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            //            self.endDayLbl.text = formatter.string(from: (self.dateAlertView?.calenderView.date)!)
            
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
        timeAlertView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        var comps2:DateComponents = DateComponents()
        comps2.day = -1
        
        self.timeAlertView?.timeView.minimumDate = self.timeAlertView?.timeView.calendar.date(from: comps2)
        
        timeAlertView?.HandleOKBtn = {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            //            self.startTimeLbl.text = formatter.string(from: (self.timeAlertView?.timeView.date)!)
            
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
        timeAlertView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        var comps2:DateComponents = DateComponents()
        comps2.day = -1
        
        self.timeAlertView?.timeView.minimumDate = self.timeAlertView?.timeView.calendar.date(from: comps2)
        
        timeAlertView?.HandleOKBtn = {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            //            self.endTimeLbl.text = formatter.string(from: (self.timeAlertView?.timeView.date)!)
            
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
    
    @IBAction func saveBtn(_ sender: Any) {
        
        let eventDate = self.formatterDate.string(from: Date())
        let eventTime = self.formatterTime.string(from: Date())

        if internetConect == true {
            if attachedImg == false {
                DispatchQueue.main.async {
                    self.view.makeToast("Please add image to the event".localizedString)
                }
            }
            else if eventTypeID == "" {
                DispatchQueue.main.async {
                    self.view.makeToast("Please select the type of event first".localizedString)
                }
            }
            else if eventTypeName == "Private" && listFriendsIDs.count == 0 {
                DispatchQueue.main.async {
                    self.view.makeToast("This is the event private, please select friends for it".localizedString)
                }
            }
            else {
                self.saveBtn.setTitle("Saving...", for: .normal)
                self.saveBtn.isUserInteractionEnabled = false
                viewmodel.addNewEvent(withTitle: addTitleTxt.text!, AndDescription: descriptionTxtView.text!, AndStatus: "creator", AndCategory: catID , lang: locationLng, lat: locationLat, totalnumbert: limitUsersTxt.text!, allday: switchAllDays.isOn, eventdateFrom: startDate, eventDateto: endDate , eventfrom: startTime, eventto: endTime,creatDate: eventDate,creattime: eventTime, eventTypeName: eventTypeName,eventtype:eventTypeID, showAttendees: showAttendeesForAll,listOfUserIDs:listFriendsIDs, attachedImg: attachedImg, AndImage: eventImg.image ?? UIImage()) { error, data in
                    
                    DispatchQueue.main.async {
                        self.saveBtn.isUserInteractionEnabled = true
                        self.saveBtn.setTitle("Save", for: .normal)
                    }
                    
                    if let error = error {
                        DispatchQueue.main.async {
                            self.view.makeToast(error)
                        }
                        return
                    }
                    
                    guard let _ = data else {return}
                    DispatchQueue.main.asyncAfter(wallDeadline: .now() + 1) {
                        Router().toMap()
                    }
                }
            }
        }else {
            return
        }
    }
    
    //MARK: - Helper
    func updateUserInterface() {
        let monitor = NWPathMonitor()
        
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                DispatchQueue.main.async {
                    self.internetConect = true
                    DispatchQueue.main.async {
                        self.getCats()
                    }
                    DispatchQueue.main.async {
                        self.getEventTypes()
                    }
                    DispatchQueue.main.async {
                        self.getAllValidatConfig()
                    }
                }
                return
            }else {
                DispatchQueue.main.async {
                    self.internetConect = false
                    self.HandleInternetConnection()
                }
                return
            }
        }
        
        let queue = DispatchQueue(label: "Network")
        monitor.start(queue: queue)
    }
    
    func HandleInternetConnection() {
        self.view.makeToast("Network is unavailable, please try again!".localizedString)
    }
    
    func getAllValidatConfig() {
        allValidatConfigVM.getAllValidatConfig()
        allValidatConfigVM.userValidationConfig.bind { [unowned self]value in
        }
        
        // Set View Model Event Listener
        allValidatConfigVM.errorMsg.bind { [unowned self]error in
            DispatchQueue.main.async {
                print(error)
            }
        }
    }
    
    func setupView() {
        eventImg.cornerRadiusView(radius: 6)
        saveBtn.cornerRadiusView(radius: 6)
        limitUsersView.cornerRadiusView(radius: 5)
        descriptionTxtView.cornerRadiusView(radius: 5)
        saveCategoryBtn.cornerRadiusView(radius: 8)
        
        categoriesView.setCornerforTop( withShadow: false, cornerMask: [.layerMaxXMinYCorner, .layerMinXMinYCorner], radius: 21)
        eventTypesView.setCornerforTop( withShadow: false, cornerMask: [.layerMaxXMinYCorner, .layerMinXMinYCorner], radius: 21)
        
        descriptionTxtView.delegate = self
        
        DispatchQueue.main.async {
            self.setupDatePickerForStartDate()
            self.setupDatePickerForStartTime()
            self.setupDatePickerForEndTime()
        }
        
        //        let formatter = DateFormatter()
        //        formatter.dateFormat = "yyyy-MM-dd"
        //        self.startDayLbl.text = formatter.string(from: (self.dateAlertView?.calenderView.date)!)
        //        self.endDayLbl.text = formatter.string(from: (self.dateAlertView?.calenderView.date)!)
        //
        //        let formattrTime = DateFormatter()
        //        formattrTime.dateFormat = "HH:mm"
        //        self.startTimeLbl.text = formattrTime.string(from: (self.timeAlertView?.timeView.date)!)
        //        self.endTimeLbl.text = formattrTime.string(from: (self.timeAlertView?.timeView.date)!)
        
        collectionView.register(UINib(nibName: cellId, bundle: nil), forCellWithReuseIdentifier: cellId)
        eventTypesTV.register(UINib(nibName: eventTypeCellId, bundle: nil), forCellReuseIdentifier: eventTypeCellId)
    }
    
    var selectFriends:[UserConversationModel] = [UserConversationModel]()
    var listNamesSelected:[String] = [String]()
    
    func onListFriendsCallBack(_ listIDs: [String],_ listNames: [String],_ selectFriends:[UserConversationModel]) -> () {
        print("\(listIDs)")
        print("\(listNames)")
        self.listFriendsIDs = listIDs
        self.listNamesSelected = listNames
        self.selectFriends = selectFriends
    }
}

//MARK: - Extensions
extension AddEventVC : UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        hiddenLbl.isHidden = !textView.text.isEmpty
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (descriptionTxtView.text as NSString).replacingCharacters(in: range, with: text)
        return newText.count < Defaults.eventDetailsDescription_MaxLength
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
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image = info[.originalImage] as! UIImage
        let originImg = image.fixOrientation()
        
        let cropper = CustomCropperViewController(originalImage: originImg)
        cropper.delegate = self
        self.navigationController?.pushViewController(cropper, animated: true)
        picker.dismiss(animated: true) {
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.attachedImg = false
        self.tabBarController?.tabBar.isHidden = false
        picker.dismiss(animated:true, completion: nil)
    }
}

extension AddEventVC: CropperViewControllerDelegate {
    
    func aspectRatioPickerDidSelectedAspectRatio(_ aspectRatio: AspectRatio) {
        print("\(String(describing: aspectRatio.dictionary))")
    }
    
    func cropperDidConfirm(_ cropper: CropperViewController, state: CropperState?) {
        cropper.onPopup()
        if let state = state,
           let image = cropper.originalImage.cropped(withCropperState: state) {
            eventImg.image = image
            self.attachedImg = true
            print(cropper.isCurrentlyInInitialState)
            print(image)
        }
    }
    
    func cropperDidCancel(_ cropper: CropperViewController) {
        cropper.onPopup()
    }
}

extension AddEventVC : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return catsVM.cats.value?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? CategoryCollectionViewCell else {return UICollectionViewCell()}
        let model = catsVM.cats.value?[indexPath.row]
        cell.tagNameLbl.text = model?.name
        cell.layoutSubviews()
        return cell
    }
}

extension AddEventVC: UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = catsVM.cats.value?[indexPath.row]
        catSelectedName = model?.name ?? ""
        catselectedID = model?.id ?? ""
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let model = catsVM.cats.value?[indexPath.row]
        let width = model?.name?.widthOfString(usingFont: UIFont(name: "Montserrat-Medium", size: 12)!)
        
        return CGSize(width: width! + 40, height: 45)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}

extension AddEventVC :UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return typesVM.types.value?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: eventTypeCellId, for: indexPath) as? ProblemTableViewCell else {return UITableViewCell()}
        let model = typesVM.types.value?[indexPath.row]
        cell.titleLbl.text = (model?.name ?? "") + " Event"
        return cell
    }
}

extension AddEventVC:UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let model = typesVM.types.value?[indexPath.row]
        
        eventTypeLbl.text = (model?.name ?? "") + " Event"
        eventTypeID = model?.entityId ?? ""
        eventTypeName = model?.name ?? ""
        
        if model?.name == "Private" {
            selectFriendsView.isHidden = false
            topFriendsViewLayoutConstraint.constant = 10
            bottomFriendsViewLayoutConstaint.constant = 10
            selectFriendsViewHeight.constant = 40
            selectFriendsTopView.isHidden = false
            
            showAttendeesViewHeight.constant = 40
            showAttendeesFriendsTopView.isHidden = false
            topShowAttendeesViewLayoutConstraint.constant = 10
            bottomShowAttendeesViewLayoutConstaint.constant = 10
            showAttendeesTopView.isHidden = false
        }else {
            selectFriendsView.isHidden = true
            topFriendsViewLayoutConstraint.constant = 0
            bottomFriendsViewLayoutConstaint.constant = 0
            selectFriendsViewHeight.constant = 0
            selectFriendsTopView.isHidden = true
         
            showAttendeesTopView.isHidden = true
            showAttendeesViewHeight.constant = 0
            showAttendeesFriendsTopView.isHidden = true
            topShowAttendeesViewLayoutConstraint.constant = 0
            bottomShowAttendeesViewLayoutConstaint.constant = 0
            
        }
        
        categoriesSuperView.isHidden = true
        eventTypesView.isHidden = true
    }
}

extension AddEventVC {
    func setupDatePickerForStartDate(){
        //Formate Date
        datePicker1.datePickerMode = .date
        if #available(iOS 13.4, *) {
            datePicker1.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        
        datePicker1.minimumDate = Date()
        
        //ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePicker1))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker))
        
        doneButton.tintColor = UIColor.FriendzrColors.primary!
        cancelButton.tintColor = UIColor.red
        
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        
        selectStartDateTxt.inputAccessoryView = toolbar
        selectStartDateTxt.inputView = datePicker1
        
    }
    @objc func donedatePicker1(){
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        selectStartDateTxt.text = formatter.string(from: datePicker1.date)
        self.startDate = formatter.string(from: self.datePicker1.date)
        
        var comps2:DateComponents = DateComponents()
        comps2.month = 1
        comps2.day = -1
        
        self.minimumDate = (self.datePicker1.date)
        self.maximumDate = self.datePicker1.calendar.date(byAdding: comps2, to: self.minimumDate)!
        
        print(formatter.string(from: self.minimumDate),formatter.string(from: self.maximumDate))
        
        setupDatePickerForEndDate()
        self.view.endEditing(true)
    }
    
    func setupDatePickerForEndDate(){
        //Formate Date
        datePicker2.datePickerMode = .date
        if #available(iOS 13.4, *) {
            datePicker2.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        
        datePicker2.minimumDate = self.minimumDate
        datePicker2.maximumDate = self.maximumDate
        
        //ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePicker2))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker))
        
        doneButton.tintColor = UIColor.FriendzrColors.primary!
        cancelButton.tintColor = UIColor.red
        
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        
        selectEndDateTxt.inputAccessoryView = toolbar
        selectEndDateTxt.inputView = datePicker2
        
    }
    @objc func donedatePicker2(){
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        selectEndDateTxt.text = formatter.string(from: datePicker2.date)
        self.endDate = formatter.string(from: datePicker2.date)
        
        self.view.endEditing(true)
    }
    
    
    func setupDatePickerForStartTime(){
        //Formate Date
        timePicker1.datePickerMode = .time
        if #available(iOS 13.4, *) {
            timePicker1.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        
        //ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePicker3))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker))
        
        doneButton.tintColor = UIColor.FriendzrColors.primary!
        cancelButton.tintColor = UIColor.red
        
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        
        selectStartTimeTxt.inputAccessoryView = toolbar
        selectStartTimeTxt.inputView = timePicker1
        
    }
    @objc func donedatePicker3(){
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        selectStartTimeTxt.text = formatter.string(from: timePicker1.date)
        self.startTime = formatter.string(from: timePicker1.date)
        self.view.endEditing(true)
    }
    
    func setupDatePickerForEndTime(){
        //Formate Date
        timePicker2.datePickerMode = .time
        if #available(iOS 13.4, *) {
            timePicker2.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        
        //ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePicker4))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker))
        
        doneButton.tintColor = UIColor.FriendzrColors.primary!
        cancelButton.tintColor = UIColor.red
        
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        
        selectEndTimeTxt.inputAccessoryView = toolbar
        selectEndTimeTxt.inputView = timePicker2
        
    }
    @objc func donedatePicker4(){
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        selectEndTimeTxt.text = formatter.string(from: timePicker2.date)
        self.endTime = formatter.string(from: timePicker2.date)
        self.view.endEditing(true)
    }
    
    @objc func cancelDatePicker(){
        self.view.endEditing(true)
    }
    
}
