//
//  EventTimeCalenderView.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 17/08/2021.
//

import Foundation
import UIKit

class EventTimeCalenderView: UIView {
   
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var timeView: UIDatePicker!
    @IBOutlet weak var okBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    var HandleOKBtn: (()->())?
    var HandleCancelBtn: (()->())?

    var startTime = ""
    
    override func awakeFromNib() {
        containerView.shadow()
        containerView.cornerRadiusView(radius: 12)
        subView.setCornerforTop()
        showDatePicker()
    }
    
    func showDatePicker(){
        //Formate Date
        timeView.datePickerMode = .time
        timeView.minimumDate = Date()
        timeView.tintColor = UIColor.FriendzrColors.primary
        timeView.cornerRadiusView(radius: 12)
        
//        let formattrTime = DateFormatter()
//        formattrTime.dateFormat = "HH:mm"
//        startTime = formattrTime.string(from: (timeView.date))
    }
    
    @IBAction func cancelBtn(_ sender: Any) {
        HandleCancelBtn?()
    }
    @IBAction func okBtn(_ sender: Any) {
        HandleOKBtn?()
    }
}
