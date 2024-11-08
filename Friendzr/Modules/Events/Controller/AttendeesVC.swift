//
//  AttendeesVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 07/09/2021.
//

import UIKit
import ListPlaceholder
import Network
import SDWebImage

class AttendeesVC: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchContainerView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var tryAgainBtn: UIButton!
    @IBOutlet weak var emptyLbl: UILabel!
    @IBOutlet weak var emptyImg: UIImageView!
    
    //MARK: - Properties
    let cellID = "AttendeesTableViewCell"
    var viewmodel:AttendeesViewModel = AttendeesViewModel()
    var eventID:String = ""
    var currentPage : Int = 1
    var isLoadingList : Bool = false
    var eventKey:Int = 0
    
    lazy var alertView = Bundle.main.loadNibNamed("BlockAlertView", owner: self, options: nil)?.first as? BlockAlertView
    
    private let formatterDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    private let formatterTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchBar()
        tableView.register(UINib(nibName: cellID, bundle: nil), forCellReuseIdentifier: cellID)
        initBackButton()
        title = "Attendees".localizedString
        tryAgainBtn.cornerRadiusView(radius: 8)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        alertView?.addGestureRecognizer(tap)
        
        DispatchQueue.main.async {
            self.updateUserInterface()
        }
        
        tryAgainBtn.cornerRadiusView(radius: 8)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        CancelRequest.currentTask = false
        if Defaults.isWhiteLable {
            tabBarController?.tabBar.isHidden = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.hideLoading()
        CancelRequest.currentTask = true
    }
    
    //MARK: - APIs
    func updateUserInterface() {
        appDelegate.networkReachability()
        
        switch Network.reachability.status {
        case .unreachable:
            DispatchQueue.main.async {
                NetworkConected.internetConect = false
                self.emptyView.isHidden = false
                self.HandleInternetConnection()
            }
        case .wwan:
            DispatchQueue.main.async {
                NetworkConected.internetConect = true
                self.emptyView.isHidden = true
                self.loadAllAttendees(pageNumber: 0, search: self.searchBar.text ?? "")
            }
        case .wifi:
            DispatchQueue.main.async {
                NetworkConected.internetConect = true
                self.emptyView.isHidden = true
                self.loadAllAttendees(pageNumber: 0, search: self.searchBar.text ?? "")
            }
        }
        
        print("Reachability Summary")
        print("Status:", Network.reachability.status)
        print("HostName:", Network.reachability.hostname ?? "nil")
        print("Reachable:", Network.reachability.isReachable)
        print("Wifi:", Network.reachability.isReachableViaWiFi)
    }
    func loadMoreItemsForList(){
        currentPage += 1
        getAllAttendees(pageNumber: currentPage, search: searchBar.text ?? "")
    }
    func getAllAttendees(pageNumber:Int,search:String) {
        self.tableView.hideLoader()
        viewmodel.getEventAttendees(ByEventID: eventID, pageNumber: pageNumber, search: search)
        viewmodel.attendees.bind { [weak self] value in
            DispatchQueue.main.async {
                self?.tableView.delegate = self
                self?.tableView.dataSource = self
                self?.tableView.reloadData()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self?.isLoadingList = false
                    self?.tableView.tableFooterView = nil
                }

                self?.showEmptyView()
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
    func loadAllAttendees(pageNumber:Int,search:String) {
        
        viewmodel.getEventAttendees(ByEventID: eventID, pageNumber: pageNumber, search: search)
        viewmodel.attendees.bind { [weak self] value in
            DispatchQueue.main.async {
                self?.tableView.delegate = self
                self?.tableView.dataSource = self
                self?.tableView.reloadData()
                
                self?.isLoadingList = false
                self?.tableView.tableFooterView = nil
                
                self?.showEmptyView()
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
    func updateAttendees(_ id:String,_ stutus:Int,_ actionDate:String,_ actiontime:String) {
        // handling code
        
        self.viewmodel.editAttendees(ByUserAttendId: id, AndEventid: eventID, AndStutus: stutus,Actiontime: actiontime ,ActionDate: actionDate) { [self] error, data in
            if let error = error {
                DispatchQueue.main.async {
                    self.view.makeToast(error)
                }
                
                return
            }
            
            guard let _ = data else {return}
            DispatchQueue.main.async {
                self.getAllAttendees(pageNumber: 0, search: self.searchBar.text ?? "")
            }
        }
    }
    func showAlertView(messageString:String,eventID:String,UserattendId:String,Stutus :Int) {
        self.alertView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        self.alertView?.titleLbl.text = "Confirm?".localizedString
        self.alertView?.detailsLbl.text = "Are you sure you want to ".localizedString + "\(messageString)" + " this account?".localizedString
        
        let ActionDate = self.formatterDate.string(from: Date())
        let Actiontime = self.formatterTime.string(from: Date())
        
        self.alertView?.HandleConfirmBtn = {
            self.updateAttendees(UserattendId, Stutus, ActionDate, Actiontime)
            
            UIView.animate(withDuration: 0.3, animations: {
                self.alertView?.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
                self.alertView?.alpha = 0
            }) { (success: Bool) in
                self.alertView?.removeFromSuperview()
                self.alertView?.alpha = 1
                self.alertView?.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            }
        }
        
        self.view.addSubview((self.alertView)!)
    }
    
    func showActionsheet(_ model:UserConversationModel?) {
        let settingsActionSheet: UIAlertController = UIAlertController(title:nil, message:nil, preferredStyle:UIAlertController.Style.actionSheet)
        
        settingsActionSheet.addAction(UIAlertAction(title:"Remove".localizedString.localizedString, style:UIAlertAction.Style.default, handler:{ action in
            self.showAlertView(messageString: "delete".localizedString, eventID: self.eventID, UserattendId: model?.userId ?? "", Stutus: 1)
        }))
        settingsActionSheet.addAction(UIAlertAction(title:"Block From Event".localizedString.localizedString, style:UIAlertAction.Style.default, handler:{ action in
            self.showAlertView(messageString: "block".localizedString, eventID: self.eventID, UserattendId: model?.userId ?? "", Stutus: 2)
        }))
        settingsActionSheet.addAction(UIAlertAction(title:"Cancel".localizedString, style:UIAlertAction.Style.cancel, handler:nil))
        
        self.present(settingsActionSheet, animated:true, completion:nil)
    }
    
    //MARK: - Helpers
    func setupSearchBar() {
        searchBar.delegate = self
        searchContainerView.cornerRadiusView(radius: 6)
        searchContainerView.setBorder()
        searchBar.backgroundImage = UIImage()
        searchBar.searchTextField.textColor = .black
        searchBar.searchTextField.backgroundColor = .clear
        searchBar.searchTextField.font = UIFont(name: "Montserrat-Medium", size: 14)
        var placeHolder = NSMutableAttributedString()
        let textHolder  = "Search...".localizedString
        let font = UIFont(name: "Montserrat-Medium", size: 14) ?? UIFont.systemFont(ofSize: 14)
        placeHolder = NSMutableAttributedString(string:textHolder, attributes: [NSAttributedString.Key.font: font])
        searchBar.searchTextField.attributedPlaceholder = placeHolder
        searchBar.searchTextField.addDoneOnKeyboard(withTarget: self, action: #selector(dismissKeyboard))
        searchBar.searchTextField.addTarget(self, action: #selector(updateSearchResult), for: .editingChanged)
    }
    func showEmptyView() {
        if viewmodel.attendees.value?.data?.count == 0 {
            emptyView.isHidden = false
            emptyLbl.text = "You haven't any data yet".localizedString
        }else {
            emptyView.isHidden = true
        }
        
        tryAgainBtn.alpha = 0.0
    }
    func HandleinvalidUrl() {
        emptyView.isHidden = false
        emptyImg.image = UIImage.init(named: "maskGroup9")
        emptyLbl.text = "sorry for that we have some maintaince with our servers please try again in few moments".localizedString
        tryAgainBtn.alpha = 1.0
    }
    func HandleInternetConnection() {
        emptyView.isHidden = false
        emptyImg.image = UIImage.init(named: "feednodata_img")
        emptyLbl.text = "No available network, please try again!".localizedString
        tryAgainBtn.alpha = 1.0
    }
    func createFooterView() -> UIView {
        let footerview = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 100))
        let indicatorView = UIActivityIndicatorView()
        indicatorView.center = footerview.center
        footerview.addSubview(indicatorView)
        indicatorView.startAnimating()
        return footerview
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        // handling code
        UIView.animate(withDuration: 0.3, animations: {
            self.alertView?.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.alertView?.alpha = 0
        }) { (success: Bool) in
            self.alertView?.removeFromSuperview()
            self.alertView?.alpha = 1
            self.alertView?.transform = CGAffineTransform.init(scaleX: 1, y: 1)
        }
    }
    
    //MARK: - Actions
    @IBAction func tryAgainBtn(_ sender: Any) {
        updateUserInterface()
    }
}

//MARK: - SearchBar Delegate
extension AttendeesVC: UISearchBarDelegate{
    @objc func updateSearchResult() {
        guard let text = searchBar.text else {return}
        print(text)
        if NetworkConected.internetConect {
            getAllAttendees(pageNumber: 0, search: text)
        }
    }
    
    func initNewConversationBarButton() {
        let button = UIButton.init(type: .custom)
        button.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        let image = UIImage(named: "newMessage_ic")?.withRenderingMode(.automatic)
        
        button.setImage(image, for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(PresentNewConversation), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    @objc func PresentNewConversation() {
        print("PresentNewConversation")
        if let controller = UIViewController.viewController(withStoryboard: .Main, AndContollerID: "NewConversationNC") as? UINavigationController, let _ = controller.viewControllers.first as? NewConversationVC {
            self.present(controller, animated: true)
        }
    }
}

//MARK: - tableView DataSource & Delegate
extension AttendeesVC:UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewmodel.attendees.value?.data?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? AttendeesTableViewCell else {return UITableViewCell()}
        let model = viewmodel.attendees.value?.data?[indexPath.row]
        
        cell.friendNameLbl.text = model?.userName
        cell.friendImg.sd_imageIndicator = SDWebImageActivityIndicator.gray
        cell.friendImg.sd_setImage(with: URL(string: model?.image ?? ""), placeholderImage: UIImage(named: "userPlaceHolderImage"))
        cell.joinDateLbl.text = "join Date: " + "\(model?.joinDate ?? "")"
        
        if eventKey == 1 {
            if model?.myEventO == true {
                cell.dropDownBtn.isHidden = true
                cell.adminLbl.isHidden = false
                cell.btnWidth.constant = 0
            }else {
                cell.dropDownBtn.isHidden = false
                cell.adminLbl.isHidden = true
                cell.btnWidth.constant = 20
            }
        }
        else {
            if model?.myEventO == true {
                cell.dropDownBtn.isHidden = true
                cell.adminLbl.isHidden = false
                cell.btnWidth.constant = 0
            }else {
                cell.dropDownBtn.isHidden = true
                cell.adminLbl.isHidden = true
                cell.btnWidth.constant = 0
            }
        }
        
        cell.HandleDropDownBtn = {
            self.showActionsheet(model)
        }
        
        return cell
    }
}

extension AttendeesVC:UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (((scrollView.contentOffset.y + scrollView.frame.size.height) > scrollView.contentSize.height ) && !isLoadingList){
            self.isLoadingList = true
            if currentPage < viewmodel.attendees.value?.totalPages ?? 0 {
                self.tableView.tableFooterView = self.createFooterView()
                
                DispatchQueue.main.asyncAfter(wallDeadline: .now() + 2) {
                    print("self.currentPage >> \(self.currentPage)")
                    self.loadMoreItemsForList()
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
