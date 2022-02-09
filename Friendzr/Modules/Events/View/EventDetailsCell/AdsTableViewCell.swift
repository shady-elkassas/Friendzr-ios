//
//  AdsTableViewCell.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 09/02/2022.
//

import UIKit
import GoogleMobileAds

class AdsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var bannerView: GADBannerView!
    
    var parentVC = UIViewController()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bannerView.cornerRadiusView(radius: 12)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
