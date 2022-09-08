//
//  CommunityVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 24/08/2022.
//

import UIKit
import AMShimmer
import SDWebImage
import FirebaseAnalytics

class CommunitySingletone {
    static var userID:String = ""
    static var eventID:String = ""
}

class CommunityVC: UIViewController {
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var superView: UIView!
    @IBOutlet weak var friendsCommunityCollectionView: UICollectionView!
    @IBOutlet weak var recentlyConnectedCollectionView: UICollectionView!
    @IBOutlet weak var eventCollectionView: UICollectionView!
    
    @IBOutlet weak var hideView1: UIView!
    @IBOutlet weak var hideView2: UIView!
    @IBOutlet weak var hideView3: UIView!
    
    @IBOutlet weak var emptyView1: UIView!
    @IBOutlet weak var emptyView2: UIView!
    @IBOutlet weak var emptyLbl1: UILabel!
    @IBOutlet weak var emptyLbl2: UILabel!
    
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
    
    @IBOutlet weak var superEmptyView: UIView!
    @IBOutlet weak var tryAgainBtn: UIButton!
    @IBOutlet weak var superEmptyViewLbl: UILabel!
    
    @IBOutlet weak var emptyView3: UIView!
    @IBOutlet weak var emptyLbl3: UILabel!
    
    
//    let cellID1 = "FriendsCommunityCollectionViewCell"
    let cellID1 = "NewFriendsCommunityCollectionViewCell"
    let cellID2 = "RecommendedEventCollectionViewCell"
    let cellID3 = "RecentlyConnectedCollectionViewCell"
    
    var viewmodel:CommunityViewModel = CommunityViewModel()
    var requestFriendVM:RequestFriendStatusViewModel = RequestFriendStatusViewModel()
    
    private var layout: UICollectionViewFlowLayout!
    
    var currentPage : Int = 1
    var isLoadingList : Bool = false
    var activityIndiator : UIActivityIndicatorView? = UIActivityIndicatorView()
    
