//
//  EventCalendarVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 28/02/2022.
//

import UIKit

class EventCalendarVC: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var yearAndDayView: UIView!
    @IBOutlet weak var yearLbl: UILabel!
    @IBOutlet weak var dayLbl: UILabel!
    @IBOutlet weak var calenderView: UIDatePicker!
    @IBOutlet weak var okBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!

    //MARK: - Properties
    var onDateCallBackResponse: ((_ dayDate: String, _ date: String,_ minimumDate:Date,_ maximumDate:Date) -> ())?
    var minimumDate:Date = Date()
    var maximumDate:Date = Date()
    var dayname = ""
    var monthname = ""
    var nday = ""
    var nyear = ""
    var startDate = ""
    var endDate = ""

    var eventModel:EventObj? = nil

    var startDateEvent:Date = Date()
    var endDateEvent:Date = Date()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        containerView.shadow()
        containerView.cornerRadiusView(radius: 12)
        yearAndDayView.setCornerforTop()
        showDatePicker()
        
        self.calenderView.addTarget(self, action: #selector(self.dateChanged(_:)), for: .valueChanged)
    }
    
    //MARK: - Helpers
    func showDatePicker(){
        //Formate Date
//        let dateee = (eventModel?.eventdate ?? "") + "T10:44:00+0000"
        
//        startDateEvent = dateee.toDate(withFormat: "yyyy-MM-dd'T'HH:mm:ss") ?? Date()
        calenderView.datePickerMode = .date
        calenderView.minimumDate = Date()
        calenderView.tintColor = UIColor.FriendzrColors.primary
        calenderView.cornerRadiusView(radius: 12)
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        let formatter2 = DateFormatter()
        formatter2.dateFormat = "yyyy"
        
        dayLbl.text = formatter.string(from: (calenderView.date))
        yearLbl.text = formatter2.string(from: (calenderView.date))

    }
    
    //MARK: - Actions
    @IBAction func cancelBtn(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func okBtn(_ sender: Any) {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let formatter2 = DateFormatter()
        formatter2.dateFormat = "yyyy-MM-dd"
        
        var comps2:DateComponents = DateComponents()
        comps2.month = 1
        comps2.day = -1
        
        self.minimumDate = (self.calenderView.date)
        self.maximumDate = (self.calenderView.calendar.date(byAdding: comps2, to: self.minimumDate))!
        
        onDateCallBackResponse?(formatter.string(from: (self.calenderView.date)),formatter2.string(from: (self.calenderView.date)),self.minimumDate,self.maximumDate)
        
        print(formatter2.string(from: self.minimumDate),formatter2.string(from: self.maximumDate))
        
        self.dismiss(animated: true)
    }
    
}

//MARK: - Date Changed Calendar
extension EventCalendarVC {
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
            
            dayLbl.text = dayname + ", " + monthname + " " + nday
            yearLbl.text = nyear
        }
    }
}
