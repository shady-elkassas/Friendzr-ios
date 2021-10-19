//
//  EventDetailsVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 17/08/2021.
//

import UIKit
import SwiftUI
import SDWebImage

class EventDetailsVC: UIViewController {
    
    //MARK:- Outlets
    @IBOutlet weak var superView: UIView!
    @IBOutlet weak var eventImg: UIImageView!
    @IBOutlet weak var dateCreateLbl: UILabel!
    @IBOutlet weak var timeCreateLbl: UILabel!
    @IBOutlet weak var chartContainerView: UIView!
    @IBOutlet weak var chartView: UIView!
    @IBOutlet weak var attendLbl: UILabel!
    @IBOutlet weak var detailsView: UIView!
    @IBOutlet weak var categoryNameLbl: UILabel!
    @IBOutlet weak var descreptionLbl: UILabel!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var leaveBtn: UIButton!
    @IBOutlet weak var joinBtn: UIButton!
    @IBOutlet weak var interestsStatisticsView: UIView!
    @IBOutlet weak var attendeesTableView: UITableView!
    @IBOutlet weak var attendeesViewHeight: NSLayoutConstraint!
    @IBOutlet weak var eventTitleLbl: UILabel!
    @IBOutlet weak var hideView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var chartTitleLbl: UILabel!
    
    //MARK: - Properties
    var numbers:[Double] = [1,2,3]
    var genders:[String] = ["Men","Women","Other"]
    let attendeesCellID = "AttendeesTableViewCell"
    private var footerCellID = "SeeMoreTableViewCell"
    let interestCellID = "InterestsCollectionViewCell"
    let genderCellID = "GenderCollectionViewCell"
    var eventId:String = ""
    var viewmodel:EventsViewModel = EventsViewModel()
    var joinVM:JoinEventViewModel = JoinEventViewModel()
    var leaveVM:LeaveEventViewModel = LeaveEventViewModel()
    
    var internetConect:Bool = false
    
    var visibleIndexPath:Int = 0
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initBackButton()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        clearNavigationBar()
        
