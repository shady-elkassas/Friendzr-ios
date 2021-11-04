//
//  SettingsTableViewCell.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 26/10/2021.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var settingIcon: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var switchBtn: UISwitch!
    
    var HandleSwitchBtn: (()->())?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
//        switchBtn.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func switchBtn(_ sender: Any) {
        HandleSwitchBtn?()
    }
}
