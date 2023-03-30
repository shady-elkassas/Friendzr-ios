//
//  FavoriteVC.swift
//  Friendzr
//
//  Created by Shady Elkassas on 27/03/2023.
//

import UIKit
import SwiftUI
import ListPlaceholder
import Network
import SDWebImage
import AppTrackingTransparency

class FavoriteVC: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var tryAgainBtn: UIButton!
    @IBOutlet weak var emptyLbl: UILabel!
    @IBOutlet weak var emptyImg: UIImageView!
    @IBOutlet weak var hideView: UIView!
    @IBOutlet var hideImgs: [UIImageView]!
    @IBOutlet var subhideImgs: [UIImageView]!
    
    //MARK: - Properties
    let cellID = "EventTableViewCell"
    let emptyCellID = "EmptyViewTableViewCell"
    
    var viewmodel:FavoriteViewModel = FavoriteViewModel()
    var refreshControl = UIRefreshControl()
    var cellSelect:Bool = false
    var currentPage : Int = 1
    var isLoadingList : Bool = false

    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "My Events".localizedString
        setupView()
        
        initBackButton()
        pullToRefresh()
//        NotificationCenter.default.addObserver(self, selector: #selector(reloadAllEvents), name: Notification.Name("reloadAllEvents"), object: nil)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Defaults.availableVC = "EventsVC"
        print("availableVC >> \(Defaults.availableVC)")
        
        CancelRequest.currentTask = false
        
        setupHideView()
        self.currentPage = 1
        
        DispatchQueue.main.async {
            self.updateUserInterface()
        }
        
        setupNavBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.hideLoading()
        CancelRequest.currentTask = true
    }
    
    //MARK:- APIs
    func loadMoreEventItems(){
        currentPage += 1
        getAllEvents(pageNumber: currentPage)
    }
    
    func getAllEvents(pageNumber:Int) {
        self.hideView.isHidden = false
        hideView.hideLoader()
        viewmodel.getMyFavoritesEvents(pageNumber: pageNumber)
        viewmodel.events.bind { [weak self] value in
            DispatchQueue.main.async {
                DispatchQueue.main.async {
                    self?.hideView.hideLoader()
                    self?.hideView.isHidden = true
                }
                
                self?.tableView.delegate = self
                self?.tableView.dataSource = self
                self?.tableView.reloadData()
                self?.initTotalEventsBarButton(total: value.totalRecords ?? 0)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self?.isLoadingList = false
                    self?.tableView.tableFooterView = nil
                }
            }
        }
        
        // Set View Model Event Listener
        viewmodel.error.bind { [weak self]error in
            DispatchQueue.main.async {
                if error == "Internal Server Error" {
                    self?.HandleInternetConnection()
                }else if error == "Bad Request" {
                    self?.HandleinvalidUrl()
                }else {
                    DispatchQueue.main.async {
                        self?.view.makeToast(error)
                    }
                    
                }
            }
        }
    }
    
    func LoadAllEvents(pageNumber:Int) {
        let startDate = Date()
        self.hideView.isHidden = false
        hideView.showLoader()
        viewmodel.getMyFavoritesEvents(pageNumber: pageNumber)
        viewmodel.events.bind { [weak self] value in
            DispatchQueue.main.async {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self?.hideView.hideLoader()
                    self?.hideView.isHidden = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self?.tableView.delegate = self
                    self?.tableView.dataSource = self
                    self?.tableView.reloadData()
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self?.initTotalEventsBarButton(total: value.totalRecords ?? 0)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self?.isLoadingList = false
                        self?.tableView.tableFooterView = nil
                    }
                }
                
                let executionTimeWithSuccess = Date().timeIntervalSince(startDate)
                print("executionTimeWithSuccess \(executionTimeWithSuccess) second")

            }
        }
        
        // Set View Model Event Listener
        viewmodel.error.bind { [weak self]error in
            DispatchQueue.main.async {
                if error == "Internal Server Error" {
                    self?.HandleInternetConnection()
                }else if error == "Bad Request" {
                    self?.HandleinvalidUrl()
                }else {
                    DispatchQueue.main.async {
                        self?.view.makeToast(error)
//                        self?.onPopup()
                    }
                }
            }
        }
    }
    
    //MARK: - Helper
    
    //internet cpnnection for APIs
    func updateUserInterface() {
        appDelegate.networkReachability()
        switch Network.reachability.status {
        case .unreachable:
            DispatchQueue.main.async {
                self.emptyView.isHidden = false
                NetworkConected.internetConect = false
                self.HandleInternetConnection()
            }
        case .wwan:
            DispatchQueue.main.async {
                NetworkConected.internetConect = true
                self.emptyView.isHidden = true
                self.LoadAllEvents(pageNumber: 1)
            }
        case .wifi:
            DispatchQueue.main.async {
                NetworkConected.internetConect = true
                self.emptyView.isHidden = true
                self.LoadAllEvents(pageNumber: 1)
            }
        }
        
        print("Reachability Summary")
        print("Status:", Network.reachability.status)
        print("HostName:", Network.reachability.hostname ?? "nil")
        print("Reachable:", Network.reachability.isReachable)
        print("Wifi:", Network.reachability.isReachableViaWiFi)
    }
    
    //Handle invalid Url
    func HandleinvalidUrl() {
        emptyView.isHidden = false
        emptyImg.image = UIImage.init(named: "myEventnodata_img")
        emptyLbl.text = "sorry for that we have some maintaince with our servers please try again in few moments".localizedString
        tryAgainBtn.alpha = 1.0
    }
    
    //Handle Internet Connection
    func HandleInternetConnection() {
        if cellSelect {
            emptyView.isHidden = true
            self.view.makeToast("Network is unavailable, please try again!".localizedString)
        }else {
            emptyView.isHidden = false
            emptyImg.image = UIImage.init(named: "myEventnodata_img")
            emptyLbl.text = "Network is unavailable, please try again!".localizedString
            tryAgainBtn.alpha = 1.0
        }
    }
    
    //setup all views
    func setupView() {
        tableView.register(UINib(nibName: cellID, bundle: nil), forCellReuseIdentifier: cellID)
        tableView.register(UINib(nibName: emptyCellID, bundle: nil), forCellReuseIdentifier: emptyCellID)
        tryAgainBtn.cornerRadiusView(radius: 8)
    }
    
    // pull to refresh
    func pullToRefresh() {
        self.refreshControl.attributedTitle = NSAttributedString(string: "")
        self.refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        self.tableView.addSubview(refreshControl)
    }
    @objc func didPullToRefresh() {
        print("Refersh")
        currentPage = 1
        DispatchQueue.main.async {
            self.updateUserInterface()
        }
        self.refreshControl.endRefreshing()
    }
    
    //create footer for table view when loading more events
    func createFooterView() -> UIView {
        let footerview = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 100))
        let indicatorView = UIActivityIndicatorView()
        indicatorView.center = footerview.center
        footerview.addSubview(indicatorView)
        indicatorView.startAnimating()
        return footerview
    }
    
    //hide shimmer views
    func setupHideView() {
        for itm in hideImgs {
            itm.cornerRadiusView(radius: 10)
        }
        
        for item in subhideImgs {
            item.cornerRadiusView(radius: 5)
        }
    }
    
    //MARK:- Actions
    @IBAction func tryAgainBtn(_ sender: Any) {
        cellSelect = false
        updateUserInterface()
    }
}

