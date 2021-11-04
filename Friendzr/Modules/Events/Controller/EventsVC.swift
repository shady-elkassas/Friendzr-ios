//
//  EventsVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 16/08/2021.
//

import UIKit
import SwiftUI

class EventsVC: UIViewController {
    
    //MARK:- Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var tryAgainBtn: UIButton!
    @IBOutlet weak var emptyLbl: UILabel!
    @IBOutlet weak var emptyImg: UIImageView!
    
    //MARK: - Properties
    let cellID = "EventTableViewCell"
    var viewmodel:EventsViewModel = EventsViewModel()
    var refreshControl = UIRefreshControl()
    
    var internetConect:Bool = false
    var cellSelect:Bool = false
    
    var currentPage : Int = 1
    var isLoadingList : Bool = false

    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "My Events"
        setupView()
        
        initBackButton()
        pullToRefresh()
        NotificationCenter.default.addObserver(self, selector: #selector(refreshAllEvents), name: Notification.Name("refreshAllEvents"), object: nil)
        
        DispatchQueue.main.async {
            self.updateUserInterface()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        clearNavigationBar()
    }
    
    func loadMoreItemsForList(){
        currentPage += 1
        getAllEvents(pageNumber: currentPage)
    }

    //MARK:- APIs
    func getAllEvents(pageNumber:Int) {
        self.showLoading()
        viewmodel.getMyEvents(pageNumber: pageNumber)
        viewmodel.events.bind { [unowned self] value in
            DispatchQueue.main.async {
                self.hideLoading()
                tableView.delegate = self
                tableView.dataSource = self
                tableView.reloadData()
                initAddNewEventBarButton(total: value.totalRecords ?? 0)
                
                self.isLoadingList = false
                self.tableView.tableFooterView = nil

                showEmptyView()
            }
        }
        
        // Set View Model Event Listener
        viewmodel.error.bind { [unowned self]error in
            DispatchQueue.main.async {
                self.hideLoading()
                if error == "Internal Server Error" {
                    HandleInternetConnection()
                }else if error == "Bad Request" {
                    HandleinvalidUrl()
                }else {
                    self.showAlert(withMessage: error)
                }
            }
        }
    }
    
    //MARK: - Helper
    func updateUserInterface() {
        appDelegate.networkReachability()
        
        switch Network.reachability.status {
        case .unreachable:
            self.emptyView.isHidden = false
            internetConect = false
            HandleInternetConnection()
        case .wwan:
            internetConect = true
            self.emptyView.isHidden = true
            getAllEvents(pageNumber: 1)
        case .wifi:
            internetConect = true
            self.emptyView.isHidden = true
            getAllEvents(pageNumber: 1)
        }
        
        print("Reachability Summary")
        print("Status:", Network.reachability.status)
        print("HostName:", Network.reachability.hostname ?? "nil")
        print("Reachable:", Network.reachability.isReachable)
        print("Wifi:", Network.reachability.isReachableViaWiFi)
    }
    
    func showEmptyView() {
        if viewmodel.events.value?.data?.count == 0 {
            emptyView.isHidden = false
            emptyLbl.text = "You haven't any data yet".localizedString
        }else {
            emptyView.isHidden = true
        }
        
        tryAgainBtn.alpha = 0.0
    }
    
    func HandleinvalidUrl() {
        emptyView.isHidden = false
        emptyImg.image = UIImage.init(named: "emptyImage")
        emptyLbl.text = "sorry for that we have some maintaince with our servers please try again in few moments".localizedString
        tryAgainBtn.alpha = 1.0
    }
    
    func HandleInternetConnection() {
        if cellSelect {
            emptyView.isHidden = true
            self.view.makeToast("No avaliable newtwok ,Please try again!".localizedString)
        }else {
            emptyView.isHidden = false
            emptyImg.image = UIImage.init(named: "nointernet")
            emptyLbl.text = "No avaliable newtwok ,Please try again!".localizedString
            tryAgainBtn.alpha = 1.0
        }
    }
    
    func setupView() {
        tableView.register(UINib(nibName: cellID, bundle: nil), forCellReuseIdentifier: cellID)
        tryAgainBtn.cornerRadiusView(radius: 8)
    }
    
    func pullToRefresh() {
        self.refreshControl.attributedTitle = NSAttributedString(string: "")
        self.refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        self.tableView.addSubview(refreshControl)
    }
    
    @objc func didPullToRefresh() {
        print("Refersh")
        updateUserInterface()
        self.refreshControl.endRefreshing()
    }
    
    @objc func refreshAllEvents() {
        updateUserInterface()
    }
    
    func createFooterView() -> UIView {
        let footerview = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 100))
        let indicatorView = UIActivityIndicatorView()
        indicatorView.center = footerview.center
        footerview.addSubview(indicatorView)
        indicatorView.startAnimating()
        return footerview
    }
    
    //MARK:- Actions
    @IBAction func tryAgainBtn(_ sender: Any) {
        cellSelect = false
        updateUserInterface()
    }
}

//MARK: - Extensions
extension EventsVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewmodel.events.value?.data?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? EventTableViewCell else {return UITableViewCell()}
        let model = viewmodel.events.value?.data?[indexPath.row]
        cell.attendeesLbl.text = "Attendees : \(model?.joined ?? 0) / \(model?.totalnumbert ?? 0)"
        cell.eventTitleLbl.text = model?.title
        cell.categoryLbl.text = model?.categorie
        cell.dateLbl.text = model?.eventdate
        cell.eventImg.sd_setImage(with: URL(string: model?.image ?? "" ), placeholderImage: UIImage(named: "placeholder"))
        return cell
    }
}

extension EventsVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        cellSelect = true
        updateUserInterface()
        if internetConect == true {
            guard let vc = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "EventDetailsVC") as? EventDetailsVC else {return}
            vc.eventId = viewmodel.events.value?.data?[indexPath.row].id ?? ""
            self.navigationController?.pushViewController(vc, animated: true)
        }else {
            return
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
          if (((scrollView.contentOffset.y + scrollView.frame.size.height) > scrollView.contentSize.height ) && !isLoadingList){
              self.isLoadingList = true
              if currentPage < viewmodel.events.value?.totalPages ?? 0 {
                  self.tableView.tableFooterView = self.createFooterView()
                  
                  DispatchQueue.main.asyncAfter(wallDeadline: .now() + 2) {
                      print("self.currentPage >> \(self.currentPage)")
                      self.loadMoreItemsForList()
                  }
              }else {
                  self.tableView.tableFooterView = nil
                  DispatchQueue.main.async {
                      self.view.makeToast("No more data here")
                  }
                  return
              }
          }
      }
}

extension EventsVC {
    func initAddNewEventBarButton(total:Int) {
        let button = UIButton.init(type: .custom)
        button.setTitle("Total Event: \(total)".localizedString, for: .normal)
        button.setTitleColor(UIColor.setColor(lightColor: UIColor.color("#141414")!, darkColor: .white), for: .normal)
        button.titleLabel?.font = UIFont.init(name: "Montserrat-SemiBold", size: 12)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButton
    }
}