    private let formatterDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter
    }()
    
    private let formatterTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()
    
    private lazy var paginationManager: HorizontalPaginationManager = {
        let manager = HorizontalPaginationManager(scrollView: self.recentlyConnectedCollectionView)
        manager.delegate = self
        return manager
    }()
    
    private var isDragging: Bool {
        return self.recentlyConnectedCollectionView.isDragging
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBar()
        title = "Community"
        setupViews()
        

        NotificationCenter.default.addObserver(self, selector: #selector(reloadRecommendedPeople), name: Notification.Name("reloadRecommendedPeople"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadRecommendedEvent), name: Notification.Name("reloadRecommendedEvent"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateInitRequestsBarButton), name: Notification.Name("updateInitRequestsBarButton"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        CancelRequest.currentTask = false
        Defaults.isCommunityVC = true
        
        if Defaults.token != "" {
            DispatchQueue.main.async {
                self.setupPagination()
                self.fetchItems()
                self.updateUserInterface()
            }
        }else {
            Router().toOptionsSignUpVC(IsLogout: false)
        }
        
        initRequestsBarButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        CancelRequest.currentTask = true

        currentPage = 1
        let contentOffset = CGPoint(x: 0, y: 0)
        self.recentlyConnectedCollectionView.setContentOffset(contentOffset, animated: false)
        Defaults.isCommunityVC = false
    }
    
    func setupViews() {
        friendsCommunityCollectionView.register(UINib(nibName: cellID1, bundle: nil), forCellWithReuseIdentifier: cellID1)
        eventCollectionView.register(UINib(nibName: cellID2, bundle: nil), forCellWithReuseIdentifier: cellID2)
        recentlyConnectedCollectionView.register(UINib(nibName: cellID3, bundle: nil), forCellWithReuseIdentifier: cellID3)
        tryAgainBtn.cornerRadiusView(radius: 8)
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
    
    func loadMoreItemsForList() {
        currentPage += 1
        getRecentlyConnectedBy(pageNumber: currentPage)
    }
    
    @objc func reloadRecommendedPeople() {
        self.getRecommendedPeopleBy(userID: CommunitySingletone.userID)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.showEmptyView1()
        }
    }
    @objc func reloadRecommendedEvent() {
        self.getRecommendedEventBy(eventID: CommunitySingletone.eventID)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.showEmptyView2()
        }
    }
    
    @objc func updateInitRequestsBarButton() {
        initRequestsBarButton()
    }
    
    //MARK: - APIs
    func getRecommendedPeopleBy(userID:String) {
        self.hideView1.isHidden = false
        AMShimmer.start(for: hideView1)
        viewmodel.getRecommendedPeople(userId: userID)
        viewmodel.recommendedPeople.bind { [unowned self] value in
            DispatchQueue.main.async {
                self.friendsCommunityCollectionView.delegate = self
                self.friendsCommunityCollectionView.dataSource = self
                self.friendsCommunityCollectionView.reloadData()
                
                DispatchQueue.main.async {
                    self.hideView1.isHidden = true
                    AMShimmer.stop(for: self.hideView1)
                }
            }
        }
        
        // Set View Model Event Listener
        viewmodel.error.bind { [unowned self]error in
            DispatchQueue.main.async {
                if error == "Internal Server Error" {
                    self.HandleInternetConnection()
                }else if error == "Bad Request" {
                    self.HandleinvalidUrl()
                }else {
                    DispatchQueue.main.async {
                        self.view.makeToast(error)
                    }
                }
            }
        }
    }
    
    func getRecommendedEventBy(eventID:String) {
        self.hideView2.isHidden = false
        AMShimmer.start(for: hideView2)
        viewmodel.getRecommendedEvent(eventId: eventID)
        viewmodel.recommendedEvent.bind { [unowned self] value in
            DispatchQueue.main.async {
                self.eventCollectionView.delegate = self
                self.eventCollectionView.dataSource = self
                self.eventCollectionView.reloadData()
                
                DispatchQueue.main.async {
                    self.hideView2.isHidden = true
                    AMShimmer.stop(for: self.hideView2)
                }
            }
        }
        
        // Set View Model Event Listener
        viewmodel.error.bind { [unowned self]error in
            DispatchQueue.main.async {
                if error == "Internal Server Error" {
                    self.HandleInternetConnection()
                }else if error == "Bad Request" {
                    self.HandleinvalidUrl()
                }else {
                    DispatchQueue.main.async {
                        self.view.makeToast(error)
                    }
                }
            }
        }
    }
    
    func getRecentlyConnectedBy(pageNumber:Int) {
        self.hideView3.isHidden = false
        AMShimmer.start(for: hideView3)
        viewmodel.getRecentlyConnected(pageNumber: pageNumber)
        viewmodel.recentlyConnected.bind { [unowned self] value in
            DispatchQueue.main.async {
                self.recentlyConnectedCollectionView.delegate = self
                self.recentlyConnectedCollectionView.dataSource = self
                self.recentlyConnectedCollectionView.reloadData()
                
                DispatchQueue.main.async {
                    self.hideView3.isHidden = true
                    AMShimmer.stop(for: self.hideView3)
                }
            }
        }
        
        // Set View Model Event Listener
        viewmodel.error.bind { [unowned self]error in
            DispatchQueue.main.async {
                if error == "Internal Server Error" {
                    self.HandleInternetConnection()
                }else {
                    DispatchQueue.main.async {
                        self.view.makeToast(error)
                    }
                    
                }
            }
        }
    }

    
    func updateUserInterface() {
        appDelegate.networkReachability()
        
        switch Network.reachability.status {
        case .unreachable:
            DispatchQueue.main.async {
                NetworkConected.internetConect = false
                self.HandleInternetConnection()
            }
        case .wwan:
            DispatchQueue.main.async {
                self.superEmptyView.isHidden = true
                NetworkConected.internetConect = true
                self.showRecommendedPeople()
                self.showRecommendedEvent()
                self.showRecentlyConnected()
            }
        case .wifi:
            self.superEmptyView.isHidden = true
            DispatchQueue.main.async {
                NetworkConected.internetConect = true
                self.showRecommendedPeople()
                self.showRecommendedEvent()
                self.showRecentlyConnected()
            }
        }
        
        print("Reachability Summary")
        print("Status:", Network.reachability.status)
        print("HostName:", Network.reachability.hostname ?? "nil")
        print("Reachable:", Network.reachability.isReachable)
        print("Wifi:", Network.reachability.isReachableViaWiFi)
    }
    
    func showRecommendedPeople() {
        self.getRecommendedPeopleBy(userID: "")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.showEmptyView1()
        }
    }
    
    func showRecommendedEvent() {
        self.getRecommendedEventBy(eventID: "")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.showEmptyView2()
        }
    }
    
    func showRecentlyConnected() {
        self.getRecentlyConnectedBy(pageNumber: 1)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.showEmptyView3()
        }
    }
    
    func HandleInternetConnection() {
        superEmptyView.isHidden = false
        superEmptyViewLbl.text = "Network is unavailable, please try again!".localizedString
        tryAgainBtn.alpha = 1.0
    }
    
    func HandleinvalidUrl() {
        superEmptyView.isHidden = false
        superEmptyViewLbl.text = "Sorry for that we have some maintaince with our servers please try again in few moments.".localizedString
        tryAgainBtn.alpha = 1.0
    }
    
    func changeTitleBtns(btn:UIButton,title:String) {
        btn.setTitle(title, for: .normal)
    }
    func showEmptyView1() {
        DispatchQueue.main.async {
            if self.viewmodel.recommendedPeople.value != nil {
                self.emptyView1.isHidden = true
            }else {
                self.emptyView1.isHidden = false
                self.emptyLbl1.text = "No more users, please try again later."
            }
        }
    }
    
    func showEmptyView2() {
        DispatchQueue.main.async {
            if self.viewmodel.recommendedEvent.value != nil {
                self.emptyView2.isHidden = true
            }
            else {
                self.emptyView2.isHidden = false
                self.emptyLbl2.text = "No more events, please try again later."
            }
        }
    }
    
    func showEmptyView3() {
        DispatchQueue.main.async {
            if self.viewmodel.recentlyConnected.value?.data?.count != 0 {
                self.emptyView3.isHidden = true
            }else {
                self.emptyView3.isHidden = false
                self.emptyLbl3.text = "No more users, please try again later."
            }
        }
    }
    
    @IBAction func tryAgainBtn(_ sender: Any) {
        updateUserInterface()
    }
}

