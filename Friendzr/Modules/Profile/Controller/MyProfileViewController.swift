//
//  MyProfileViewController.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 14/02/2022.
//

import UIKit
import SDWebImage
import ListPlaceholder
import Network
import AMShimmer
import ImageSlideshow

class MyProfileViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var hideView: UIView!
    @IBOutlet var hideImgs: [UIImageView]!
    @IBOutlet weak var emptyImg: UIImageView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var emptyMessageLbl: UILabel!
    @IBOutlet weak var triAgainBtn: UIButton!
    
    //MARK: - Properties
    var viewmodel: ProfileViewModel = ProfileViewModel()
    let imageCellID = "ImageProfileTableViewCell"
    let userNameCellId = "ProfileUserNameTableViewCell"
    let interestsCellId = "InterestsProfileTableViewCell"
    let bestDescribesCellId = "BestDescribesTableViewCell"
    let aboutmeCellId = "AboutMeTableViewCell"
    let preferCellId = "PreferToTableViewCell"
    
    var btnSelect:Bool = false
    var selectedVC:Bool = false
    lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        return control
    }()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "My Profile".localizedString
        
        if selectedVC {
            initCloseBarButton()
        }else {
            initBackButton()
        }
        clearNavigationBar()
        setupView()
        
        tableView.refreshControl = refreshControl
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateMyProfile), name: Notification.Name("updateMyProfile"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.hideView.isHidden = false
        if selectedVC {
            Defaults.availableVC = "PresentMyProfileViewController"
        }else {
            Defaults.availableVC = "MyProfileViewController"
        }
        
        print("availableVC >> \(Defaults.availableVC)")
        
        CancelRequest.currentTask = false
        
        DispatchQueue.main.async {
            self.updateUserInterface()
        }
        
        hideNavigationBar(NavigationBar: false, BackButton: false)
        
        
        setupNavBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        CancelRequest.currentTask = true
        self.hideView.isHidden = false
    }
    
    @objc func didPullToRefresh() {
        print("Refersh")
        btnSelect = false
        updateUserInterface()
        self.refreshControl.endRefreshing()
    }
    
    @objc func updateMyProfile() {
        DispatchQueue.main.async {
            self.updateUserInterface()
        }
    }
    
    //MARK: - APIs
    func getProfileInformation() {
        self.hideView.isHidden = false
        AMShimmer.start(for: self.hideView)
        viewmodel.getProfileInfo()
        viewmodel.userModel.bind { [weak self]value in
            DispatchQueue.main.async {
                DispatchQueue.main.async {
                    self?.tableView.dataSource = self
                    self?.tableView.delegate = self
                    self?.tableView.reloadData()
                }
                
                DispatchQueue.main.async {
                    self?.hideView.isHidden = true
                }
            }
        }
        
        // Set View Model Event Listener
        viewmodel.error.bind { [weak self]error in
            DispatchQueue.main.async {
                self?.hideLoading()
                if error == "Internal Server Error" {
                    self?.HandleInternetConnection()
                }else {
                    DispatchQueue.main.async {
                        self?.view.makeToast(error)
                    }
                    
                }
            }
        }
    }
    
    //MARK: - Helpers
    func updateUserInterface() {
        appDelegate.networkReachability()
        
        switch Network.reachability.status {
        case .unreachable:
            DispatchQueue.main.async {
                NetworkConected.internetConect = false
                self.hideView.isHidden = true
                self.emptyView.isHidden = false
                self.HandleInternetConnection()
            }
        case .wwan:
            DispatchQueue.main.async {
                self.emptyView.isHidden = true
                self.hideView.isHidden = false
                NetworkConected.internetConect = true
                self.getProfileInformation()
            }
        case .wifi:
            DispatchQueue.main.async {
                self.emptyView.isHidden = true
                self.hideView.isHidden = false
                NetworkConected.internetConect = true
                self.getProfileInformation()
            }
        }
        
        print("Reachability Summary")
        print("Status:", Network.reachability.status)
        print("HostName:", Network.reachability.hostname ?? "nil")
        print("Reachable:", Network.reachability.isReachable)
        print("Wifi:", Network.reachability.isReachableViaWiFi)
    }
    func HandleInternetConnection() {
        if btnSelect {
            emptyView.isHidden = true
            self.view.makeToast("Network is unavailable, please try again!".localizedString)
        }else {
            emptyView.isHidden = false
            emptyImg.image = UIImage.init(named: "feednodata_img")
            emptyMessageLbl.text = "Network is unavailable, please try again!".localizedString
            triAgainBtn.alpha = 1.0
        }
    }
    func setupView() {
        tableView.register(UINib(nibName: imageCellID, bundle: nil), forCellReuseIdentifier: imageCellID)
        tableView.register(UINib(nibName: userNameCellId, bundle: nil), forCellReuseIdentifier: userNameCellId)
        tableView.register(UINib(nibName: interestsCellId, bundle: nil), forCellReuseIdentifier: interestsCellId)
        tableView.register(UINib(nibName: bestDescribesCellId, bundle: nil), forCellReuseIdentifier: bestDescribesCellId)
        tableView.register(UINib(nibName: aboutmeCellId, bundle: nil), forCellReuseIdentifier: aboutmeCellId)
        tableView.register(UINib(nibName: preferCellId, bundle: nil), forCellReuseIdentifier: preferCellId)
        
        for itm in hideImgs {
            itm.cornerRadiusView(radius: 10)
        }
        
        triAgainBtn.cornerRadiusView(radius: 8)
    }
    
    func setupSliderShow(_ cell: ImageProfileTableViewCell, _ model: ProfileObj?) {
        cell.imagesSlider.slideshowInterval = 5.0
        cell.imagesSlider.pageIndicatorPosition = .init(horizontal: .center, vertical: .top)
        cell.imagesSlider.contentScaleMode = UIViewContentMode.scaleAspectFill
        
        // optional way to show activity indicator during image load (skipping the line will show no activity indicator)
        cell.imagesSlider.activityIndicator = DefaultActivityIndicator()
        cell.imagesSlider.delegate = self
        
        cell.imagesSlider.pageIndicator = UIPageControl.withSlideshowColors()
        //        imagesSlider.setImageInputs(localSource)
        var sdWebImageSource = [SDWebImageSource(urlString: model?.userImage ?? "") ?? SDWebImageSource(urlString: "jpeg.ly/G2tv")!]
        
        for item in model?.userImages ?? [] {
            sdWebImageSource.append(SDWebImageSource(urlString: item)!)
        }
        
        cell.imagesSlider.setImageInputs(sdWebImageSource)
    }
    
    //MARK: - Actions
    @IBAction func tryAgainBtn(_ sender: Any) {
        DispatchQueue.main.async {
            self.updateUserInterface()
        }
    }
}

