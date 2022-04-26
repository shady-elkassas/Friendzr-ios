//
//  AddNewUsersForMyGroupVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 18/01/2022.
//

import UIKit
import Network
import SDWebImage

class AddNewUsersForMyGroupVC: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var searchbar: UISearchBar!
    @IBOutlet weak var searchBarView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var emptyView: UIView!
    
    //MARK: - Properties
    let cellID = "AddFriendsToPrivateEventTableViewCell"
    let emptyCellID = "EmptyViewTableViewCell"
    var viewmodel:AllFriendesViewModel = AllFriendesViewModel()
    var addNewUserGroupVM:GroupViewModel = GroupViewModel()
    var groupId:String = ""
    var cellSelected:Bool = false
    var internetConnect:Bool = false
    var currentPage : Int = 1
    var isLoadingList : Bool = false
    var selectedFriends:[UserConversationModel] = [UserConversationModel]()
    var selectedIDs = [String]()
    var selectedNames = [String]()
    
    private let formatterDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    private let formatterTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Select Friends".localizedString
        initCancelBarButton()
        setupSearchBar()
        setupViews()
        
        DispatchQueue.main.async {
            self.updateUserInterface()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Defaults.availableVC = "AddNewUsersForMyGroupVC"
        print("availableVC >> \(Defaults.availableVC)")
    }
    
    //MARK: - Helpers
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
                NetworkConected.internetConect = true
                self.LaodAllFriends(pageNumber: 1, search: self.searchbar.text ?? "")
            }
        case .wifi:
            DispatchQueue.main.async {
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
        tableView.allowsMultipleSelection = true
        tableView.register(UINib(nibName: cellID, bundle: nil), forCellReuseIdentifier: cellID)
        doneBtn.cornerRadiusView(radius: 8)
    }
    func HandleInternetConnection() {
        self.view.makeToast("Network is unavailable, please try again!".localizedString)
    }
    
    //MARK: - APIs
    func loadMoreFriendItems(){
        currentPage += 1
        getAllFriends(pageNumber: currentPage, search: searchbar.text ?? "")
    }
    
    func getAllFriends(pageNumber:Int,search:String) {
        viewmodel.getAllFriendes(pageNumber: pageNumber, search: search)
        viewmodel.friends.bind { [unowned self] value in
            DispatchQueue.main.async {
                self.tableView.hideLoader()
                self.tableView.delegate = self
                self.tableView.dataSource = self
                self.tableView.reloadData()
                
                self.isLoadingList = false
                self.tableView.tableFooterView = nil
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
        
        viewmodel.getAllFriendes(pageNumber: pageNumber, search: search)
        viewmodel.friends.bind { [unowned self] value in
            DispatchQueue.main.async {
                self.tableView.delegate = self
                self.tableView.dataSource = self
                self.tableView.reloadData()
                
                
                if value.data?.count != 0 {
                    self.tableView.showLoader()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.tableView.hideLoader()
                    }
                }
                
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

    //Show Empty View
    func showEmptyView() {
        let model = viewmodel.friends.value?.data
        if model?.count != 0 {
            emptyView.isHidden = true
        }else {
            emptyView.isHidden = false
        }
    }
    
    //create Footer View for load more table view
    func createFooterView() -> UIView {
        let footerview = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 100))
        let indicatorView = UIActivityIndicatorView()
        indicatorView.center = footerview.center
        footerview.addSubview(indicatorView)
        indicatorView.startAnimating()
        return footerview
    }
    
    //MARK: - Actions
    @IBAction func doneBtn(_ sender: Any) {
        let actionDate = formatterDate.string(from: Date())
        let actionTime = formatterTime.string(from: Date())
        
        if selectedIDs.count == 0 {
            self.view.makeToast("Please select group participants".localizedString)
        }else {
            doneBtn.setTitle("Sending...", for: .normal)
            addNewUserGroupVM.addUsersGroup(withGroupId: groupId, AndListOfUserIDs: selectedIDs, AndRegistrationDateTime: "\(actionDate) \(actionTime)") { error, data in
                if let error = error {
                    DispatchQueue.main.async {
                        self.view.makeToast(error)
                    }
                    return
                }
                
                guard let _ = data else {return}
                
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Notification.Name("updateGroupDetails"), object: nil, userInfo: nil)
                }
                
                DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.5) {
                    self.onDismiss()
                }
            }
        }
    }
}


//MARK: - Extensions UISearchBarDelegate
extension AddNewUsersForMyGroupVC : UISearchBarDelegate {
    @objc func updateSearchResult() {
        guard let text = searchbar.text else {return}
        print(text)
        
        if internetConnect {
            getAllFriends(pageNumber: 1, search: text)
        }
    }
}

//MARK: - UITableViewDataSource
extension AddNewUsersForMyGroupVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewmodel.friends.value?.data?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? AddFriendsToPrivateEventTableViewCell else {return UITableViewCell()}
        let model = viewmodel.friends.value?.data?[indexPath.row]
        cell.titleLbl.text = model?.userName
        cell.profileImg.sd_imageIndicator = SDWebImageActivityIndicator.gray
        cell.profileImg.sd_setImage(with: URL(string: model?.image ?? "" ), placeholderImage: UIImage(named: "placeHolderApp"))
        
        if selectedIDs.contains(model?.userId ?? "") {
            cell.selectedImg.image = UIImage(named: "selected_ic")
        }
        else {
            cell.selectedImg.image = UIImage(named: "unSelected_ic")
        }
        
        if indexPath.row == ((viewmodel.friends.value?.data?.count ?? 0) - 1 ) {
            cell.bottomView.isHidden = true
        }
        
        return cell
    }
}

//MARK: - UITableViewDelegate
extension AddNewUsersForMyGroupVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let type = viewmodel.friends.value?.data?[indexPath.row]
        if selectedFriends.contains(where: { $0.userId == type?.userId }) {
            // found
            selectedFriends.removeAll(where: { $0.userId == type?.userId })
        } else {
            // not
            selectedFriends.append(type!)
        }
        
        //remove the lbl
        if selectedIDs.count != 0 {
            selectedIDs.removeAll()
            selectedNames.removeAll()
            for item in selectedFriends {
                selectedIDs.append(item.userId)
                selectedNames.append(item.userName )
            }
        }else {
            for item in selectedFriends {
                selectedIDs.append(item.userId)
                selectedNames.append(item.userName )
            }
        }
        
        print("selectedIDs = \(selectedIDs)")
        print("selectedNames = \(selectedNames)")
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let type = viewmodel.friends.value?.data![indexPath.row]
        if selectedFriends.contains(where: { $0.userId == type?.userId }) {
            // found
            selectedFriends.removeAll(where: { $0.userId == type?.userId })
        } else {
            // not
            selectedFriends.append(type!)
        }
        
        //remove the lbl
        selectedIDs.removeAll()
        selectedNames.removeAll()
        for item in selectedFriends {
            selectedIDs.append(item.userId )
            selectedNames.append(item.userName )
        }
        
        print("selectedIDs = \(selectedIDs)")
        print("selectedNames = \(selectedNames)")
        tableView.reloadData()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if (((scrollView.contentOffset.y + scrollView.frame.size.height) > scrollView.contentSize.height ) && !isLoadingList){
            self.isLoadingList = true
            
            if currentPage < viewmodel.friends.value?.totalPages ?? 0 {
                self.tableView.tableFooterView = self.createFooterView()
                
                DispatchQueue.main.asyncAfter(wallDeadline: .now() + 2) {
                    print("self.currentPage >> \(self.currentPage)")
                    self.loadMoreFriendItems()
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
