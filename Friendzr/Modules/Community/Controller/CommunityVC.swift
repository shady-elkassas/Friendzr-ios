//
//  CommunityVC.swift
//  Friendzr
//
//  Created by Shady Elkassas on 24/08/2022.
//

import UIKit
import AMShimmer

class CommunityVC: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var superView: UIView!
    @IBOutlet weak var friendsCommunityCollectionView: UICollectionView!
    @IBOutlet weak var recentlyConnectedCollectionView: UICollectionView!
    @IBOutlet weak var eventCollectionView: UICollectionView!
    
    @IBOutlet weak var hideView1: UIView!
    @IBOutlet weak var hideView2: UIView!
    @IBOutlet weak var hideView3: UIView!
    
    @IBOutlet weak var hideImg1: UIImageView!
    @IBOutlet weak var hideImg2: UIImageView!
    @IBOutlet weak var hideImg3: UIImageView!
    @IBOutlet weak var hideImg4: UIImageView!
    @IBOutlet weak var hideImg5: UIImageView!
    @IBOutlet weak var hideImg6: UIImageView!
    @IBOutlet weak var hideImg7: UIImageView!
    @IBOutlet weak var hideImg8: UIImageView!
    
    @IBOutlet weak var hideImg9: UIImageView!
    @IBOutlet var hideImg10: [UIImageView]!
    @IBOutlet var hideImgs: [UIImageView]!
    
    
    
    let cellID1 = "FriendsCommunityCollectionViewCell"
    let cellID2 = "RecommendedEventCollectionViewCell"
    let cellID3 = "RecentlyConnectedCollectionViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBar()
        title = "Community"
        setupViews()
        initRequestsBarButton()
        initProfileBarButton(didTap: true)
    }
        
    override func viewWillAppear(_ animated: Bool) {
        
        shimmerViews()
    }
    
    func setupViews() {
        friendsCommunityCollectionView.register(UINib(nibName: cellID1, bundle: nil), forCellWithReuseIdentifier: cellID1)
        eventCollectionView.register(UINib(nibName: cellID2, bundle: nil), forCellWithReuseIdentifier: cellID2)
        recentlyConnectedCollectionView.register(UINib(nibName: cellID3, bundle: nil), forCellWithReuseIdentifier: cellID3)
        
        hideImg1.cornerRadiusView(radius: 5)
        hideImg2.cornerRadiusView(radius: 8)
        hideImg3.cornerRadiusView(radius: 5)
        hideImg4.cornerRadiusView(radius: 8)
        hideImg5.cornerRadiusView(radius: 5)
        hideImg6.cornerRadiusView(radius: 5)
        hideImg7.cornerRadiusView(radius: 5)
        hideImg8.cornerRadiusView(radius: 5)
        hideImg9.cornerRadiusView(radius: 8)
        
        for item in hideImg10 {
            item.cornerRadiusView(radius: 5)
        }
        
        for itm in hideImgs {
            itm.cornerRadiusView(radius: 8)
        }
    }
    
    func shimmerViews() {
        self.hideView1.isHidden = false
        self.hideView2.isHidden = false
        self.hideView3.isHidden = false

        AMShimmer.start(for: hideView1)
        AMShimmer.start(for: hideView2)
        AMShimmer.start(for: hideView3)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            AMShimmer.stop(for: self.hideView1)
            AMShimmer.stop(for: self.hideView2)
            AMShimmer.stop(for: self.hideView3)
            self.hideView1.isHidden = true
            self.hideView2.isHidden = true
            self.hideView3.isHidden = true
        }
    }
}

extension CommunityVC:UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView != recentlyConnectedCollectionView {
            return 1
        }else {
            return 10
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == friendsCommunityCollectionView {
            guard let cell = friendsCommunityCollectionView.dequeueReusableCell(withReuseIdentifier: cellID1, for: indexPath) as? FriendsCommunityCollectionViewCell else {return UICollectionViewCell()}
            
            cell.HandleSkipBtn = {
                self.hideView1.isHidden = false
                AMShimmer.start(for: self.hideView1)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.hideView1.isHidden = true
                    AMShimmer.stop(for: self.hideView1)
                }
            }
            return cell
        }
        else if collectionView == eventCollectionView {
            guard let cell = eventCollectionView.dequeueReusableCell(withReuseIdentifier: cellID2, for: indexPath) as? RecommendedEventCollectionViewCell else {return UICollectionViewCell()}
            
            cell.HandleSkipBtn = {
                self.hideView2.isHidden = false
                AMShimmer.start(for: self.hideView2)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.hideView2.isHidden = true
                    AMShimmer.stop(for: self.hideView2)
                }
            }
            return cell
        }
        else {
            guard let cell = recentlyConnectedCollectionView.dequeueReusableCell(withReuseIdentifier: cellID3, for: indexPath) as? RecentlyConnectedCollectionViewCell else {return UICollectionViewCell()}
            return cell
        }
    }
}

extension CommunityVC:UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let wid = collectionView.frame.width
        let hig = collectionView.frame.height
        if collectionView != recentlyConnectedCollectionView {
            return CGSize(width: wid, height: hig)
        }else {
            return CGSize(width: wid/3.3, height: hig)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        if collectionView != recentlyConnectedCollectionView {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }else {
            return UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension CommunityVC {
    //init requests page
    func initRequestsBarButton() {
        let button = UIButton.init(type: .custom)
        button.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        let image = UIImage(named: "request_unselected_ic")?.withRenderingMode(.automatic)
        button.setImage(image, for: .normal)
        button.setTitle("Requests", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.tintColor = .black
        button.titleLabel?.font = UIFont(name: "Montserrat-Medium", size: 10)!
        button.imageEdgeInsets.left = button.frame.width - 5
        button.titleEdgeInsets.left = -5
        button.addTarget(self, action: #selector(goToRequestsPage), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    @objc func goToRequestsPage() {
        guard let vc = UIViewController.viewController(withStoryboard: .Request, AndContollerID: "RequestVC") as? RequestVC else {return}
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
