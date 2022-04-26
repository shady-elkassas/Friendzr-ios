//
//  EventTimeVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 28/02/2022.
//

import UIKit

class EventTimeVC: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var timeView: UIDatePicker!
    @IBOutlet weak var okBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!

    //MARK: - Properties
    var startTime = ""
    var onTimeCallBackResponse: ((_ timeDateLbl: String, _ timeDate: String) -> ())?

    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        containerView.shadow()
        containerView.cornerRadiusView(radius: 12)
        subView.setCornerforTop()
        setupViews()
        showDatePicker()
    }
    
    //MARK: - Helpers
    func showDatePicker(){
        //Formate Date
        timeView.datePickerMode = .time
        timeView.minimumDate = Date()
        timeView.tintColor = UIColor.FriendzrColors.primary!
        timeView.cornerRadiusView(radius: 12)
    }
    func setupViews() {
        var comps2:DateComponents = DateComponents()
        comps2.day = -1
        timeView.minimumDate = timeView.calendar.date(from: comps2)
    }
    
    //MARK: - Actions
    @IBAction func cancelBtn(_ sender: Any) {
        self.onDismiss()
    }
    
    @IBAction func okBtn(_ sender: Any) {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        let formatter2 = DateFormatter()
        formatter2.dateFormat = "HH:mm"
        self.startTime = formatter2.string(from: self.timeView.date)

        onTimeCallBackResponse?(formatter.string(from: self.timeView.date),self.startTime)
        
        self.onDismiss()
    }
}
