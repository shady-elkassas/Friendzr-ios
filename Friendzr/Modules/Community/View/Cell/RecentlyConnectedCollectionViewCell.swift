//
//  RecentlyConnectedCollectionViewCell.swift
//  Friendzr
//
//  Created by Shady Elkassas on 28/08/2022.
//

import UIKit

class RecentlyConnectedCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var connectedDateLbl: UILabel!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        setupView()
    }
    
    func setupView() {
        userImage.cornerRadiusView()
        containerView.setBorder(color: UIColor.FriendzrColors.primary?.cgColor, width: 1.0)
        containerView.cornerRadiusView(radius: 8)
    }
}