extension CommunityVC:UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView != recentlyConnectedCollectionView {
            return 1
        }else {
            return viewmodel.recentlyConnected.value?.data?.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == friendsCommunityCollectionView {
            guard let cell = friendsCommunityCollectionView.dequeueReusableCell(withReuseIdentifier: cellID1, for: indexPath) as? NewFriendsCommunityCollectionViewCell else {return UICollectionViewCell()}
            
            let actionDate = formatterDate.string(from: Date())
//            let actionTime = formatterTime.string(from: Date())
            
            let model = viewmodel.recommendedPeople.value
            cell.nameTitleLbl.text = model?.name
            cell.milesLbl.text = "\(model?.distanceFromYou?.rounded(toPlaces: 1) ?? 0.0) miles from you"
            cell.interestMatchLbl.text = "\(model?.interestMatchPercent?.rounded(toPlaces: 1) ?? 0.0) % interest match"
            cell.userImg.sd_setImage(with: URL(string: model?.image ?? "" ), placeholderImage: UIImage(named: "placeHolderApp"))
            cell.tagsList = model?.matchedInterests ?? []
            
            if model?.matchedInterests?.count == 0 {
                cell.noAvailableInterestLbl.isHidden = false
                cell.collectionView.isHidden = true
            }else {
                cell.noAvailableInterestLbl.isHidden = true
                cell.collectionView.isHidden = false
            }
            
            cell.collectionView.reloadData()
//            cell.tagsView.removeAllTags()
//            for item in model?.matchedInterests ?? [] {
//                cell.tagsView.addTag(tagId: item, title: "#" + (item).capitalizingFirstLetter()).isSelected = true
//            }
//
//            if cell.tagsView.rows > 4 {
//                print("cell.tagsView.rows > 4")
//            }else {
//                print("cell.tagsView.rows < 4")
//            }
//
            cell.HandleViewProfileBtn = {
                guard let vc = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "FriendProfileViewController") as? FriendProfileViewController else {return}
                vc.userID = model?.userId ?? ""
                CommunitySingletone.userID = model?.userId ?? ""
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
            cell.HandleSkipBtn = {
                self.animationFor(collectionView: self.friendsCommunityCollectionView)
                self.getRecommendedPeopleBy(userID: model?.userId ?? "")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.showEmptyView1()
                }
            }
            
            cell.HandleSendRequestBtn = {
                self.changeTitleBtns(btn: cell.sendRequestBtn, title: "Sending...".localizedString)
                self.requestFriendVM.requestFriendStatus(withID: model?.userId ?? "", AndKey: 1, requestdate: actionDate) { error, message in
                    if let error = error {
                        DispatchQueue.main.async {
                            self.view.makeToast(error)
                        }
                        return
                    }
                    
                    guard let _ = message else {return}
                    DispatchQueue.main.async {
                        self.changeTitleBtns(btn: cell.sendRequestBtn, title: "Send Request".localizedString)
                    }
                    
                    DispatchQueue.main.async {
                        self.animationFor(collectionView: self.friendsCommunityCollectionView)
                        self.getRecommendedPeopleBy(userID: model?.userId ?? "")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self.showEmptyView1()
                        }
                    }
                }
            }
            return cell
        }
        else if collectionView == eventCollectionView {
            guard let cell = eventCollectionView.dequeueReusableCell(withReuseIdentifier: cellID2, for: indexPath) as? RecommendedEventCollectionViewCell else {return UICollectionViewCell()}
            
            let model = viewmodel.recommendedEvent.value
            cell.enventNameLbl.text = model?.title
            cell.eventImg.sd_setImage(with: URL(string: model?.image ?? "" ), placeholderImage: UIImage(named: "placeHolderApp"))
            cell.infoLbl.text = model?.descriptionEvent
            cell.attendeesLbl.text = "Attendees: \(model?.attendees ?? 0) / \(model?.from ?? 0)"
            cell.startDateLbl.text = model?.eventDate
            cell.bgView.backgroundColor =  UIColor.color((model?.eventtypecolor ?? ""))
            
            cell.HandleSkipBtn = {
                self.animationFor(collectionView: self.eventCollectionView)
                self.getRecommendedEventBy(eventID: model?.eventId ?? "")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.showEmptyView2()
                }
            }
                        
            cell.HandleExpandBtn = {
                if model?.eventtype == "External" {
                    guard let vc = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "ExternalEventDetailsVC") as? ExternalEventDetailsVC else {return}
                    vc.eventId = model?.eventId ?? ""
                    self.navigationController?.pushViewController(vc, animated: true)
                }else {
                    guard let vc = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "EventDetailsViewController") as? EventDetailsViewController else {return}
                    vc.eventId = model?.eventId ?? ""
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
            return cell
        }
        else {
            guard let cell = recentlyConnectedCollectionView.dequeueReusableCell(withReuseIdentifier: cellID3, for: indexPath) as? RecentlyConnectedCollectionViewCell else {return UICollectionViewCell()}
            let model = viewmodel.recentlyConnected.value?.data?[indexPath.row]
            cell.userImage.sd_setImage(with: URL(string: model?.image ?? "" ), placeholderImage: UIImage(named: "placeHolderApp"))
            cell.userNameLbl.text = model?.name
            cell.connectedDateLbl.text = "Connected: \(model?.date ?? "")"
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == friendsCommunityCollectionView {
            
        }
        else if collectionView == eventCollectionView {
            let model = viewmodel.recommendedEvent.value
            
            if model?.eventtype == "External" {
                guard let vc = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "ExternalEventDetailsVC") as? ExternalEventDetailsVC else {return}
                vc.eventId = model?.eventId ?? ""
                self.navigationController?.pushViewController(vc, animated: true)
            }else {
                guard let vc = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "EventDetailsViewController") as? EventDetailsViewController else {return}
                vc.eventId = model?.eventId ?? ""
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        else {
            if Defaults.token != "" {
                if NetworkConected.internetConect {
                    if viewmodel.recentlyConnected.value?.data?.count != 0 {
                        guard let vc = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "FriendProfileViewController") as? FriendProfileViewController else {return}
                        vc.userID = viewmodel.recentlyConnected.value?.data?[indexPath.row].userId ?? ""
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }else {
                Router().toOptionsSignUpVC(IsLogout: false)
            }
        }
    }
}

