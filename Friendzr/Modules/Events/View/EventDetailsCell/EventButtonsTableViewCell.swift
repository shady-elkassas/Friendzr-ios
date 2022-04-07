//
//  EventButtonsTableViewCell.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 09/02/2022.
//

import UIKit

class EventButtonsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var leaveBtn: UIButton!
    @IBOutlet weak var joinBtn: UIButton!
    @IBOutlet weak var chatBtn: UIButton!
    @IBOutlet weak var bottomLbl: UILabel!
    
    let model:EventObj? = nil
    var parentvc = UIViewController()
    
    var HandleLeaveBtn: (() -> ())?
    var HandleEditBtn: (() -> ())?
    var HandleJoinBtn: (() -> ())?
    var HandleChatBtn: (() -> ())?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        editBtn.cornerRadiusView(radius: 8)
        joinBtn.cornerRadiusView(radius: 8)
        leaveBtn.cornerRadiusView(radius: 8)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    @IBAction func chatBtn(_ sender: Any) {
        HandleChatBtn?()
    }
    @IBAction func editBtn(_ sender: Any) {
        HandleEditBtn?()
    }
    @IBAction func joinBtn(_ sender: Any) {
        HandleJoinBtn?()
    }
    @IBAction func leaveBtn(_ sender: Any) {
        HandleLeaveBtn?()
    }
}
