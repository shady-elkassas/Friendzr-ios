//
//  EventImageTableViewCell.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 09/02/2022.
//

import UIKit

class EventImageTableViewCell: UITableViewCell {
    @IBOutlet weak var eventImg: UIImageView!
    @IBOutlet weak var gradientView: GradientView!
    @IBOutlet weak var attendeesLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var categoryLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
