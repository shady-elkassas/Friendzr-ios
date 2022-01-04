//
//  ConfirmReportButtonTableViewCell.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 03/01/2022.
//

import UIKit

class ConfirmReportButtonTableViewCell: UITableViewCell {

    @IBOutlet weak var confirmBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        confirmBtn.cornerRadiusView(radius: 8)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func confirmBtn(_ sender: Any) {
    }
    
}
