//
//  SelectFriendsVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 13/03/2022.
//

import UIKit
import ListPlaceholder
import Network

class SelectFriendsVC: UIViewController {

    //MARK: - Outlets
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var selectImg: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var selectAllBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var hideViews: UIView!
    @IBOutlet var profileImgViews: [UIImageView]!
    @IBOutlet var namesFirendsViews: [UIImageView]!
    @IBOutlet var selectImgsView: [UIImageView]!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var tryAgainBtn: UIButton!
    @IBOutlet weak var emptyLbl: UILabel!
    @IBOutlet weak var emptyImg: UIImageView!
    
    //MARK: - Properties
    let cellID = "AddFriendsToPrivateEventTableViewCell"
    let emptyCellID = "EmptyViewTableViewCell"

    var viewmodel:AllFriendesViewModel = AllFriendesViewModel()
    
    var cellSelected:Bool = false
    var currentPage : Int = 1
    var isLoadingList : Bool = false
    var selectedIDs = [String]()
    var selectedNames = [String]()
    var selectedFriends:[UserConversationModel] = [UserConversationModel]()

    var onListFriendsCallBackResponse: ((_ listIDs: [String],_ listNames: [String],_ selectFriends:[UserConversationModel]) -> ())?

    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Select Attendees".localizedString
        
        initCancelBarButton()
        setupSearchBar()
        setupViews()
        
        DispatchQueue.main.async {
            self.updateUserInterface()
        }
        
