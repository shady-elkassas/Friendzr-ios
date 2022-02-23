//
//  EventTableViewCell.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 23/08/2021.
//

import UIKit
import ListPlaceholder

class EventTableViewCell: UITableViewCell {
    
    @IBOutlet weak var eventImg: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var eventTitleLbl: UILabel!
    @IBOutlet weak var categoryLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var attendeesLbl: UILabel!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var editBtn: UIButton!
    
    var HandleEditBtn: (() -> ())?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        containerView.setBorder()
        containerView.cornerRadiusView(radius: 12)
        bgView.setCornerforBottom()
        eventImg.cornerRadiusView(radius: 12)
//        editBtn.cornerRadiusForHeight()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    @IBAction func editBtn(_ sender: Any) {
        HandleEditBtn?()
    }
}
