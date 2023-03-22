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
import GoogleMobileAds

//MARK: - singletone
class CommunitySingletone {
    static var userID:String = ""
    static var eventID:String = ""
}

class CommunityVC: UIViewController,UIPopoverPresentationControllerDelegate,UIGestureRecognizerDelegate {
    
    //MARK: - Outlets
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
    @IBOutlet weak var bannerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var bannerView: UIView!
    
    @IBOutlet weak var superEmptyView: UIView!
    @IBOutlet weak var tryAgainBtn: UIButton!
    @IBOutlet weak var superEmptyViewLbl: UILabel!
    
    @IBOutlet weak var emptyView3: UIView!
    @IBOutlet weak var emptyLbl3: UILabel!
    
    @IBOutlet weak var adsView2: UIView!
    @IBOutlet weak var showAdsBanner2: UIView!
    @IBOutlet weak var showAdsBanner1: UIView!
    @IBOutlet weak var bannerView1: UIView!
    @IBOutlet weak var adsView1: UIView!
    @IBOutlet weak var bannerView2: UIView!
    @IBOutlet weak var closeBtn1: UIButton!
    @IBOutlet weak var closeBtn2: UIButton!
    @IBOutlet weak var showMoreTagsView: UIView!
    @IBOutlet weak var tagsMoreView: UIView!
    @IBOutlet weak var moreTagsCollectionView: UICollectionView!
    @IBOutlet weak var closeBtn: UIButton!
    
    
    //MARK: - Properties
    lazy var sendRequestMessageView = Bundle.main.loadNibNamed("SendMessageWithSendRequestView", owner: self, options: nil)?.first as? SendMessageWithSendRequestView

    let cellID1 = "FriendsCommunityCollectionViewCell"
    let cellID2 = "RecommendedEventCollectionViewCell"
    let cellID3 = "RecentlyConnectedCollectionViewCell"
    let catsCellId = "TagCollectionViewCell"

    var recommendedPeopleViewModel:RecommendedPeopleViewModel = RecommendedPeopleViewModel()
    var recommendedEventViewModel:RecommendedEventViewModel = RecommendedEventViewModel()
    var recentlyConnectedViewModel:RecentlyConnectedViewModel = RecentlyConnectedViewModel()
    var requestFriendVM:RequestFriendStatusViewModel = RequestFriendStatusViewModel()
    
    private var layout: UICollectionViewFlowLayout!
//    var bannerAdsView1: GADBannerView!
//    var bannerAdsView2: GADBannerView!
    var bannerADSView: GADBannerView!

    var currentPage : Int = 1
    var isLoadingList : Bool = false
    var activityIndiator : UIActivityIndicatorView? = UIActivityIndicatorView()
    
