//
//  TextMessageTableViewCell.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 16/05/2022.
//

import UIKit

class TextMessageTableViewCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var textMessage: UILabel!
    @IBOutlet weak var profileBtn: UIButton!
    
    var HandleProfileBtn: (() -> ())?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        profileBtn.cornerRadiusForHeight()
        containerView.cornerRadiusView(radius: 8)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func profileBtn(_ sender: Any) {
        HandleProfileBtn?()
    }
}
