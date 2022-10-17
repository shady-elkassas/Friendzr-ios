//
//  FriendImageProfileTableViewCell.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 14/02/2022.
//

import UIKit

class FriendImageProfileTableViewCell: UITableViewCell {
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var gradientView: GradientView!
    @IBOutlet weak var refuseBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var acceptBtn: UIButton!
    @IBOutlet weak var sendRequestBtn: UIButton!
    @IBOutlet weak var messageBtn: UIButton!
    @IBOutlet weak var ageLbl: UILabel!
    @IBOutlet weak var genderLlb: UILabel!
    @IBOutlet weak var friendStackView: UIStackView!
    @IBOutlet weak var unfriendBtn: UIButton!
    
    var HandleMessageBtn: (()->())?
    var HandleRefuseBtn: (()->())?
    var HandleCancelBtn: (()->())?
    var HandleAcceptBtn: (()->())?
    var HandleUnFriendBtn: (()->())?
    var HandleSendRequestBtn: (()->())?

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        sendRequestBtn.cornerRadiusForHeight()
        cancelBtn.cornerRadiusForHeight()
        acceptBtn.cornerRadiusForHeight()
        refuseBtn.cornerRadiusForHeight()
        messageBtn.cornerRadiusForHeight()
        unfriendBtn.cornerRadiusForHeight()
        cancelBtn.setBorder(color: UIColor.white.cgColor, width: 1)
        messageBtn.setBorder(color: UIColor.white.cgColor, width: 1)
        refuseBtn.setBorder(color: UIColor.white.cgColor, width: 1)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func unFriendBtn(_ sender: Any) {
        HandleUnFriendBtn?()
    }
    @IBAction func messageBtn(_ sender: Any) {
        HandleMessageBtn?()
    }
    
    @IBAction func sendRequestBtn(_ sender: Any) {
        HandleSendRequestBtn?()
    }
    
    @IBAction func cancelBtn(_ sender: Any) {
        HandleCancelBtn?()
    }
    
    @IBAction func refuseBtn(_ sender: Any) {
        HandleRefuseBtn?()
    }
    
    @IBAction func acceptBtn(_ sender: Any) {
        HandleAcceptBtn?()
    }
}