    var isAdConnected:Bool = false
    var isBtnSelected:Bool = false

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
    
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBar()
        title = "My Hub"
        setupViews()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadRecommendedPeople), name: Notification.Name("reloadRecommendedPeople"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadRecommendedEvent), name: Notification.Name("reloadRecommendedEvent"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateInitRequestsBarButton), name: Notification.Name("updateInitRequestsBarButton"), object: nil)
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        showMoreTagsView?.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        CancelRequest.currentTask = false
        Defaults.isCommunityVC = true
                
        Defaults.availableVC = "CommunityVC"
        
        if Defaults.isSubscribe == false {
            setupAds()
        }else {
            bannerViewHeight.constant = 0
        }
        
        if Defaults.token != "" {
            DispatchQueue.main.async {
                self.setupPagination()
                self.fetchItems()
                self.updateUserInterface()
            }
        }
        else {
            Router().toOptionsSignUpVC(IsLogout: false)
        }
        
        initRequestsBarButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        CancelRequest.currentTask = true
        
        currentPage = 1
        
        DispatchQueue.main.async {
            let contentOffset = CGPoint(x: 0, y: 0)
            self.recentlyConnectedCollectionView.setContentOffset(contentOffset, animated: false)
        }
        
        Defaults.isCommunityVC = false
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    
    //MARK: - Helper
    func setupViews() {
        moreTagsCollectionView.register(UINib(nibName: catsCellId, bundle: nil), forCellWithReuseIdentifier: catsCellId)
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
        tagsMoreView.setCornerforTop()
        closeBtn.cornerRadiusView(radius: 8)
        
        bannerView.cornerRadiusView(radius: 8)
        adsView1.setBorder()
        adsView2.setBorder()

        adsView1.cornerRadiusView(radius: 8)
        adsView2.cornerRadiusView(radius: 8)
        
        for item in hideImg10 {
            item.cornerRadiusView(radius: 5)
        }
        
        for itm in hideImgs {
            itm.cornerRadiusView(radius: 8)
        }
    }
    
    func setupAds() {
        bannerADSView = GADBannerView(adSize: GADAdSizeBanner)
        bannerADSView.adUnitID = URLs.adUnitBanner
        bannerADSView.rootViewController = self
        bannerADSView.load(GADRequest())
        bannerADSView.delegate = self
        bannerADSView.translatesAutoresizingMaskIntoConstraints = false
        bannerView.addSubview(bannerADSView)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        self.showMoreTagsView.isHidden = true
        self.tagsMoreView.isHidden = true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    func loadMoreItemsForList() {
        currentPage += 1
        getRecentlyConnectedBy(pageNumber: currentPage)
    }
    
    @objc func reloadRecommendedPeople() {
        self.getRecommendedPeopleBy(userID: CommunitySingletone.userID, previous: false)
    }
    @objc func reloadRecommendedEvent() {
        self.getRecommendedEventBy(eventID: CommunitySingletone.eventID, previous: false)
    }
    
    @objc func updateInitRequestsBarButton() {
        initRequestsBarButton()
    }
    
    //MARK: - APIs
    func getRecommendedPeopleBy(userID:String,previous:Bool) {
        let startDate = Date()

        if !isBtnSelected {
            self.hideView1.isHidden = false
            AMShimmer.start(for: hideView1)
        }else {
            self.hideView1.isHidden = true
            AMShimmer.start(for: hideView1)
        }
        
        recommendedPeopleViewModel.getRecommendedPeople(userId: userID, previous: previous)
        recommendedPeopleViewModel.recommendedPeople.bind { [weak self] value in
            let executionTimeWithSuccessVC1 = Date().timeIntervalSince(startDate)
            print("executionTimeWithSuccessVC1 \(executionTimeWithSuccessVC1) second")

            DispatchQueue.main.async {
                self?.friendsCommunityCollectionView.delegate = self
                self?.friendsCommunityCollectionView.dataSource = self
                self?.friendsCommunityCollectionView.reloadData()
                
                DispatchQueue.main.async {
                    self?.hideView1.isHidden = true
                    self?.emptyView1.isHidden = true
                }
                
                let executionTimeWithSuccessVC2 = Date().timeIntervalSince(startDate)
                print("executionTimeWithSuccessVC2 \(executionTimeWithSuccessVC2) second")
            }
        }
        
        // Set View Model Event Listener
        recommendedPeopleViewModel.error.bind { [weak self]error in
            DispatchQueue.main.async {
                if error == "Internal Server Error" {
                    self?.HandleInternetConnection()
                }else if error == "Bad Request" {
                    self?.HandleinvalidUrl()
                }else {
                    DispatchQueue.main.async {
                        self?.emptyView1.isHidden = false
                        self?.emptyLbl1.text = error
                    }
                }
            }
        }
    }
    
    func getRecommendedEventBy(eventID:String,previous:Bool) {
        self.hideView2.isHidden = false
        AMShimmer.start(for: hideView2)
        
        if !isBtnSelected {
            self.hideView2.isHidden = false
            AMShimmer.start(for: hideView2)
        }else {
            self.hideView2.isHidden = true
        }
        
        recommendedEventViewModel.getRecommendedEvent(eventId: eventID, previous: previous)
        recommendedEventViewModel.recommendedEvent.bind { [weak self] value in
            DispatchQueue.main.async {
                self?.eventCollectionView.delegate = self
                self?.eventCollectionView.dataSource = self
                self?.eventCollectionView.reloadData()

                DispatchQueue.main.async {
                    self?.hideView2.isHidden = true
                    self?.emptyView2.isHidden = true
                }                
            }
        }
        
        // Set View Model Event Listener
        recommendedEventViewModel.error.bind { [weak self]error in
            DispatchQueue.main.async {
                if error == "Internal Server Error" {
                    self?.HandleInternetConnection()
                }else if error == "Bad Request" {
                    self?.HandleinvalidUrl()
                }else {
                    DispatchQueue.main.async {
                        self?.emptyView2.isHidden = false
                        self?.emptyLbl2.text = error
                    }
                }
            }
        }
    }
    
    func getRecentlyConnectedBy(pageNumber:Int) {
        self.hideView3.isHidden = false
        AMShimmer.start(for: hideView3)
        recentlyConnectedViewModel.getRecentlyConnected(pageNumber: pageNumber)
        recentlyConnectedViewModel.recentlyConnected.bind { [weak self] value in
            DispatchQueue.main.async {
                self?.recentlyConnectedCollectionView.delegate = self
                self?.recentlyConnectedCollectionView.dataSource = self
                self?.recentlyConnectedCollectionView.reloadData()
                
                DispatchQueue.main.async {
                    self?.hideView3.isHidden = true
                    self?.emptyView3.isHidden = true
                }
            }
        }
        
        // Set View Model Event Listener
        recentlyConnectedViewModel.error.bind { [weak self]error in
            DispatchQueue.main.async {
                if error == "Internal Server Error" {
                    self?.HandleInternetConnection()
                }else {
                    DispatchQueue.main.async {
                        self?.emptyView3.isHidden = false
                        self?.emptyLbl3.text = error
                    }
                    
                }
            }
        }
    }

    
    func updateUserInterface() {
        appDelegate.networkReachability()
        
        if Network.reachability.status == .unreachable {
            DispatchQueue.main.async {
                NetworkConected.internetConect = false
                self.HandleInternetConnection()
            }
        }else {
            DispatchQueue.main.async {
                self.superEmptyView.isHidden = true
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
        self.getRecommendedPeopleBy(userID: "", previous: false)
    }
    
    func showRecommendedEvent() {
        self.getRecommendedEventBy(eventID: "", previous: false)
    }
    
    func showRecentlyConnected() {
        self.getRecentlyConnectedBy(pageNumber: 1)
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
    
    
    func sendFriendRequestWithMessage(_ model: RecommendedPeopleObj?, _ requestdate:String, _ cell: FriendsCommunityCollectionViewCell) {
        self.sendRequestMessageView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        self.sendRequestMessageView?.HandleSendBtn = {
            print("Send")
            self.sendRequest(cell, model, requestdate,self.sendRequestMessageView?.messageTxtView.text ?? "")
        }
        
        self.view.addSubview((self.sendRequestMessageView)!)
    }
    
    func sendRequest(_ cell:FriendsCommunityCollectionViewCell, _ model:RecommendedPeopleObj?, _ actionDate:String,_ message:String) {
        self.isBtnSelected = true
        Defaults.bannerAdsCount1 += 1
        self.changeTitleBtns(btn: cell.sendRequestBtn, title: "Sending...".localizedString)
        self.requestFriendVM.requestFriendStatus(withID: model?.userId ?? "", AndKey: 1, isNotFriend: true, requestdate: actionDate,message: message) { error, message in
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
                self.getRecommendedPeopleBy(userID: model?.userId ?? "", previous: false)
            }
        }
    }
    
    //MARK: - Actions
    
    @IBAction func tryAgainBtn(_ sender: Any) {
        self.isBtnSelected = false
        updateUserInterface()
    }
    
    @IBAction func closeBtn1(_ sender: Any) {
        Defaults.bannerAdsCount1 = 0
        self.showAdsBanner1.isHidden = true
    }
    
    @IBAction func closeBtn2(_ sender: Any) {
        Defaults.bannerAdsCount2 = 0
        self.showAdsBanner2.isHidden = true
    }
    
    @IBAction func closeBtn(_ sender: Any) {
        self.tagsMoreView.isHidden = true
        self.showMoreTagsView.isHidden = true
    }
    
}

//MARK: - UICollectionViewDataSource
extension CommunityVC:UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == moreTagsCollectionView {
            return recommendedPeopleViewModel.recommendedPeople.value?.matchedInterests?.count ?? 0
        }
        else if collectionView == recentlyConnectedCollectionView {
            return recentlyConnectedViewModel.recentlyConnected.value?.data?.count ?? 0
        }else {
            return 1
        }
    }
    

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == friendsCommunityCollectionView {
            guard let cell = friendsCommunityCollectionView.dequeueReusableCell(withReuseIdentifier: cellID1, for: indexPath) as? FriendsCommunityCollectionViewCell else {return UICollectionViewCell()}
            
            let actionDate = formatterDate.string(from: Date())

            let model = recommendedPeopleViewModel.recommendedPeople.value
            cell.model = model
            
            cell.HandleViewProfileBtn = {
                guard let vc = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "FriendProfileViewController") as? FriendProfileViewController else {return}
                vc.userID = model?.userId ?? ""
                CommunitySingletone.userID = model?.userId ?? ""
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
            cell.HandleSkipBtn = {
                self.isBtnSelected = true
//                Defaults.bannerAdsCount1 += 1
                self.getRecommendedPeopleBy(userID: model?.userId ?? "", previous: false)
            }

            cell.HandleNextBtn = {
                self.isBtnSelected = true
//                Defaults.bannerAdsCount1 += 1
                self.getRecommendedPeopleBy(userID: model?.userId ?? "", previous: false)
            }
            cell.HandlePreviuosBtn = {
                self.isBtnSelected = true
//                Defaults.bannerAdsCount1 += 1
                self.getRecommendedPeopleBy(userID: model?.userId ?? "", previous: true)
            }
            cell.HandleSendRequestBtn = {
                self.sendFriendRequestWithMessage(model, actionDate, cell)
            }
            return cell
        }
        else if collectionView == eventCollectionView {
            guard let cell = eventCollectionView.dequeueReusableCell(withReuseIdentifier: cellID2, for: indexPath) as? RecommendedEventCollectionViewCell else {return UICollectionViewCell()}
            
            let model = recommendedEventViewModel.recommendedEvent.value
            cell.model = model
            
            cell.HandleSkipBtn = {
                self.isBtnSelected = true
                self.getRecommendedEventBy(eventID: model?.eventId ?? "", previous: false)
            }
            
            cell.HandlePreviuosBtn = {
                self.isBtnSelected = true
                self.getRecommendedEventBy(eventID: model?.eventId ?? "", previous: true)
            }
            
            cell.HandleNextBtn = {
                self.isBtnSelected = true
                self.getRecommendedEventBy(eventID: model?.eventId ?? "", previous: false)
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
        else if collectionView == recentlyConnectedCollectionView {
            guard let cell = recentlyConnectedCollectionView.dequeueReusableCell(withReuseIdentifier: cellID3, for: indexPath) as? RecentlyConnectedCollectionViewCell else {return UICollectionViewCell()}
            let model = recentlyConnectedViewModel.recentlyConnected.value?.data?[indexPath.row]
            cell.model = model
            return cell
        }
        else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: catsCellId, for: indexPath) as? TagCollectionViewCell else {return UICollectionViewCell()}
            
            let model = recommendedPeopleViewModel.recommendedPeople.value?.matchedInterests?[indexPath.row]
            cell.tagNameLbl.text = "#\(model ?? "")".capitalizingFirstLetter()
            cell.editBtn.isHidden = true
            cell.editBtnWidth.constant = 0
            cell.containerView.backgroundColor = UIColor.FriendzrColors.primary
            cell.layoutSubviews()
            return cell
        }
    }
}