        setupHideView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        print("availableVC >> \(Defaults.availableVC)")
    }
        
    //MARK: - APIs
    func loadMoreItemsForList(){
        currentPage += 1
        getAllFriends(pageNumber: currentPage, search: searchBar.text ?? "")
    }
    
    func getAllFriends(pageNumber:Int,search:String) {
        hideViews.isHidden = true
        viewmodel.getAllFriendes(pageNumber: pageNumber, search: search)
        viewmodel.friends.bind { [weak self] value in
            DispatchQueue.main.async {
                self?.tableView.hideLoader()
                self?.tableView.delegate = self
                self?.tableView.dataSource = self
                self?.tableView.reloadData()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self?.isLoadingList = false
                    self?.tableView.tableFooterView = nil
                }

                DispatchQueue.main.async {
                    if self?.selectedIDs.count == value.data?.count {
                        self?.selectAllBtn.isSelected = true
                    }else {
                        self?.selectAllBtn.isSelected = false
                    }
                }
            }
        }
        
        // Set View Model Event Listener
        viewmodel.error.bind { [weak self]error in
            DispatchQueue.main.async {
                if error == "Internal Server Error" {
                    self?.HandleInternetConnection()
                }else {
                    DispatchQueue.main.async {
                        self?.view.makeToast(error)
                    }
                    
                }
            }
        }
    }
    
    func LaodAllFriends(pageNumber:Int,search:String) {
        hideViews.isHidden = false
        hideViews.showLoader()
        viewmodel.getAllFriendes(pageNumber: pageNumber, search: search)
        viewmodel.friends.bind { [weak self] value in
            DispatchQueue.main.async {
                self?.tableView.delegate = self
                self?.tableView.dataSource = self
                self?.tableView.reloadData()
                
                DispatchQueue.main.async {
                    self?.hideViews.isHidden = true
                    self?.hideViews.hideLoader()
                }
                
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
                }else {
                    DispatchQueue.main.async {
                        self?.view.makeToast(error)
                    }
                    
                }
            }
        }
    }

    //MARK: - Helpers
    func setupHideView() {
        for itm in profileImgViews {
            itm.cornerRadiusForHeight()
        }
        
        for item in namesFirendsViews {
            item.cornerRadiusView(radius: 6)
        }
        
        for itmm in selectImgsView {
            itmm.cornerRadiusView(radius: 6)
        }
    }
    
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
                self.LaodAllFriends(pageNumber: 1, search: self.searchBar.text ?? "")
            }
        case .wifi:
            DispatchQueue.main.async {
                NetworkConected.internetConect = true
                self.LaodAllFriends(pageNumber: 1, search: self.searchBar.text ?? "")
            }
        }
        
        print("Reachability Summary")
        print("Status:", Network.reachability.status)
        print("HostName:", Network.reachability.hostname ?? "nil")
        print("Reachable:", Network.reachability.isReachable)
        print("Wifi:", Network.reachability.isReachableViaWiFi)
    }
    
    func setupSearchBar() {
        searchBar.delegate = self
        searchView.cornerRadiusView(radius: 6)
        searchView.setBorder()
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
    
    func setupViews() {
        tableView.allowsMultipleSelection = true
        tableView.register(UINib(nibName: cellID, bundle: nil), forCellReuseIdentifier: cellID)
        saveBtn.cornerRadiusView(radius: 8)
        tryAgainBtn.cornerRadiusView(radius: 8)
    }
    
    func HandleInternetConnection() {
        if cellSelected {
            emptyView.isHidden = true
            self.view.makeToast("Network is unavailable, please try again!".localizedString)
        }else {
            emptyView.isHidden = false
            emptyImg.image = UIImage.init(named: "myEventnodata_img")
            emptyLbl.text = "Network is unavailable, please try again!".localizedString
            tryAgainBtn.alpha = 1.0
        }
    }
    
    func showEmptyView() {
        let model = viewmodel.friends.value?.data
        tryAgainBtn.alpha = 0.0
        if model?.count != 0 {
            emptyView.isHidden = true
        }else {
            emptyView.isHidden = false
            emptyLbl.text = "You haven't any data yet".localizedString
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
    
    //MARK: - ACtions
    @IBAction func selectAllBtn(_ sender: Any) {
        selectAllBtn.isSelected = !selectAllBtn.isSelected
        
        if selectAllBtn.isSelected {
            selectImg.image = UIImage(named: "selected_ic")
            let totalRows = tableView.numberOfRows(inSection: 0)
            for row in 0..<totalRows {
                let index = IndexPath(row: row, section: 0 )
                tableView.selectRow(at: index, animated: false, scrollPosition: .none)
            }
            
            selectedIDs.removeAll()
            selectedNames.removeAll()
            selectedFriends.removeAll()
            for itm in viewmodel.friends.value?.data ?? [] {
                selectedIDs.append(itm.userId)
                selectedNames.append(itm.userName)
                selectedFriends.append(itm)
            }
        }else {
            selectImg.image = UIImage(named: "unSelected_ic")
            let totalRows = tableView.numberOfRows(inSection: 0)
            for row in 0..<totalRows {
                let index = IndexPath(row: row, section: 0 )
                tableView.deselectRow(at: index, animated: false)
            }
            
            selectedIDs.removeAll()
            selectedNames.removeAll()
            selectedFriends.removeAll()
        }
        
        tableView.reloadData()
    }
    
    @IBAction func saveBtn(_ sender: Any) {
        self.onListFriendsCallBackResponse!(selectedIDs,selectedNames,selectedFriends)
        self.onDismiss()
    }
}

//MARK: - Extensions UISearchBarDelegate
extension SelectFriendsVC : UISearchBarDelegate {
    @objc func updateSearchResult() {
        guard let text = searchBar.text else {return}
        print(text)
        
        if NetworkConected.internetConect {
            self.getAllFriends(pageNumber: 1, search: text)
        }
    }
}

//MARK: - Extensions UITableViewDataSource
extension SelectFriendsVC :UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewmodel.friends.value?.data?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? AddFriendsToPrivateEventTableViewCell else {return UITableViewCell()}
        let model = viewmodel.friends.value?.data?[indexPath.row]
        cell.titleLbl.text = model?.userName
        cell.profileImg.sd_setImage(with: URL(string: model?.image ?? "" ), placeholderImage: UIImage(named: "userPlaceHolderImage"))
        
        if selectedIDs.contains(model?.userId ?? "") {
            cell.selectedImg.image = UIImage(named: "selected_ic")
        }
        else {
            cell.selectedImg.image = UIImage(named: "unSelected_ic")
        }
        
        if indexPath.row == ((viewmodel.friends.value?.data?.count ?? 0) - 1) {
            cell.bottomView.isHidden = true
        }
        
        cell.layoutSubviews()
        
        return cell
    }
}

//MARK: - Extensions UITableViewDelegate
extension SelectFriendsVC:UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        selectImg.image = UIImage(named: "unSelected_ic")
        selectAllBtn.isSelected = false

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
        selectImg.image = UIImage(named: "unSelected_ic")
        selectAllBtn.isSelected = false
        
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
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
//                    self.view.makeToast("No more data".localizedString)
                }
                return
            }
        }
    }
}
