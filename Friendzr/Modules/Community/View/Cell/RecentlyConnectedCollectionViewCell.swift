//
//  RecentlyConnectedCollectionViewCell.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 28/08/2022.
//

import UIKit
import SDWebImage

class RecentlyConnectedCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var connectedDateLbl: UILabel!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    
    
    var model :RecentlyConnectedObj! {
        didSet {
            userImage.sd_imageIndicator = SDWebImageActivityIndicator.gray
            userImage.sd_setImage(with: URL(string: model?.image ?? "" ), placeholderImage: UIImage(named: "placeHolderApp"))
            userNameLbl.text = model?.name
            connectedDateLbl.text = "Connected: \(model?.date ?? "")"
        }
    }
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
