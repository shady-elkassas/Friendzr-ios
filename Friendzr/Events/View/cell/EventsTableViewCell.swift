//
//  EventsTableViewCell.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 16/08/2021.
//

import UIKit

class EventsTableViewCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var arrowImg: UIImageView!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var joinedDateLbl: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        containerView.setBorder()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
