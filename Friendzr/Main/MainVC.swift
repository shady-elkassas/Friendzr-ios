//
//  ViewController.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 10/08/2021.
//

import UIKit
import SwiftUI

class MainVC: UIViewController {
    
    //MARK:- Outlets
    @IBOutlet weak var searchContainerView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var tryAgainBtn: UIButton!
    @IBOutlet weak var emptyLbl: UILabel!
    @IBOutlet weak var emptyImg: UIImageView!
    
    //MARK: - Properties
    let cellID = "ChatListTableViewCell"
    
    var viewmodel:ChatViewModel = ChatViewModel()
    var searchVM:SearchUserViewModel = SearchUserViewModel()
    
    var refreshControl = UIRefreshControl()
    
    var internetConect:Bool = false
    var cellSelect:Bool = false
    
    var currentPage : Int = 1
    var isLoadingList : Bool = false
    
    var isSearch:Bool = false
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        initProfileBarButton()
        initNewConversationBarButton()
        self.title = "Inbox"
        
        pullToRefresh()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadChatList), name: Notification.Name("reloadChatList"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        hideNavigationBar(NavigationBar: false, BackButton: true)
        DispatchQueue.main.async {
            self.updateUserInterface()
        }
    }
    
    //MARK:- APIs
    
    @objc func reloadChatList() {
        getAllChatList(pageNumber: 1)
    }
    
    func loadMoreItemsForList(){
        currentPage += 1
        getAllChatList(pageNumber: currentPage)
    }
    
    func getAllChatList(pageNumber:Int) {
        self.showLoading()
        viewmodel.getChatList(pageNumber: pageNumber)
        viewmodel.listChat.bind { [unowned self] value in
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
                }else if error == "Bad Request" {
                    HandleinvalidUrl()
                }else {
                    self.showAlert(withMessage: error)
                }
            }
        }
    }
    
    func getSearchUsers(text:String) {
//        self.showLoading()
        searchVM.SearshUsersinChat(ByUserName: text)
        searchVM.usersinChat.bind { [unowned self] value in
            DispatchQueue.main.async {
                self.hideLoading()
                tableView.delegate = self
                tableView.dataSource = self
                tableView.reloadData()
                showEmptyView()
            }
        }
        
        // Set View Model Event Listener
        searchVM.error.bind { [unowned self]error in
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
    
    func showEmptyView() {
        if viewmodel.listChat.value?.data?.count == 0 {
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
            getAllChatList(pageNumber: 1)
        case .wifi:
            internetConect = true
            self.emptyView.isHidden = true
            getAllChatList(pageNumber: 1)
        }
        
        print("Reachability Summary")
        print("Status:", Network.reachability.status)
        print("HostName:", Network.reachability.hostname ?? "nil")
        print("Reachable:", Network.reachability.isReachable)
        print("Wifi:", Network.reachability.isReachableViaWiFi)
    }
    
    func setupView() {
        setupSearchBar()
        tableView.register(UINib(nibName: cellID, bundle: nil), forCellReuseIdentifier: cellID)
        tryAgainBtn.cornerRadiusView(radius: 8)
    }
    
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
        searchBar.searchTextField.addTarget(self, action: #selector(updateSearchResult), for: .editingChanged)
    }
}

//MARK: - Extensions
extension MainVC:UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearch {
            return searchVM.usersinChat.value?.data?.count ?? 0
        }else {
            return viewmodel.listChat.value?.data?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isSearch {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? ChatListTableViewCell else {return UITableViewCell()}
            let model = searchVM.usersinChat.value?.data?[indexPath.row]
            cell.nameLbl.text = model?.chatName
            cell.lastMessageLbl.text = model?.messages
            cell.lastMessageDateLbl.text = "\(model?.latestdate ?? "") \(model?.latesttime ?? "")"
            
            cell.profileImg.sd_setImage(with: URL(string: model?.image ?? "" ), placeholderImage: UIImage(named: "photo_img"))
            
            if viewmodel.listChat.value?.data?.count ?? 0 != 0 {
                if indexPath.row == ((viewmodel.listChat.value?.data?.count ?? 0) - 1) {
                    cell.underView.isHidden = true
                }
            }
            return cell
        }else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? ChatListTableViewCell else {return UITableViewCell()}
            let model = viewmodel.listChat.value?.data?[indexPath.row]
            cell.nameLbl.text = model?.chatName
            cell.lastMessageLbl.text = model?.messages
            cell.lastMessageDateLbl.text = "\(model?.latestdate ?? "") \(model?.latesttime ?? "")"
            
            cell.profileImg.sd_setImage(with: URL(string: model?.image ?? "" ), placeholderImage: UIImage(named: "photo_img"))
            
            if viewmodel.listChat.value?.data?.count ?? 0 != 0 {
                if indexPath.row == ((viewmodel.listChat.value?.data?.count ?? 0) - 1) {
                    cell.underView.isHidden = true
                }
            }
            return cell
        }
    }
}
extension MainVC:UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var model = viewmodel.listChat.value?.data?[indexPath.row]
        
        if isSearch {
            model = searchVM.usersinChat.value?.data?[indexPath.row]
        }
        
        guard let vc = UIViewController.viewController(withStoryboard: .Main, AndContollerID: "ChatVC") as? ChatVC else {return}
        if model?.isevent == true {
            vc.eventChat = true
            vc.eventChatID = model?.id ?? ""
            vc.chatuserID = ""
            vc.eventImage = model?.image ?? ""
        }else {
            vc.eventChat = false
            vc.eventChatID = ""
            vc.chatuserID = model?.id ?? ""
        }
        
        vc.titleChatName = model?.chatName ?? ""
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let model = self.viewmodel.listChat.value?.data?[indexPath.row]
        let archiveTitle = self.viewmodel.listChat.value?.data?[indexPath.row].isArchive ?? false ? "UnArchive" : "Archive"
        let muteTitle = self.viewmodel.listChat.value?.data?[indexPath.row].isMute ?? false ? "UnMute" : "Mute"
        
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { action, indexPath in
            print("deleteAction")
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                let settingsActionSheet: UIAlertController = UIAlertController(title:nil, message:nil, preferredStyle: .alert)
                
                settingsActionSheet.addAction(UIAlertAction(title:"Confirm".localizedString, style:UIAlertAction.Style.default, handler:{ action in
                    self.showLoading()
                    self.viewmodel.deleteChat(ByID: model?.id ?? "", isevent: model?.isevent ?? false) { error, data in
                        self.hideLoading()
                        if let error = error {
                            self.showAlert(withMessage: error)
                            return
                        }
                        
                        guard let _ = data else {
                            return
                        }
                        
                        DispatchQueue.main.async {
                            self.viewmodel.listChat.value?.data?.remove(at: indexPath.row)
                            self.tableView.beginUpdates()
                            self.tableView.deleteRows(at: [indexPath], with: .fade)
                            self.tableView.endUpdates()
                        }
                    }
                }))
                settingsActionSheet.addAction(UIAlertAction(title:"Cancel".localizedString, style:UIAlertAction.Style.cancel, handler:nil))
                
                self.present(settingsActionSheet, animated:true, completion:nil)
            }else {
                let settingsActionSheet: UIAlertController = UIAlertController(title:nil, message:nil, preferredStyle:UIAlertController.Style.actionSheet)
                
                settingsActionSheet.addAction(UIAlertAction(title:"Confirm".localizedString, style:UIAlertAction.Style.default, handler:{ action in
                    self.showLoading()
                    self.viewmodel.deleteChat(ByID: model?.id ?? "", isevent: model?.isevent ?? false) { error, data in
                        self.hideLoading()
                        if let error = error {
                            self.showAlert(withMessage: error)
                            return
                        }
                        
                        guard let _ = data else {
                            return
                        }
                        
                        DispatchQueue.main.async {
                            self.viewmodel.listChat.value?.data?.remove(at: indexPath.row)
                            self.tableView.beginUpdates()
                            self.tableView.deleteRows(at: [indexPath], with: .fade)
                            self.tableView.endUpdates()
                        }
                    }
                }))
                settingsActionSheet.addAction(UIAlertAction(title:"Cancel".localizedString, style:UIAlertAction.Style.cancel, handler:nil))
                
                self.present(settingsActionSheet, animated:true, completion:nil)
            }
        }
        
        let archiveAction = UITableViewRowAction(style: .default, title: archiveTitle) { action, indexPath in
            print("archiveAction")
            //            self.viewmodel.listChat.value?.data?[indexPath.row].isArchive?.toggle()
            //            tableView.reloadData()
            //            self.view.makeToast("Archived")
        }
        
        let muteAction = UITableViewRowAction(style: .default, title: muteTitle) { action, indexPath in
            print("muteAction")
            if model?.isMute == true {
                if UIDevice.current.userInterfaceIdiom == .pad {
                    let settingsActionSheet: UIAlertController = UIAlertController(title:nil, message:nil, preferredStyle: .alert)
                    
                    settingsActionSheet.addAction(UIAlertAction(title:"Confirm".localizedString, style:UIAlertAction.Style.default, handler:{ action in
                        self.showLoading()
                        self.viewmodel.muteChat(ByID: model?.id ?? "", isevent: model?.isevent ?? false, mute: false) { error, data in
                            self.hideLoading()
                            if let error = error {
                                self.showAlert(withMessage: error)
                                return
                            }
                            
                            guard let _ = data else {
                                return
                            }
                            
                            DispatchQueue.main.async {
                                self.viewmodel.listChat.value?.data?[indexPath.row].isMute?.toggle()
                                tableView.reloadData()
                            }
                        }
                    }))
                    settingsActionSheet.addAction(UIAlertAction(title:"Cancel".localizedString, style:UIAlertAction.Style.cancel, handler:nil))
                    
                    self.present(settingsActionSheet, animated:true, completion:nil)
                }else {
                    let settingsActionSheet: UIAlertController = UIAlertController(title:nil, message:nil, preferredStyle:UIAlertController.Style.actionSheet)
                    
                    settingsActionSheet.addAction(UIAlertAction(title:"Confirm".localizedString, style:UIAlertAction.Style.default, handler:{ action in
                        self.showLoading()
                        self.viewmodel.muteChat(ByID: model?.id ?? "", isevent: model?.isevent ?? false, mute: false) { error, data in
                            self.hideLoading()
                            if let error = error {
                                self.showAlert(withMessage: error)
                                return
                            }
                            
                            guard let _ = data else {
                                return
                            }
                            
                            DispatchQueue.main.async {
                                self.viewmodel.listChat.value?.data?[indexPath.row].isMute?.toggle()
                                tableView.reloadData()
                            }
                            
                        }
                    }))
                    settingsActionSheet.addAction(UIAlertAction(title:"Cancel".localizedString, style:UIAlertAction.Style.cancel, handler:nil))
                    
                    self.present(settingsActionSheet, animated:true, completion:nil)
                }
            }else {
                if UIDevice.current.userInterfaceIdiom == .pad {
                    let settingsActionSheet: UIAlertController = UIAlertController(title:nil, message:nil, preferredStyle: .alert)
                    
                    settingsActionSheet.addAction(UIAlertAction(title:"Confirm".localizedString, style:UIAlertAction.Style.default, handler:{ action in
                        self.showLoading()
                        self.viewmodel.muteChat(ByID: model?.id ?? "", isevent: model?.isevent ?? false, mute: true) { error, data in
                            self.hideLoading()
                            if let error = error {
                                self.showAlert(withMessage: error)
                                return
                            }
                            
                            guard let _ = data else {
                                return
                            }
                            
                            DispatchQueue.main.async {
                                self.viewmodel.listChat.value?.data?[indexPath.row].isMute?.toggle()
                                tableView.reloadData()
                            }
                        }
                    }))
                    settingsActionSheet.addAction(UIAlertAction(title:"Cancel".localizedString, style:UIAlertAction.Style.cancel, handler:nil))
                    
                    self.present(settingsActionSheet, animated:true, completion:nil)
                }else {
                    let settingsActionSheet: UIAlertController = UIAlertController(title:nil, message:nil, preferredStyle:UIAlertController.Style.actionSheet)
                    
                    settingsActionSheet.addAction(UIAlertAction(title:"Confirm".localizedString, style:UIAlertAction.Style.default, handler:{ action in
                        self.showLoading()
                        self.viewmodel.muteChat(ByID: model?.id ?? "", isevent: model?.isevent ?? false, mute: true) { error, data in
                            self.hideLoading()
                            if let error = error {
                                self.showAlert(withMessage: error)
                                return
                            }
                            
                            guard let _ = data else {
                                return
                            }
                            
                            DispatchQueue.main.async {
                                self.viewmodel.listChat.value?.data?[indexPath.row].isMute?.toggle()
                                tableView.reloadData()
                            }
                        }
                    }))
                    settingsActionSheet.addAction(UIAlertAction(title:"Cancel".localizedString, style:UIAlertAction.Style.cancel, handler:nil))
                    
                    self.present(settingsActionSheet, animated:true, completion:nil)
                }
            }
        }
        
        archiveAction.backgroundColor = UIColor.blue
        muteAction.backgroundColor = UIColor.green
        return [deleteAction,archiveAction,muteAction]
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if isSearch {
            print("Search")
        }else {
            if (((scrollView.contentOffset.y + scrollView.frame.size.height) > scrollView.contentSize.height ) && !isLoadingList){
                self.isLoadingList = true
                if currentPage < viewmodel.listChat.value?.totalPages ?? 0 {
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
}

extension MainVC: UISearchBarDelegate{
    @objc func updateSearchResult() {
        guard let text = searchBar.text else {return}
        print(text)
        if text != "" {
            isSearch = true
            getSearchUsers(text: text)
        }else {
            isSearch = false
            getAllChatList(pageNumber: 0)
        }
    }
    
    func initNewConversationBarButton() {
        let button = UIButton.init(type: .custom)
        button.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
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
