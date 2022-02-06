//
//  AddNewUsersForMyGroupVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 18/01/2022.
//

import UIKit

class AddNewUsersForMyGroupVC: UIViewController {
    
    @IBOutlet weak var searchbar: UISearchBar!
    @IBOutlet weak var searchBarView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var emptyView: UIView!
    
    //MARK: - Properties
    let cellID = "SelectedFriendTableViewCell"
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
    
    //MARK: - Helper
    func updateUserInterface() {
        appDelegate.networkReachability()
        
        switch Network.reachability.status {
        case .unreachable:
            internetConnect = false
            HandleInternetConnection()
        case .wwan:
            internetConnect = true
            LaodAllFriends(pageNumber: 1, search: searchbar.text ?? "")
        case .wifi:
            internetConnect = true
            LaodAllFriends(pageNumber: 1, search: searchbar.text ?? "")
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
            internetConnect = false
            HandleInternetConnection()
        case .wwan:
            internetConnect = true
        case .wifi:
            internetConnect = true
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
        self.view.makeToast("No avaliable network ,Please try again!".localizedString)
    }
    
    
    //MARK:- APIs
    func loadMoreItemsForList(){
        currentPage += 1
        getAllFriends(pageNumber: currentPage, search: searchbar.text ?? "")
    }
    
    func getAllFriends(pageNumber:Int,search:String) {
        viewmodel.getAllFriendes(pageNumber: pageNumber, search: search)
        viewmodel.friends.bind { [unowned self] value in
            DispatchQueue.main.async {
                tableView.hideLoader()
                tableView.delegate = self
                tableView.dataSource = self
                tableView.reloadData()
                
                self.isLoadingList = false
                self.tableView.tableFooterView = nil
            }
        }
        
        // Set View Model Event Listener
        viewmodel.error.bind { [unowned self]error in
            DispatchQueue.main.async {
                if error == "Internal Server Error" {
                    HandleInternetConnection()
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
                tableView.delegate = self
                tableView.dataSource = self
                tableView.reloadData()
                
                
                if value.data?.count != 0 {
                    tableView.showLoader()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.tableView.hideLoader()
                    }
                }
                
                self.isLoadingList = false
                self.tableView.tableFooterView = nil
                showEmptyView()
            }
        }
        
        // Set View Model Event Listener
        viewmodel.error.bind { [unowned self]error in
            DispatchQueue.main.async {
                if error == "Internal Server Error" {
                    HandleInternetConnection()
                }else {
                    DispatchQueue.main.async {
                        self.view.makeToast(error)
                    }
                    
                }
            }
        }
    }
    
    
    func showEmptyView() {
        let model = viewmodel.friends.value?.data
        if model?.count != 0 {
            emptyView.isHidden = true
        }else {
            emptyView.isHidden = false
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
    
    
    @IBAction func doneBtn(_ sender: Any) {
        let actionDate = formatterDate.string(from: Date())
        let actionTime = formatterTime.string(from: Date())
        
        if selectedIDs.count == 0 {
            self.view.makeToast("Please select a group of friends".localizedString)
        }else {
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
                
                DispatchQueue.main.async {
                    self.view.makeToast("New friends have been added to the group successfully".localizedString)
                }
                
                DispatchQueue.main.asyncAfter(wallDeadline: .now() + 1) {
                    self.onDismiss()
                }
            }
        }
    }
}


//MARK: - Extensions
extension AddNewUsersForMyGroupVC : UISearchBarDelegate {
    @objc func updateSearchResult() {
        guard let text = searchbar.text else {return}
        print(text)
        
        getAllFriends(pageNumber: 1, search: text)
    }
}

extension AddNewUsersForMyGroupVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewmodel.friends.value?.data?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? SelectedFriendTableViewCell else {return UITableViewCell()}
        let model = viewmodel.friends.value?.data?[indexPath.row]
        cell.titleLbl.text = model?.userName
        cell.profileImg.sd_setImage(with: URL(string: model?.image ?? "" ), placeholderImage: UIImage(named: "placeholder"))
        
        if indexPath.row == ((viewmodel.friends.value?.data?.count ?? 0) - 1 ) {
            cell.bottomView.isHidden = true
        }
        
        return cell
    }
}

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
                    self.view.makeToast("No more data here".localizedString)
                }
                return
            }
        }
    }
}
