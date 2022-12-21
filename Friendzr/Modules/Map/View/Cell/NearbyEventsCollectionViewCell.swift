//
//  NearbyEventsCollectionViewCell.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 15/11/2021.
//

import UIKit
import SDWebImage

class NearbyEventsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var eventColorView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var eventImg: UIImageView!
    @IBOutlet weak var eventDateLbl: UILabel!
    @IBOutlet weak var eventTitleLbl: UILabel!
    @IBOutlet weak var joinedLbl: UILabel!
    @IBOutlet weak var detailsBtn: UIButton!
    @IBOutlet weak var expandLbl: UILabel!
    @IBOutlet weak var expandBtn: UIButton!
    
    var HandledetailsBtn: (()->())?

    var model:EventObj! {
        didSet {
            eventTitleLbl.text = model?.title
            eventDateLbl.text = model?.eventdate
            joinedLbl.text = "Attendees : ".localizedString + "\(model?.joined ?? 0) / \(model?.totalnumbert ?? 0)"
            
            eventImg.sd_imageIndicator = SDWebImageActivityIndicator.gray
            eventImg.sd_setImage(with: URL(string: model?.image ?? "" ), placeholderImage: UIImage(named: "placeHolderApp"))
            
            detailsBtn.tintColor = UIColor.color((model?.eventtypecolor ?? ""))
            expandLbl.textColor = UIColor.color((model?.eventtypecolor ?? ""))
            eventDateLbl.textColor = UIColor.color((model?.eventtypecolor ?? ""))
            eventColorView.backgroundColor = UIColor.color((model?.eventtypecolor ?? ""))
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        eventImg.cornerRadiusView(radius: 10)
        containerView.cornerRadiusView(radius: 10)
        eventColorView.setCornerforTop()
        detailsBtn.cornerRadiusForHeight()
        eventImg.setBorder(color: UIColor.FriendzrColors.primary?.cgColor, width: 0.5)
    }
    
    @IBAction func expandBtn(_ sender: Any) {
        HandledetailsBtn?()
    }
    @IBAction func detailsBtn(_ sender: Any) {
        HandledetailsBtn?()
    }
}
