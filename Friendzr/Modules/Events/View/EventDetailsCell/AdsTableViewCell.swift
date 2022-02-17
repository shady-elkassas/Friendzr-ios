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
    @IBOutlet weak var bannerViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var topLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
    
    var parentVC = UIViewController()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bannerView.cornerRadiusView(radius: 12)
        bannerView.adUnitID = adUnitID
//        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
//        addBannerViewToView(bannerView)
        bannerView.rootViewController = parentVC
        bannerView.load(GADRequest())
        bannerView.delegate = self
        bannerView.cornerRadiusView(radius: 12)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

extension AdsTableViewCell:GADBannerViewDelegate {
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print(error)
        bannerViewHeight.constant = 0
        //        topLayoutConstraint.constant = 0
//        bottomLayoutConstraint.constant = 0
    }
    
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("Receive Ad")
    }
    
    func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
        print("bannerViewDidRecordImpression")
    }
    
    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("bannerViewWillPresentScreen")
        bannerView.load(GADRequest())
    }
    
    func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("bannerViewWillDIsmissScreen")
    }
    
    func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("bannerViewDidDismissScreen")
    }
}
