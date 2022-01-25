//
//  EmptyViewTableViewCell.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 08/11/2021.
//

import UIKit

class EmptyViewTableViewCell: UITableViewCell {

    @IBOutlet weak var controlBtn: UIButton!
    @IBOutlet weak var emptyImg: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    
    var HandleControlBtn: (() -> ())?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        controlBtn.cornerRadiusForHeight()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func controlBtn(_ sender: Any) {
        HandleControlBtn?()
    }
}