        DispatchQueue.main.async {
            self.updateUserInterface()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateViews), name: Notification.Name("updateViews"), object: nil)
    }
    
    //MARK: - Helper
    func updateUserInterface() {
        appDelegate.networkReachability()
        
        switch Network.reachability.status {
        case .unreachable:
            internetConect = false
            HandleInternetConnection()
        case .wwan:
            internetConect = true
            getEventDetails()
        case .wifi:
            internetConect = true
            getEventDetails()
        }
        
        print("Reachability Summary")
        print("Status:", Network.reachability.status)
        print("HostName:", Network.reachability.hostname ?? "nil")
        print("Reachable:", Network.reachability.isReachable)
        print("Wifi:", Network.reachability.isReachableViaWiFi)
    }
    
    @objc func updateViews() {
        setupChart()
    }
    
    func HandleInternetConnection() {
        self.view.makeToast("No avaliable newtwok ,Please try again!".localizedString)
    }
    
    func setupViews() {
        editBtn.cornerRadiusView(radius: 8)
        joinBtn.cornerRadiusView(radius: 8)
        leaveBtn.cornerRadiusView(radius: 8)
        detailsView.cornerRadiusView(radius: 21)
        interestsStatisticsView.cornerRadiusView(radius: 21)
        attendeesTableView.register(UINib(nibName: attendeesCellID, bundle: nil), forCellReuseIdentifier: attendeesCellID)
        attendeesTableView.register(UINib(nibName: footerCellID, bundle: nil), forHeaderFooterViewReuseIdentifier: footerCellID)
        
        collectionView.register(UINib(nibName: interestCellID, bundle: nil), forCellWithReuseIdentifier: interestCellID)
        collectionView.register(UINib(nibName: genderCellID, bundle: nil), forCellWithReuseIdentifier: genderCellID)
    }
    
    
    func showNewtworkConnected() {
        appDelegate.networkReachability()
        
        switch Network.reachability.status {
        case .unreachable:
            internetConect = false
            HandleInternetConnection()
        case .wwan:
            internetConect = true
        case .wifi:
            internetConect = true
        }
        
        print("Reachability Summary")
        print("Status:", Network.reachability.status)
        print("HostName:", Network.reachability.hostname ?? "nil")
        print("Reachable:", Network.reachability.isReachable)
        print("Wifi:", Network.reachability.isReachableViaWiFi)
    }
    
    func setupData() {
        let model = viewmodel.event.value
        eventTitleLbl.text = model?.title
        dateCreateLbl.text = model?.eventdate
        
        if model?.timefrom != "" && model?.allday == false {
            timeCreateLbl.text = model?.timefrom
        }else {
            timeCreateLbl.text = "All Day"
        }
        
        attendLbl.text = "Attendees : \(model?.joined ?? 0) / \(model?.totalnumbert ?? 0)"
        categoryNameLbl.text = model?.categorie
        descreptionLbl.text = model?.descriptionEvent
        eventImg.sd_setImage(with: URL(string: model?.image ?? ""), placeholderImage: UIImage(named: "photo_img"))
        if model?.key == 1 {
            editBtn.isHidden = false
            joinBtn.isHidden = true
            leaveBtn.isHidden = true
        }else if model?.key == 2 { // not join
            editBtn.isHidden = true
            joinBtn.isHidden = false
            leaveBtn.isHidden = true
            attendeesViewHeight.constant = 0
        }else { // join
            editBtn.isHidden = true
            joinBtn.isHidden = true
            leaveBtn.isHidden = false
            attendeesViewHeight.constant = 0
        }
        
        chartContainerView.cornerRadiusView(radius: 21)
    }
    
    
    func setupChart() {
        let model = viewmodel.event.value
        
        if visibleIndexPath == 0 {
            chartTitleLbl.text = "Interest Statistic"
            let child = UIHostingController(rootView: CircleView(fill1: 0, fill2: 0, fill3: 0, animations: true, male: model?.interestStatistic?[0].interestcount ?? 30, female: model?.interestStatistic?[1].interestcount ?? 30, other: model?.interestStatistic?[2].interestcount ?? 30))
            child.view.translatesAutoresizingMaskIntoConstraints = true
            child.view.frame = CGRect(x: 0, y: 0, width: chartView.bounds.width, height: chartView.bounds.height)
            chartView.addSubview(child.view)
        }else {
            chartTitleLbl.text = "Gender Statistic"
            let child = UIHostingController(rootView: CircleView(fill1: 0, fill2: 0, fill3: 0, animations: true, male: model?.genderStatistic?[0].gendercount ?? 30, female: model?.genderStatistic?[1].gendercount ?? 30, other: model?.genderStatistic?[2].gendercount ?? 30))
            child.view.translatesAutoresizingMaskIntoConstraints = true
            child.view.frame = CGRect(x: 0, y: 0, width: chartView.bounds.width, height: chartView.bounds.height)
            chartView.addSubview(child.view)
        }
    }
    
    
    //MARK:- APIs
    func getEventDetails() {
        hideView.isHidden = false
        self.showLoading()
        viewmodel.getEventByID(id: eventId)
        viewmodel.event.bind { [unowned self] value in
            DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.2) {
                self.hideLoading()
                hideView.isHidden = true
                collectionView.delegate = self
                collectionView.dataSource = self
                collectionView.reloadData()
                
                attendeesTableView.delegate = self
                attendeesTableView.dataSource = self
                attendeesTableView.reloadData()
                
                setupData()
                setupChart()
                
                if value.attendees?.count == 0 {
                    attendeesViewHeight.constant = 0
                }else if value.attendees?.count == 1 {
                    attendeesViewHeight.constant = CGFloat(120)
                }else if value.attendees?.count == 2 {
                    attendeesViewHeight.constant = CGFloat(220)
                }else {
                    attendeesViewHeight.constant = CGFloat(275)
                }
            }
        }
        
        // Set View Model Event Listener
        viewmodel.error.bind { [unowned self]error in
            DispatchQueue.main.async {
                self.hideLoading()
                self.showAlert(withMessage: error)
            }
        }
    }
    
    //MARK: - Actions
    @IBAction func editBtn(_ sender: Any) {
        showNewtworkConnected()
        if internetConect == true {
            guard let vc = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "EditEventsVC") as? EditEventsVC else {return}
            vc.eventModel = viewmodel.event.value
            self.navigationController?.pushViewController(vc, animated: true)
        }else {
            return
        }
    }
    
    @IBAction func joinBtn(_ sender: Any) {
        showNewtworkConnected()
        
        if internetConect == true {
            self.showLoading()
            joinVM.joinEvent(ByEventid: viewmodel.event.value?.id ?? "") { error, data in
                self.hideLoading()
                if let error = error {
                    self.showAlert(withMessage: error)
                    return
                }
                
                guard let _ = data else {return}
                
                DispatchQueue.main.async {
                    self.view.makeToast("You have successfully subscribed to event")
                }
                
                self.getEventDetails()
            }
        }else {
            return
        }
    }
    
    @IBAction func leaveBtn(_ sender: Any) {
        showNewtworkConnected()
        if internetConect == true {
            self.showLoading()
            leaveVM.leaveEvent(ByEventid: viewmodel.event.value?.id ?? "") { error, data in
                self.hideLoading()
                if let error = error {
                    self.showAlert(withMessage: error)
                    return
                }
                
                guard let _ = data else {return}
                
                DispatchQueue.main.async {
                    self.view.makeToast("You have successfully leave event")
                }
                
                self.getEventDetails()
            }
        }else {
            return
        }
    }
}

