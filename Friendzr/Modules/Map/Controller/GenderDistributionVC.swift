//
//  GenderDistributionVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 05/10/2021.
//

import UIKit
import SwiftUI
import GoogleMobileAds

let adUnitID =  "ca-app-pub-3940256099942544/2934735716"
//let publisherID = "ca-app-pub-3940256099942544/2934735716"
//let adUnitID = "ca-app-pub-9901362047037891/8741727589"
//let appID = "ca-app-pub-9901362047037891~4064115975"


class GenderDistributionVC: UIViewController {

    @IBOutlet var bannerView: GADBannerView!
    @IBOutlet weak var genderDistributionView: UIView!
    @IBOutlet weak var genderDistributionChart: UIView!
    @IBOutlet weak var tvContainerView: UIView!
    @IBOutlet weak var tvContainerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var hideView: UIView!
    
    let cellID = "GenderDistributionTableViewCell"
    var genderbylocationVM: GenderbylocationViewModel = GenderbylocationViewModel()
    
    var lat:Double = 0.0
    var lng:Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        initCloseBarButton()
        title = "Gender Distribution"
        setupNavBar()
        
        getGenderbylocation(lat: lat, lng: lng)
    }
    

    
    override func viewWillAppear(_ animated: Bool) {
        seyupAds()
    }
    
    func seyupAds() {
        bannerView.adUnitID = adUnitID
        //        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        //        addBannerViewToView(bannerView)
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
    }
    
    func getGenderbylocation(lat:Double,lng:Double) {
        self.showLoading()
        genderbylocationVM.getGenderbylocation(ByLat: lat, AndLng: lng)
        genderbylocationVM.gender.bind { [unowned self] value in
            DispatchQueue.main.async {
                self.hideLoading()
                hideView.isHidden = true
                let child = UIHostingController(rootView: CircleView(fill1: 0, fill2: 0, fill3: 0, animations: true, male: Int(value.malePercentage ?? 0.0), female: Int(value.femalepercentage ?? 0.0), other: Int(value.otherpercentage ?? 0.0)))
                child.view.translatesAutoresizingMaskIntoConstraints = true
                child.view.frame = CGRect(x: 0, y: 0, width: genderDistributionChart.bounds.width, height: genderDistributionChart.bounds.height)
                child.loadView()
                genderDistributionChart.addSubview(child.view)
                
                tableView.delegate = self
                tableView.dataSource = self
                tableView.reloadData()
            }
        }
        
        // Set View Model Event Listener
        genderbylocationVM.error.bind { [unowned self]error in
            DispatchQueue.main.async {
                self.hideLoading()
                self.showAlert(withMessage: error)
            }
        }
    }
    
    
    func setupView() {

        genderDistributionView.shadow()
        tvContainerView.shadow()
        genderDistributionView.cornerRadiusView(radius: 20)
        tvContainerView.cornerRadiusView(radius: 8)

        tableView.register(UINib(nibName: cellID, bundle: nil), forCellReuseIdentifier: cellID)
        tvContainerViewHeight.constant = CGFloat(3*50) + 20
    }
    
//    func addBannerViewToView(_ bannerView: GADBannerView) {
//      bannerView.translatesAutoresizingMaskIntoConstraints = false
//      view.addSubview(bannerView)
//      view.addConstraints(
//        [NSLayoutConstraint(item: bannerView,
//                            attribute: .bottom,
//                            relatedBy: .equal,
//                            toItem: bottomLayoutGuide,
//                            attribute: .top,
//                            multiplier: 1,
//                            constant: 0),
//         NSLayoutConstraint(item: bannerView,
//                            attribute: .centerX,
//                            relatedBy: .equal,
//                            toItem: view,
//                            attribute: .centerX,
//                            multiplier: 1,
//                            constant: 0)
//        ])
//     }

}
extension GenderDistributionVC:GADBannerViewDelegate {
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print(error)
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
extension GenderDistributionVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? GenderDistributionTableViewCell else {return UITableViewCell()}
        
        let model = genderbylocationVM.gender.value
        
        if indexPath.row == 0 {
            cell.interestNameLbl.text = "Male"
            cell.lblColor.backgroundColor = UIColor.blue
            cell.percentageLbl.text = "\(model?.malePercentage ?? 0) %"
        }else if indexPath.row == 1 {
            cell.interestNameLbl.text = "Female"
            cell.lblColor.backgroundColor = UIColor.red
            cell.percentageLbl.text = "\(model?.femalepercentage ?? 0) %"
        }else {
            cell.interestNameLbl.text = "Other Gender"
            cell.lblColor.backgroundColor = UIColor.green
            cell.percentageLbl.text = "\(model?.otherpercentage ?? 0) %"
        }
        
        
        if indexPath.row == 3 {
            cell.bottonView.isHidden = true
        }
        
        return cell
    }
}

extension GenderDistributionVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