extension CommunityVC: HorizontalPaginationManagerDelegate {
    
    private func setupPagination() {
        self.paginationManager.refreshViewColor = .clear
        self.paginationManager.loaderColor = .gray
    }
    
    private func fetchItems() {
        self.paginationManager.initialLoad()
    }
    
    func refreshAll(completion: @escaping (Bool) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.setupPagination()
            self.currentPage = 1
            self.getRecentlyConnectedBy(pageNumber: self.currentPage)
            self.recentlyConnectedCollectionView.reloadData()
            completion(true)
        }
    }
    
    func loadMore(completion: @escaping (Bool) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.setupPagination()
            self.isLoadingList = true
            if self.currentPage < self.viewmodel.recentlyConnected.value?.totalPages ?? 0 {
                print("self.currentPage >> \(self.currentPage)")
                self.loadMoreItemsForList()
            }else {
//                self.paginationManager.removeLeftLoader()
                self.paginationManager.removeRightLoader()
            }
            
            completion(true)
        }
    }
}

extension CommunityVC {
    
    //init requests page
    func initRequestsBarButton() {
        let badgeCount = UILabel(frame: CGRect(x: 87, y: -03, width: 16, height: 16))
        badgeCount.layer.borderColor = UIColor.clear.cgColor
        badgeCount.layer.borderWidth = 2
        badgeCount.layer.cornerRadius = badgeCount.bounds.size.height / 2
        badgeCount.textAlignment = .center
        badgeCount.layer.masksToBounds = true
        badgeCount.textColor = .white
        badgeCount.font = badgeCount.font.withSize(12)
        badgeCount.backgroundColor = .red
        badgeCount.text = "\(Defaults.frindRequestNumber)"

        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        button.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        button.setTitle("Requests", for: .normal)
        let image = UIImage(named: "request_unselected_ic")?.withRenderingMode(.automatic)
        button.setImage(image, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont(name: "Montserrat-Medium", size: 10)!
        button.imageEdgeInsets.left = 80
        button.titleEdgeInsets.left = -20
        button.addTarget(self, action: #selector(goToRequestsPage), for: .touchUpInside)
        
        if Defaults.frindRequestNumber != 0 {
            button.addSubview(badgeCount)
        }else {
            button.willRemoveSubview(badgeCount)
        }
        
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    @objc func goToRequestsPage() {
        guard let vc = UIViewController.viewController(withStoryboard: .Request, AndContollerID: "RequestVC") as? RequestVC else {return}
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func animationFor(collectionView:UICollectionView) {
        let transition = CATransition()
        transition.type = CATransitionType.push
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.fillMode = CAMediaTimingFillMode.removed
        transition.duration = 1.2
        transition.subtype = CATransitionSubtype.fromRight
        collectionView.layer.add(transition, forKey: "UICollectionViewReloadDataAnimationKey")
        // Update your data source here
        collectionView.reloadData()
    }
}
