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
    @IBOutlet weak var unFriendBtn: UIButton!
    @IBOutlet weak var blockBtn: UIButton!
    @IBOutlet weak var sendRequestBtn: UIButton!
    @IBOutlet weak var friendStackView: UIStackView!
    @IBOutlet weak var unblockBtn: UIButton!
    @IBOutlet weak var ageLbl: UILabel!
    @IBOutlet weak var genderLlb: UILabel!
    
    
    var HandleUnblockBtn: (()->())?
    var HandleBlockBtn: (()->())?
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
        unblockBtn.cornerRadiusForHeight()
        unFriendBtn.cornerRadiusForHeight()
        blockBtn.cornerRadiusForHeight()
        blockBtn.setBorder(color: UIColor.white.cgColor, width: 1)
        cancelBtn.setBorder(color: UIColor.white.cgColor, width: 1)
        unblockBtn.setBorder(color: UIColor.white.cgColor, width: 1)
        refuseBtn.setBorder(color: UIColor.white.cgColor, width: 1)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
    @IBAction func unblockBtn(_ sender: Any) {
        HandleUnblockBtn?()
    }
    
    @IBAction func blockBtn(_ sender: Any) {
        HandleBlockBtn?()
    }
    @IBAction func unFriendBtn(_ sender: Any) {
        HandleUnFriendBtn?()
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
