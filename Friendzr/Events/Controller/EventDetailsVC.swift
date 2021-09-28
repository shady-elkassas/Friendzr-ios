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
    @IBOutlet weak var interestsViewHeight: NSLayoutConstraint!
    @IBOutlet weak var interestsTableView: UITableView!
    @IBOutlet weak var attendeesTableView: UITableView!
    @IBOutlet weak var attendeesViewHeight: NSLayoutConstraint!
        
    //MARK: - Properties
    var numbers:[Double] = [1,2,3]
    var genders:[String] = ["Men","Women","Other"]
    let cellID = "InterestsTableViewCell"
    let attendeesCellID = "AttendeesTableViewCell"
    private var footerCellID = "SeeMoreTableViewCell"
    var eventId:String = ""
    var viewmodel:EventsViewModel = EventsViewModel()
    var joinVM:JoinEventViewModel = JoinEventViewModel()
    var leaveVM:LeaveEventViewModel = LeaveEventViewModel()
    
    var internetConect:Bool = false

    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initBackButton()
        
        DispatchQueue.main.async {
            self.updateUserInterface()
        }
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        clearNavigationBar()
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
    
    func HandleInternetConnection() {
            self.view.makeToast("No avaliable newtwok ,Please try again!".localizedString)
    }

    func setupViews() {
        let child = UIHostingController(rootView: CircleView())
        child.view.translatesAutoresizingMaskIntoConstraints = true
        child.view.frame = CGRect(x: 0, y: 0, width: chartView.bounds.width, height: chartView.bounds.height)
        chartView.addSubview(child.view)
        chartContainerView.cornerRadiusView(radius: 21)
        
        editBtn.cornerRadiusView(radius: 8)
        joinBtn.cornerRadiusView(radius: 8)
        leaveBtn.cornerRadiusView(radius: 8)
        detailsView.cornerRadiusView(radius: 21)
        interestsStatisticsView.cornerRadiusView(radius: 21)
        interestsTableView.register(UINib(nibName: cellID, bundle: nil), forCellReuseIdentifier: cellID)
        interestsViewHeight.constant = CGFloat(3*50) + 20
        
        attendeesTableView.register(UINib(nibName: attendeesCellID, bundle: nil), forCellReuseIdentifier: attendeesCellID)
        attendeesTableView.register(UINib(nibName: footerCellID, bundle: nil), forHeaderFooterViewReuseIdentifier: footerCellID)
    }
    
    func setupData() {
        let model = viewmodel.event.value
        dateCreateLbl.text = model?.eventdate
        timeCreateLbl.text = model?.timefrom
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
    }
    
    //MARK:- APIs
    func getEventDetails() {
        self.showLoading()
        viewmodel.getEventByID(id: eventId)
        viewmodel.event.bind { [unowned self] value in
            DispatchQueue.main.async {
                self.hideLoading()
                interestsTableView.delegate = self
                interestsTableView.dataSource = self
                interestsTableView.reloadData()
                
                attendeesTableView.delegate = self
                attendeesTableView.dataSource = self
                attendeesTableView.reloadData()
                
                setupData()
                
                if value.attendees?.count == 0 {
                    attendeesViewHeight.constant = 0
                }else {
                    attendeesViewHeight.constant = CGFloat(50 * (value.attendees?.count ?? 0)) + 85
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
        updateUserInterface()
        if internetConect == true {
            guard let vc = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "EditEventsVC") as? EditEventsVC else {return}
            vc.eventModel = viewmodel.event.value
            self.navigationController?.pushViewController(vc, animated: true)
        }else {
            return
        }
    }
    
    @IBAction func joinBtn(_ sender: Any) {
        updateUserInterface()
        
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
        updateUserInterface()
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
        if tableView == attendeesTableView {
            return viewmodel.event.value?.attendees?.count ?? 0
        }else {
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == attendeesTableView {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: attendeesCellID, for: indexPath) as? AttendeesTableViewCell else {return UITableViewCell()}
            let model = viewmodel.event.value?.attendees?[indexPath.row]
            cell.dropDownBtn.isHidden = true
            cell.joinDateLbl.isHidden = true
            cell.friendNameLbl.text = model?.userName
            return cell
        }else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? InterestsTableViewCell else {return UITableViewCell()}
            
            if indexPath.row == 3 {
                cell.bottonView.isHidden = true
            }
            
            cell.lblColor.backgroundColor = UIColor.colors.random()
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        if tableView == attendeesTableView {
            guard let footerView = Bundle.main.loadNibNamed(footerCellID, owner: self, options: nil)?.first as? SeeMoreTableViewCell else { return UIView()}
            
            footerView.HandleSeeMoreBtn = {
                guard let vc = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "AttendeesVC") as? AttendeesVC else {return}
                vc.eventID = self.viewmodel.event.value?.id ?? ""
                self.navigationController?.pushViewController(vc, animated: true)
            }
            return footerView
        }else {
            return UIView()
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if tableView == attendeesTableView {
            return 35
        }else {
            return 0
        }
    }
}

extension EventDetailsVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == attendeesTableView {
            return 50
        }else {
            return 50
        }
    }
}