//MARK: - UICollectionViewDelegate
extension CommunityVC:UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let wid = collectionView.frame.width
        let hig = collectionView.frame.height
        
        if collectionView == moreTagsCollectionView {
            let model = recommendedPeopleViewModel.recommendedPeople.value?.matchedInterests?[indexPath.row]
            let width = model?.widthOfString(usingFont: UIFont(name: "Montserrat-Medium", size: 12)!)
            return CGSize(width: width! + 50, height: 45)
        }else  if collectionView == recentlyConnectedCollectionView {
            return CGSize(width: wid/3.4, height: hig)
        }else {
            return CGSize(width: wid, height: hig)
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
        if collectionView == recentlyConnectedCollectionView {
            if Defaults.token != "" {
                if NetworkConected.internetConect {
                    if recentlyConnectedViewModel.recentlyConnected.value?.data?.count != 0 {
                        guard let vc = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "FriendProfileViewController") as? FriendProfileViewController else {return}
                        vc.userID = recentlyConnectedViewModel.recentlyConnected.value?.data?[indexPath.row].userId ?? ""
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }else {
                Router().toOptionsSignUpVC(IsLogout: false)
            }
        }
    }
}

//MARK: - HorizontalPaginationManagerDelegate
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
            if self.currentPage < self.recentlyConnectedViewModel.recentlyConnected.value?.totalPages ?? 0 {
                print("self.currentPage >> \(self.currentPage)")
                self.loadMoreItemsForList()
            }else {
                self.paginationManager.removeRightLoader()
            }
            
            completion(true)
        }
    }
}


