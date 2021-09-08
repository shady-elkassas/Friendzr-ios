//
//  AttendeesTableViewCell.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 23/08/2021.
//

import UIKit

class AttendeesTableViewCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var friendImg: UIImageView!
    @IBOutlet weak var dropDownBtn: UIButton!
    @IBOutlet weak var friendNameLbl: UILabel!
    @IBOutlet weak var joinDateLbl: UILabel!
    
    var HandleDropDownBtn: (() -> ())?

    override func awakeFromNib() {
        super.awakeFromNib()
        friendImg.cornerRadiusView(radius: 25)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func dropDownBtn(_ sender: Any) {
        HandleDropDownBtn?()
    }
}
