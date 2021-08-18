//
//  EventCalendarView.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 17/08/2021.
//

import Foundation
import UIKit


class EventCalendarView: UIView {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var yearAndDayView: UIView!
    @IBOutlet weak var yearLbl: UILabel!
    @IBOutlet weak var dayLbl: UILabel!
    @IBOutlet weak var calenderView: UIDatePicker!
    @IBOutlet weak var okBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    var HandleOKBtn: (()->())?
    var HandleCancelBtn: (()->())?

    override func awakeFromNib() {
        containerView.shadow()
        containerView.cornerRadiusView(radius: 12)
        yearAndDayView.setCornerforTop()
        showDatePicker()
    }
    
    func showDatePicker(){
        //Formate Date
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
    
    @IBAction func cancelBtn(_ sender: Any) {
        HandleCancelBtn?()
    }
    @IBAction func okBtn(_ sender: Any) {
        HandleOKBtn?()
    }
    
}