//MARK: - initRequestsBarButton
extension CommunityVC {
    
    //init requests page
    func initRequestsBarButton() {
        let badgeCount = UILabel(frame: CGRect(x: 22, y: 2, width: 16, height: 16))
        badgeCount.layer.borderColor = UIColor.clear.cgColor
        badgeCount.layer.borderWidth = 2
        badgeCount.layer.cornerRadius = badgeCount.bounds.size.height / 2
        badgeCount.textAlignment = .center
        badgeCount.layer.masksToBounds = true
        badgeCount.textColor = .white
        badgeCount.font = badgeCount.font.withSize(12)
        badgeCount.backgroundColor = .red
        badgeCount.text = "\(Defaults.frindRequestNumber)"

        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        let image = UIImage(named: "request_unselected_ic")?.withRenderingMode(.alwaysOriginal)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(goToRequestsPage), for: .touchUpInside)
        
        if Defaults.frindRequestNumber > 0 {
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
        transition.type = CATransitionType.reveal
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.fillMode = CAMediaTimingFillMode.forwards
        transition.duration = 3.0
        transition.subtype = CATransitionSubtype.fromRight
        collectionView.layer.add(transition, forKey: "UICollectionViewReloadDataAnimationKey")
        collectionView.reloadData()
    }
}

//MARK: - GADBannerViewDelegate
extension CommunityVC:GADBannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("bannerViewDidReceiveAd")
//        addBannerViewToView(bannerView2)
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print("bannerView:didFailToReceiveAdWithError: \(error.localizedDescription)")
        bannerViewHeight.constant = 0
    }
    
    func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
        print("bannerViewDidRecordImpression")
    }
    
    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("bannerViewWillPresentScreen")
    }
    
    func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("bannerViewWillDIsmissScreen")
    }
    
    func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("bannerViewDidDismissScreen")
    }
}


//extension CommunityVC : ViewDidclicked {
//    func viewTapped() {
//        self.isBtnSelected = true
//        let model = recommendedPeopleViewModel.recommendedPeople.value
//        self.getRecommendedPeopleBy(userID: model?.userId ?? "")
//    }
//}
