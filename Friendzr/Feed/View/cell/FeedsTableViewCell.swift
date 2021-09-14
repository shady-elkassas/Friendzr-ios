//
//  FeedsTableViewCell.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 15/08/2021.
//

import UIKit

class FeedsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var friendRequestImg: UIImageView!
    @IBOutlet weak var friendRequestNameLbl: UILabel!
    @IBOutlet weak var friendRequestUserNameLbl: UILabel!
    @IBOutlet weak var sendRequestBtn: UIButton!
    @IBOutlet weak var cancelRequestBtn: UIButton!
    
    @IBOutlet weak var respondBtn: UIButton!
    @IBOutlet weak var unfriendBtn: UIButton!
    @IBOutlet weak var blockBtn: UIButton!
    @IBOutlet weak var stackBtnsView: UIStackView!
    @IBOutlet weak var unblockBtn: UIButton!
    
    
    var HandleSendRequestBtn: (() -> ())?
    var HandleCancelRequestBtn: (() -> ())?
    var HandleBlockBtn: (() -> ())?
    var HandleUnblocktBtn: (() -> ())?
    var HandleRespondBtn: (() -> ())?
    var HandleUnfreiendBtn: (() -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cancelRequestBtn.setBorder(color: UIColor.FriendzrColors.primary?.cgColor, width: 1)
        sendRequestBtn.cornerRadiusView(radius: 6)
        blockBtn.cornerRadiusView(radius: 6)
        unfriendBtn.cornerRadiusView(radius: 6)
        respondBtn.cornerRadiusView(radius: 6)
        unblockBtn.cornerRadiusView(radius: 6)
        friendRequestImg.cornerRadiusForHeight()
        
        sendRequestBtn.layer.applySketchShadow(color: UIColor.color("#F4F8F3")!, alpha: 1, x: 34, y: 34, blur: 89, spread: 5)
        cancelRequestBtn.layer.applySketchShadow(color: UIColor.color("#F4F8F3")!, alpha: 1, x: 34, y: 34, blur: 89, spread: 5)

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func sendRequestBtn(_ sender: Any) {
        HandleSendRequestBtn?()
    }
    
    @IBAction func cancelRequestBtn(_ sender: Any) {
        HandleCancelRequestBtn?()
    }
    
    @IBAction func blockBtn(_ sender: Any) {
        HandleBlockBtn?()
    }
    
    @IBAction func unfriendBtn(_ sender: Any) {
        HandleUnfreiendBtn?()
    }
    
    @IBAction func respondBtn(_ sender: Any) {
        HandleRespondBtn?()
    }
    
    @IBAction func unblockBtn(_ sender: Any) {
        HandleUnblocktBtn?()
    }
}