extension EventDetailsVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewmodel.event.value?.attendees?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: attendeesCellID, for: indexPath) as? AttendeesTableViewCell else {return UITableViewCell()}
        let model = viewmodel.event.value?.attendees?[indexPath.row]
        cell.dropDownBtn.isHidden = true
        cell.joinDateLbl.isHidden = true
        cell.friendNameLbl.text = model?.userName
        cell.friendImg.sd_setImage(with: URL(string: model?.image ?? "" ), placeholderImage: UIImage(named: "photo_img"))
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        guard let footerView = Bundle.main.loadNibNamed(footerCellID, owner: self, options: nil)?.first as? SeeMoreTableViewCell else { return UIView()}
        
        footerView.HandleSeeMoreBtn = {
            guard let vc = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "AttendeesVC") as? AttendeesVC else {return}
            vc.eventID = self.viewmodel.event.value?.id ?? ""
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (viewmodel.event.value?.attendees?.count ?? 0) > 1 {
            return 40
        }else {
            return 0
        }
    }
}

extension EventDetailsVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = viewmodel.event.value?.attendees?[indexPath.row]
        
        if model?.myEventO == true {
            guard let vc = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "") as? MyProfileVC else {return}
            self.navigationController?.pushViewController(vc, animated: true)
        }else {
            guard let vc = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "FriendProfileVC") as? FriendProfileVC else {return}
            vc.userID = model?.id ?? ""
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension EventDetailsVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: interestCellID, for: indexPath) as? InterestsCollectionViewCell else {return UICollectionViewCell()}
            cell.model = viewmodel.event.value?.interestStatistic
            cell.parentVC = self
            cell.tableView.reloadData()
            return cell
        }else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: genderCellID, for: indexPath) as? GenderCollectionViewCell else {return UICollectionViewCell()}
            cell.model = viewmodel.event.value?.genderStatistic
            cell.parentVC = self
            cell.tableView.reloadData()
            return cell
        }
    }
}

extension EventDetailsVC: UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.frame.width - 32
        let height = collectionView.frame.height - 16
        
        return CGSize(width: width, height: height)
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        let visibleIndexPatho = collectionView.indexPathForItem(at: visiblePoint)
        print("visibleIndexPatho : \(visibleIndexPatho?.row ?? 0)")
        
//        for cell in collectionView.visibleCells {
//            let indexPath = collectionView.indexPath(for: cell)
//            print("indexPath : \(indexPath?.row ?? 0)")
//
            visibleIndexPath = visibleIndexPatho?.row ?? 0
            NotificationCenter.default.post(name: Notification.Name("updateViews"), object: nil, userInfo: nil)
//        }
    }
}
