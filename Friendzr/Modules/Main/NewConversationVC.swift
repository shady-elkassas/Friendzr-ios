//
//  NewConversationVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 19/08/2021.
//

import UIKit
import ListPlaceholder
import SDWebImage
import Network

class NewConversationVC: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var searchbar: UISearchBar!
    @IBOutlet weak var searchBarView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var tryAgainBtn: UIButton!
    @IBOutlet weak var emptyLbl: UILabel!
    @IBOutlet weak var emptyImg: UIImageView!
    
    @IBOutlet weak var hideView: UIView!
    @IBOutlet var prosImg: [UIImageView]!
    @IBOutlet var hidesImg: [UIImageView]!

    //MARK: - Properties
    let cellID = "ContactsTableViewCell"
    var viewmodel:AllFriendesViewModel = AllFriendesViewModel()
    
    var cellSelected:Bool = false
    
    var currentPage : Int = 1
    var isLoadingList : Bool = false
    
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Chat".localizedString
        initCancelBarButton()
        setupSearchBar()
        setupViews()
        initAddGroupBarButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Defaults.availableVC = "NewConversationVC"
        print("availableVC >> \(Defaults.availableVC)")
        CancelRequest.currentTask = false
        setupHideView()
        
        setupNavBar()
        hideNavigationBar(NavigationBar: false, BackButton: false)
        
        DispatchQueue.main.async {
            self.updateUserInterface()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        CancelRequest.currentTask = true
    }
    
    //MARK: - Helper
    func updateUserInterface() {
        
        appDelegate.networkReachability()
        
        switch Network.reachability.status {
        case .unreachable:
            self.emptyView.isHidden = false
            NetworkConected.internetConect = false
            self.HandleInternetConnection()
        case .wwan:
            DispatchQueue.main.async {
                self.emptyView.isHidden = true
                NetworkConected.internetConect = true
                self.LaodAllFriends(pageNumber: 1, search: self.searchbar.text ?? "")
            }
        case .wifi:
            DispatchQueue.main.async {
                self.emptyView.isHidden = true
                NetworkConected.internetConect = true
                self.LaodAllFriends(pageNumber: 1, search: self.searchbar.text ?? "")
            }
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
            emptyLbl.text = "You have no Friendzrs  currently. \nlet's Friendzr on your Feed and check back again".localizedString
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
        hideView.isHidden = true
        if cellSelected {
            emptyView.isHidden = true
            self.view.makeToast("Network is unavailable, please try again!".localizedString)
        }else {
            emptyView.isHidden = false
            emptyImg.image = UIImage.init(named: "feednodata_img")
            emptyLbl.text = "Network is unavailable, please try again!".localizedString
            tryAgainBtn.alpha = 1.0
        }
    }
    
    
    //MARK: - APIs
    func loadMoreItemsForList(){
        currentPage += 1
        getAllFriends(pageNumber: currentPage, search: searchbar.text ?? "")
    }
     func getAllFriends(pageNumber:Int,search:String) {
        hideView.isHidden = true
        viewmodel.getAllFriendes(pageNumber: pageNumber, search: search)
        viewmodel.friends.bind { [unowned self] value in
            DispatchQueue.main.async {
                self.tableView.delegate = self
                self.tableView.dataSource = self
                self.tableView.reloadData()
                
                self.isLoadingList = false
                self.tableView.tableFooterView = nil
                
                self.showEmptyView()
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
    func LaodAllFriends(pageNumber:Int,search:String) {
        hideView.isHidden = false
        hideView.showLoader()
        viewmodel.getAllFriendes(pageNumber: pageNumber, search: search)
        viewmodel.friends.bind { [unowned self] value in
            DispatchQueue.main.async {
                
                DispatchQueue.main.async {
                    self.hideView.hideLoader()
                    self.hideView.isHidden = true
                }
                
                self.tableView.delegate = self
                self.tableView.dataSource = self
                self.tableView.reloadData()
                
                self.isLoadingList = false
                self.tableView.tableFooterView = nil
                
                self.showEmptyView()
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
    
    //Create Footer View for load more
    func createFooterView() -> UIView {
        let footerview = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 100))
        let indicatorView = UIActivityIndicatorView()
        indicatorView.center = footerview.center
        footerview.addSubview(indicatorView)
        indicatorView.startAnimating()
        return footerview
    }

    func setupHideView() {
        for item in prosImg {
            item.cornerRadiusForHeight()
        }
        
        for itm in hidesImg {
            itm.cornerRadiusView(radius: 6)
        }
    }
    
    //MARK: - Actions
    @IBAction func tryAgainBtn(_ sender: Any) {
        updateUserInterface()
    }
}

//MARK: - Extensions UISearchBarDelegate
extension NewConversationVC : UISearchBarDelegate {
    @objc func updateSearchResult() {
        guard let text = searchbar.text else {return}
        print(text)

        if NetworkConected.internetConect {
            getAllFriends(pageNumber: 1, search: text)
        }else {
            HandleInternetConnection()
        }
    }
}
//MARK: - UITableViewDataSource
extension NewConversationVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewmodel.friends.value?.data?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? ContactsTableViewCell else {return UITableViewCell()}
        let model = viewmodel.friends.value?.data?[indexPath.row]
        cell.nameLbl.text = model?.userName
        cell.profileImg.sd_imageIndicator = SDWebImageActivityIndicator.gray
        cell.profileImg.sd_setImage(with: URL(string: model?.image ?? "" ), placeholderImage: UIImage(named: "placeHolderApp"))
        
        if indexPath.row == ((viewmodel.friends.value?.data?.count ?? 0) - 1 ) {
            cell.underView.isHidden = true
        }
        
        return cell
    }
}

//MARK: - UITableViewDelegate
extension NewConversationVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        cellSelected = true
        
        if NetworkConected.internetConect {
            let vc = ConversationVC()
            let model = viewmodel.friends.value?.data?[indexPath.row]
            vc.isEvent = false
            vc.eventChatID = ""
            vc.chatuserID = model?.userId ?? ""
            vc.leaveGroup = 1
            vc.isFriend = true
            vc.leavevent = 0
            vc.titleChatImage = model?.image ?? ""
            vc.titleChatName = model?.userName ?? ""
            vc.isChatGroupAdmin = false
            vc.isChatGroup = false
            vc.groupId = ""
            vc.isEventAdmin = false
            
            vc.titleChatImage = model?.image ?? ""
            vc.titleChatName = model?.userName ?? ""
            CancelRequest.currentTask = false
            navigationController?.pushViewController(vc, animated: true)
        }
        else {
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
                    self.view.makeToast("No more data".localizedString)
                }
                return
            }
        }
    }
}

extension NewConversationVC {
    //init Add Group Bar Button
    func initAddGroupBarButton() {
        let button = UIButton.init(type: .custom)
        button.setTitle("Create Group", for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont(name: "Montserrat-Medium", size: 12)
        button.tintColor = UIColor.setColor(lightColor: UIColor.black, darkColor: UIColor.white)
        button.addTarget(self, action: #selector(handleAddGroupVC), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    @objc func handleAddGroupVC() {
        if NetworkConected.internetConect {
            if viewmodel.friends.value?.data?.count == 0 {
                self.view.makeToast("Please add friends to create a group".localizedString)
                return
            }else {
                if let controller = UIViewController.viewController(withStoryboard: .Main, AndContollerID: "AddGroupNC") as? UINavigationController, let _ = controller.viewControllers.first as? AddGroupVC {
                    self.present(controller, animated: true)
                }
            }
        }
        else {
            HandleInternetConnection()
        }

    }
}
