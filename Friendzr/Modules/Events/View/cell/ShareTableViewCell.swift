//
//  ShareTableViewCell.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 18/01/2022.
//

import UIKit

class ShareTableViewCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var bottomView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        sendBtn.cornerRadiusView(radius: 8)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func sendBtn(_ sender: Any) {
    }
}