//MARK: - Extensions UITableViewDataSource
extension FavoriteVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewmodel.events.value?.data?.count != 0 {
            return viewmodel.events.value?.data?.count ?? 0
        }else {
            return 1
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if viewmodel.events.value?.data?.count != 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? EventTableViewCell else {return UITableViewCell()}
            let model = viewmodel.events.value?.data?[indexPath.row]
            cell.attendeesLbl.text = "Attendees : ".localizedString + "\(model?.joined ?? 0) / \(model?.totalnumbert ?? 0)"
            cell.eventTitleLbl.text = model?.title
            cell.categoryLbl.text = model?.categorie
            cell.dateLbl.text = model?.eventdate
            
            cell.eventImg.sd_imageIndicator = SDWebImageActivityIndicator.gray
            cell.eventImg.sd_setImage(with: URL(string: model?.image ?? "" ), placeholderImage: UIImage(named: "placeHolderApp"))
            
            
            
            if model?.key == 1 {
                if model?.eventHasExpired == true {
                    cell.editBtn.isHidden = true
                }else {
                    cell.editBtn.isHidden = false
                }
            }else {
                cell.editBtn.isHidden = true
            }
            
            cell.HandleEditBtn = {
                if NetworkConected.internetConect == true {
                    guard let vc = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "EditEventsVC") as? EditEventsVC else {return}
                    vc.eventModel = model
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            return cell
        }else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: emptyCellID, for: indexPath) as? EmptyViewTableViewCell else {return UITableViewCell()}
            cell.controlBtn.isHidden = true
            cell.emptyImg.image = UIImage(named: "myEventnodata_img")
            cell.titleLbl.text = "No events booked as yet, \nHead to Map and find out what’s coming up near you"
            return cell
        }
    }
}

//MARK: - Extensions UITableViewDelegate
extension FavoriteVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if viewmodel.events.value?.data?.count != 0 {
            return 200
        }else {
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        cellSelect = true
        let model = viewmodel.events.value?.data?[indexPath.row]
        
        if NetworkConected.internetConect == true {
            if viewmodel.events.value?.data?.count != 0 {
                if model?.eventtype == "External" {
                    guard let vc = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "ExternalEventDetailsVC") as? ExternalEventDetailsVC else {return}
                    vc.eventId = model?.id ?? ""
                    
                    if model?.key == 1 {
                        vc.isEventAdmin = true
                    }else {
                        vc.isEventAdmin = false
                    }
                    
                    self.navigationController?.pushViewController(vc, animated: true)
                }else {
                    guard let vc = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "EventDetailsViewController") as? EventDetailsViewController else {return}
                    vc.eventId = model?.id ?? ""
                    
                    if model?.key == 1 {
                        vc.isEventAdmin = true
                    }else {
                        vc.isEventAdmin = false
                    }
                    
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        //        if (((scrollView.contentOffset.y + scrollView.frame.size.height) > scrollView.contentSize.height ) && !isLoadingList){
        if scrollView == tableView,(scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height, !isLoadingList {
            
            self.isLoadingList = true
            if currentPage < viewmodel.events.value?.totalPages ?? 0 {
                self.tableView.tableFooterView = self.createFooterView()
                
                DispatchQueue.main.asyncAfter(wallDeadline: .now() + 2) {
                    print("self.currentPage >> \(self.currentPage)")
                    self.loadMoreEventItems()
                }
            }else {
                self.tableView.tableFooterView = nil
                DispatchQueue.main.async {
//                    self.view.makeToast("No more data".localizedString)
                }
                return
            }
        }
    }
}

//MARK: - Extensions initTotalEventsBarButton
extension FavoriteVC {
    func initTotalEventsBarButton(total:Int) {
        let button = UIButton.init(type: .custom)
        button.setTitle("Total: \(total)".localizedString, for: .normal)
        button.setTitleColor(UIColor.setColor(lightColor: UIColor.color("#141414")!, darkColor: .white), for: .normal)
        button.titleLabel?.font = UIFont.init(name: "Montserrat-SemiBold", size: 12)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButton
    }
}
