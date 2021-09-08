//
//  SeeMoreTableViewCell.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 07/09/2021.
//

import UIKit

class SeeMoreTableViewCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var attendeesBtn: UIButton!
    
    var HandleSeeMoreBtn: (() -> ())?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func attendessBtn(_ sender: Any) {
        HandleSeeMoreBtn?()
    }
    
}
