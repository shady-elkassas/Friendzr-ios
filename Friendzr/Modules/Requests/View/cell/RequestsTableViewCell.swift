//
//  RequestsTableViewCell.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 06/01/2022.
//

import UIKit

class RequestsTableViewCell: UITableViewCell {
    
//    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var friendRequestImg: UIImageView!
    @IBOutlet weak var friendRequestNameLbl: UILabel!
    @IBOutlet weak var friendRequestUserNameLbl: UILabel!
    @IBOutlet weak var friendRequestDateLbl: UILabel!
    @IBOutlet weak var deleteRequestBtn: UIButton!
    @IBOutlet weak var acceptBtn: UIButton!
    @IBOutlet weak var stackViewBtns: UIStackView!
    @IBOutlet weak var messageBtn: UIButton!
    @IBOutlet weak var requestRemovedLbl: UILabel!
    @IBOutlet weak var bottomView: UIView!
    
    var HandleDeleteBtn: (() -> ())?
    var HandleAcceptBtn: (() -> ())?
    var HandleMessageBtn: (() -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        friendRequestImg.cornerRadiusForHeight()
        messageBtn.cornerRadiusView(radius: 6)
        friendRequestImg.setBorder(color: UIColor.FriendzrColors.primary?.cgColor, width: 0.5)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func deleteBtn(_ sender: Any) {
        HandleDeleteBtn?()
    }
    @IBAction func acceptBtn(_ sender: Any) {
        HandleAcceptBtn?()
    }
    @IBAction func messageBtn(_ sender: Any) {
        HandleMessageBtn?()
    }
}
