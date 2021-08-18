//
//  AddEventVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 17/08/2021.
//

import Foundation
import UIKit

class AddEventVC: UIViewController {

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
        
    
    lazy var dateAlertView = Bundle.main.loadNibNamed("EventCalendarView", owner: self, options: nil)?.first as? EventCalendarView
    lazy var timeAlertView = Bundle.main.loadNibNamed("EventTimeCalenderView", owner: self, options: nil)?.first as? EventTimeCalenderView
    
    var dayname = ""
    var monthname = ""
    var nday = ""
    var nyear = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Add Event".localizedString
        setup()
        initBackButton()
    }
    override func viewWillAppear(_ animated: Bool) {
        setupNavBar()
        initSaveBarButton()
    }
    
    func setup() {
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
}

extension AddEventVC {
    func initSaveBarButton() {
        let button = UIButton.init(type: .custom)
        button.tintColor = UIColor.color("#141414")
        button.setTitle("SAVE".localizedString, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.init(name: "Montserrat-SemiBold", size: 12)
        button.addTarget(self, action: #selector(handleSaveButton), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    @objc func handleSaveButton() {
        
    }
}

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
