//
//  AdsTableViewCell.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 09/02/2022.
//

import UIKit
//import GoogleMobileAds
import Adjust
import AppLovinSDK

class AdsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var bannerView: UIView!
    @IBOutlet weak var bannerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var topLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
    
    var parentVC = UIViewController()
    var adView:MAAdView!
    var interstitialAd: MAInterstitialAd!
    var retryAttempt = 0.0
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bannerView.cornerRadiusView(radius: 12)
        //        bannerView.adUnitID =  URLs.adUnitBanner
        ////        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        ////        addBannerViewToView(bannerView)
        //        bannerView.rootViewController = parentVC
        //        bannerView.load(GADRequest())
        //        bannerView.delegate = self
        
        createBannerAd()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

//extension AdsTableViewCell:GADBannerViewDelegate {
//    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
//        print(error)
//        bannerViewHeight.constant = 0
//    }
//
//    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
//        print("Receive Ad")
//    }
//
//    func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
//        print("bannerViewDidRecordImpression")
//    }
//
//    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
//        print("bannerViewWillPresentScreen")
//        bannerView.load(GADRequest())
//    }
//
//    func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
//        print("bannerViewWillDIsmissScreen")
//    }
//
//    func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
//        print("bannerViewDidDismissScreen")
//    }
//}

// MARK: - MAAdViewAdDelegate

extension AdsTableViewCell : MAAdViewAdDelegate , MAAdRevenueDelegate { //, MAAdReviewDelegate {
    
    func createBannerAd() {
        adView = MAAdView(adUnitIdentifier: "65940d589c7a5266")
        adView.delegate = self
        adView.revenueDelegate = self
        //        adView.adReviewDelegate = self
        // Banner height on iPhone and iPad is 50 and 90, respectively
        let height: CGFloat = (UIDevice.current.userInterfaceIdiom == .pad) ? 90 : 50
        
        // Stretch to the width of the screen for banners to be fully functional
        //        let width: CGFloat = UIScreen.main.bounds.width
        
        adView.frame = CGRect(x: 0 , y: 0, width: bannerView.frame.width, height: height)
        adView.setExtraParameterForKey("adaptive_banner", value: "true")
        
        // Set background or background color for banners to be fully functional
        adView.backgroundColor = UIColor.FriendzrColors.primary!
        
        bannerView.addSubview(adView)
        // Load the first ad
        adView.loadAd()
    }
    
    // MARK: MAAdDelegate Protocol
    
    func didLoad(_ ad: MAAd) {
        //       adView.loadAd()
        //       adView.isHidden = false
        //       adView.startAutoRefresh()
    }
    
    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        //        print("error.description \(error.description)")
        
        print("Waterfall Name: \(String(describing: error.waterfall?.name)) and Test Name: \(String(describing: error.waterfall?.testName))")
        print("Waterfall latency was: \(String(describing: error.waterfall?.latency)) seconds")
        
        for networkResponse in error.waterfall?.networkResponses ?? [] {
            print("Network -> \(networkResponse.mediatedNetwork)")
            print("...latency: \(networkResponse.latency) seconds")
            print("...credentials: \(networkResponse.credentials)")
            print("...error: \(networkResponse.error!)")
        }
    }
    
    func didClick(_ ad: MAAd) {}
    
    func didFail(toDisplay ad: MAAd, withError error: MAError) {
        print("error = \(error.description)")
        print("ad = \(ad.description)")
    }
    
    
    // MARK: MAAdViewAdDelegate Protocol
    
    func didExpand(_ ad: MAAd) {}
    
    func didCollapse(_ ad: MAAd) {}
    
    
    // MARK: Deprecated Callbacks
    
    func didDisplay(_ ad: MAAd) { /* DO NOT USE - THIS IS RESERVED FOR FULLSCREEN ADS ONLY AND WILL BE REMOVED IN A FUTURE SDK RELEASE */
        //       Adjust.getInstance()
    }
    func didHide(_ ad: MAAd) { /* DO NOT USE - THIS IS RESERVED FOR FULLSCREEN ADS ONLY AND WILL BE REMOVED IN A FUTURE SDK RELEASE */ }
    
    
    // MARK: MAAdRevenueDelegate Protocol
    
    func didPayRevenue(for ad: MAAd)
    {
        //        logCallback()
        
        let adjustAdRevenue = ADJAdRevenue(source: ADJAdRevenueSourceAppLovinMAX)!
        adjustAdRevenue.setRevenue(ad.revenue, currency: "USD")
        adjustAdRevenue.setAdRevenueNetwork(ad.networkName)
        adjustAdRevenue.setAdRevenueUnit(ad.adUnitIdentifier)
        if let placement = ad.placement
        {
            adjustAdRevenue.setAdRevenuePlacement(placement)
        }
        Adjust.trackAdRevenue(adjustAdRevenue)
    }
    
}