extension MyProfileViewController: ImageSlideshowDelegate {
    func imageSlideshow(_ imageSlideshow: ImageSlideshow, didChangeCurrentPageTo page: Int) {
        print("current page:", page)
    }
}

//MARK: - UITableViewDataSource
extension MyProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = viewmodel.userModel.value
        
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: imageCellID, for: indexPath) as? ImageProfileTableViewCell else {return UITableViewCell()}
            
            cell.ageLbl.text = "\(model?.age ?? 0)"
            if model?.gender == "other" {
                cell.genderlbl.text = "other(".localizedString + "\(model?.otherGenderName ?? "")" + ")"
            }else {
                cell.genderlbl.text = model?.gender
            }
            
            cell.parentVC = self
            setupSliderShow(cell, model)
            
            cell.HandleEditBtn = {
                self.btnSelect = true
                if NetworkConected.internetConect {
                    guard let vc = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "EditMyProfileVC") as? EditMyProfileVC else {return}
                    vc.profileModel = self.viewmodel.userModel.value
                    Defaults.isFirstLogin = false
                    self.navigationController?.pushViewController(vc, animated: true)                    
                }
            }
            return cell
        }
        else if indexPath.row == 1 {//name & username
            guard let cell = tableView.dequeueReusableCell(withIdentifier: userNameCellId, for: indexPath) as? ProfileUserNameTableViewCell else {return UITableViewCell()}
            cell.userNameLbl.text = "@\(model?.displayedUserName ?? "")"
            cell.nameLbl.text = model?.userName
            return cell
        }
        else if indexPath.row == 2 {//interests...
            guard let cell = tableView.dequeueReusableCell(withIdentifier: interestsCellId, for: indexPath) as? InterestsProfileTableViewCell else {return UITableViewCell()}
            cell.tagsListView.removeAllTags()
            for item in model?.listoftagsmodel ?? [] {
                cell.tagsListView.addTag(tagId: item.tagID, title: "#" + (item.tagname).capitalizingFirstLetter())
            }
            print("tagListView.rows \(cell.tagsListView.rows)")
            cell.tagsListViewHeight.constant = CGFloat(cell.tagsListView.rows * 25)
            
            if cell.tagsListView.rows == 1 {
                cell.tagsTopConstraint.constant = 10
                cell.tagsBottomConstraint.constant = 16
            }else if cell.tagsListView.rows == 2 {
                cell.tagsTopConstraint.constant = 12
                cell.tagsBottomConstraint.constant = 26
            }else if cell.tagsListView.rows == 3 {
                cell.tagsTopConstraint.constant = 12
                cell.tagsBottomConstraint.constant = 40
            }else {
                cell.tagsTopConstraint.constant = 12
                cell.tagsBottomConstraint.constant = 46
            }
            
            return cell
        }
        else if indexPath.row == 3 {//I am ..
            guard let cell = tableView.dequeueReusableCell(withIdentifier: bestDescribesCellId, for: indexPath) as? BestDescribesTableViewCell else {return UITableViewCell()}
            
            cell.tagsListView.removeAllTags()
            for item in model?.iamList ?? [] {
                if item.tagname.contains("#") == false {
                    cell.tagsListView.addTag(tagId: item.tagID, title: "#" + (item.tagname).capitalizingFirstLetter())
                }else {
                    print("item.tagname.contains(#)")
                }
            }
            
            print("tagListView.rows \(cell.tagsListView.rows)")
            cell.tagsListViewHeight.constant = CGFloat(cell.tagsListView.rows * 25)
            
            if cell.tagsListView.rows == 1 {
                cell.tagsTopConstraint.constant = 10
                cell.tagsBottomConstraint.constant = 16
            }else if cell.tagsListView.rows == 2 {
                cell.tagsTopConstraint.constant = 12
                cell.tagsBottomConstraint.constant = 26
            }else if cell.tagsListView.rows == 3 {
                cell.tagsTopConstraint.constant = 12
                cell.tagsBottomConstraint.constant = 40
            }else {
                cell.tagsTopConstraint.constant = 12
                cell.tagsBottomConstraint.constant = 46
            }
            
            return cell
        }
        
        else if indexPath.row == 4 {//preferTo
            guard let cell = tableView.dequeueReusableCell(withIdentifier: preferCellId, for: indexPath) as? PreferToTableViewCell else {return UITableViewCell()}
            
            cell.tagsListView.removeAllTags()
            for item in model?.prefertoList ?? [] {
                if item.tagname.contains("#") == false {
                    cell.tagsListView.addTag(tagId: item.tagID, title: "#" + (item.tagname).capitalizingFirstLetter())
                }else {
                    print("item.tagname.contains(#)")
                }
            }
            
            print("tagListView.rows \(cell.tagsListView.rows)")
            cell.tagsListViewHeight.constant = CGFloat(cell.tagsListView.rows * 25)
            
            if cell.tagsListView.rows == 1 {
                cell.tagsTopConstraint.constant = 10
                cell.tagsBottomConstraint.constant = 16
            }else if cell.tagsListView.rows == 2 {
                cell.tagsTopConstraint.constant = 12
                cell.tagsBottomConstraint.constant = 26
            }else if cell.tagsListView.rows == 3 {
                cell.tagsTopConstraint.constant = 12
                cell.tagsBottomConstraint.constant = 40
            }else {
                cell.tagsTopConstraint.constant = 12
                cell.tagsBottomConstraint.constant = 46
            }
            
            return cell
        }
        else {//more about me...
            guard let cell = tableView.dequeueReusableCell(withIdentifier: aboutmeCellId, for: indexPath) as? AboutMeTableViewCell else {return UITableViewCell()}
            cell.aboutMeLbl.text = model?.bio
            cell.titleLbl.text = "More about me..."
            return cell
        }
    }
}

//MARK: - UITableViewDelegate && UIPopoverPresentationControllerDelegate
extension MyProfileViewController: UITableViewDelegate, UIPopoverPresentationControllerDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return screenH/3
        }
        else {
            return UITableView.automaticDimension
        }
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let model = viewmodel.userModel.value
//        if indexPath.row == 0 {
//            guard let popupVC = UIViewController.viewController(withStoryboard: .Main, AndContollerID: "ShowImageVC") as? ShowImageVC else {return}
//            popupVC.modalPresentationStyle = .overCurrentContext
//            popupVC.modalTransitionStyle = .crossDissolve
//            let pVC = popupVC.popoverPresentationController
//            pVC?.permittedArrowDirections = .any
//            pVC?.delegate = self
//            pVC?.sourceRect = CGRect(x: 100, y: 100, width: 1, height: 1)
//            popupVC.imgURL = model?.userImage
//            present(popupVC, animated: true, completion: nil)
//        }
//    }
}
