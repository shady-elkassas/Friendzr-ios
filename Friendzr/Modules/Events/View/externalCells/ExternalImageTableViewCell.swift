//
//  ExternalImageTableViewCell.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 27/03/2022.
//

import UIKit

class ExternalImageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var gradiendView: GradientView!
    @IBOutlet weak var eventImg: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
