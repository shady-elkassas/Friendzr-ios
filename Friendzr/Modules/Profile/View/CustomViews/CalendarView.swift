//
//  CalendarView.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 16/08/2021.
//

import Foundation
import UIKit


class CalendarView: UIView {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var calendarView: UIDatePicker!
    
    var HandleOKBtn: (()->())?
    var HandleCancelBtn: (()->())?
    
    override func awakeFromNib() {
        containerView.shadow()
        containerView.cornerRadiusView(radius: 12)
        showDatePicker()
    }
    
    func showDatePicker(){
        //Formate Date
        calendarView.datePickerMode = .date
        calendarView.maximumDate = Date()
        calendarView.tintColor = UIColor.FriendzrColors.primary!
        calendarView.cornerRadiusView(radius: 12)
    }

    @IBAction func okBtn(_ sender: Any) {
        HandleOKBtn?()
    }
    @IBAction func cancelBtn(_ sender: Any) {
        HandleCancelBtn?()
    }
    
}
