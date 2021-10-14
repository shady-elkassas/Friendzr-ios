//
//  NewConversationVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 19/08/2021.
//

import UIKit

class NewConversationVC: UIViewController {
    
    //MARK:- Outlets
    @IBOutlet weak var searchbar: UISearchBar!
    @IBOutlet weak var searchBarView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var tryAgainBtn: UIButton!
    @IBOutlet weak var emptyLbl: UILabel!
    @IBOutlet weak var emptyImg: UIImageView!
    
    //MARK: - Properties
    let cellID = "ContactsTableViewCell"
    var viewmodel:AllFriendesViewModel = AllFriendesViewModel()
    
    var cellSelected:Bool = false
    var internetConnect:Bool = false
    
    var currentPage : Int = 1
    var isLoadingList : Bool = false
    
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "New Conversation"
        initCloseBarButton()
        setupNavBar()
        setupSearchBar()
        setupViews()
        
        DispatchQueue.main.async {
            self.updateUserInterface()
        }
    }
    
    //MARK: - Helper
    func updateUserInterface() {
        appDelegate.networkReachability()
        
        switch Network.reachability.status {
        case .unreachable:
            self.emptyView.isHidden = false
            internetConnect = false
            HandleInternetConnection()
        case .wwan:
            self.emptyView.isHidden = true
            internetConnect = true
            getAllFriends(pageNumber: 1)
        case .wifi:
            self.emptyView.isHidden = true
            internetConnect = true
            getAllFriends(pageNumber: 1)
        }
        
        print("Reachability Summary")
        print("Status:", Network.reachability.status)
        print("HostName:", Network.reachability.hostname ?? "nil")
        print("Reachable:", Network.reachability.isReachable)
        print("Wifi:", Network.reachability.isReachableViaWiFi)
    }
    
    func updateNetworkForBtns() {
        appDelegate.networkReachability()
        
        switch Network.reachability.status {
        case .unreachable:
            self.emptyView.isHidden = false
            internetConnect = false
            HandleInternetConnection()
        case .wwan:
            self.emptyView.isHidden = true
            internetConnect = true
        case .wifi:
            self.emptyView.isHidden = true
            internetConnect = true
        }
        
        print("Reachability Summary")
        print("Status:", Network.reachability.status)
        print("HostName:", Network.reachability.hostname ?? "nil")
        print("Reachable:", Network.reachability.isReachable)
        print("Wifi:", Network.reachability.isReachableViaWiFi)
    }
    
    func showEmptyView() {
        if viewmodel.friends.value?.data?.count == 0 {
            emptyView.isHidden = false
            emptyLbl.text = "You haven't any data yet".localizedString
        }else {
            emptyView.isHidden = true
        }
        
        tryAgainBtn.alpha = 0.0
    }
    
    func setupSearchBar() {
        searchbar.delegate = self
        searchBarView.cornerRadiusView(radius: 6)
        searchBarView.setBorder()
        searchbar.backgroundImage = UIImage()
        searchbar.searchTextField.textColor = .black
        searchbar.searchTextField.backgroundColor = .clear
        searchbar.searchTextField.font = UIFont(name: "Montserrat-Medium", size: 14)
        var placeHolder = NSMutableAttributedString()
        let textHolder  = "Search...".localizedString
        let font = UIFont(name: "Montserrat-Medium", size: 14) ?? UIFont.systemFont(ofSize: 14)
        placeHolder = NSMutableAttributedString(string:textHolder, attributes: [NSAttributedString.Key.font: font])
        searchbar.searchTextField.attributedPlaceholder = placeHolder
        searchbar.searchTextField.addTarget(self, action: #selector(updateSearchResult), for: .editingChanged)
    }
    
    func setupViews() {
        tableView.register(UINib(nibName: cellID, bundle: nil), forCellReuseIdentifier: cellID)
        tryAgainBtn.cornerRadiusView(radius: 8)
    }
    
    func HandleInternetConnection() {
        if cellSelected {
            emptyView.isHidden = true
            self.view.makeToast("No avaliable newtwok ,Please try again!".localizedString)
        }else {
            emptyView.isHidden = false
            emptyImg.image = UIImage.init(named: "nointernet")
            emptyLbl.text = "No avaliable newtwok ,Please try again!".localizedString
            tryAgainBtn.alpha = 1.0
        }
    }
    
    
    //MARK:- APIs
    func loadMoreItemsForList(){
        currentPage += 1
        getAllFriends(pageNumber: currentPage)
    }
    
    func getAllFriends(pageNumber:Int) {
        self.showLoading()
        viewmodel.getAllFriendes(pageNumber: pageNumber)
        viewmodel.friends.bind { [unowned self] value in
            DispatchQueue.main.async {
                self.hideLoading()
                tableView.delegate = self
                tableView.dataSource = self
                tableView.reloadData()
                
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
                }else {
                    self.showAlert(withMessage: error)
                }
            }
        }
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
        updateUserInterface()
    }
}

//MARK: - Extensions
extension NewConversationVC : UISearchBarDelegate {
    @objc func updateSearchResult() {
        guard let text = searchbar.text else {return}
        print(text)
    }
}

extension NewConversationVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewmodel.friends.value?.data?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? ContactsTableViewCell else {return UITableViewCell()}
        let model = viewmodel.friends.value?.data?[indexPath.row]
        cell.nameLbl.text = model?.userName
        cell.profileImg.sd_setImage(with: URL(string: model?.image ?? "" ), placeholderImage: UIImage(named: "avatar"))
        
        if indexPath.row == ((viewmodel.friends.value?.data?.count ?? 0) - 1 ) {
            cell.underView.isHidden = true
        }
        
        return cell
    }
}

extension NewConversationVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        cellSelected = true
        updateNetworkForBtns()
        
        if internetConnect {
            let model = viewmodel.friends.value?.data?[indexPath.row]
            guard let vc = UIViewController.viewController(withStoryboard: .Main, AndContollerID: "ChatVC") as? ChatVC else {return}
            
            vc.eventChat = false
            vc.eventChatID = ""
            vc.chatuserID = model?.userId ?? ""
            
            vc.titleChatName = model?.userName ?? ""
            self.navigationController?.pushViewController(vc, animated: true)
        }else {
            return
        }
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if (((scrollView.contentOffset.y + scrollView.frame.size.height) > scrollView.contentSize.height ) && !isLoadingList){
            self.isLoadingList = true
            
            if currentPage < viewmodel.friends.value?.totalPages ?? 0 {
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
