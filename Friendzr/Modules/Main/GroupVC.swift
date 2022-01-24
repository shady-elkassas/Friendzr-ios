//
//  GroupVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 10/01/2022.
//

import UIKit
import ListPlaceholder

class GroupVC: UIViewController {
    
    @IBOutlet weak var superView: UIView!
    @IBOutlet weak var groupImg: UIImageView!
    @IBOutlet weak var cameraBtn: UIButton!
    @IBOutlet weak var nameTxtView: UIView!
    @IBOutlet weak var nameTxt: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addUsersBtn: UIButton!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var searchbar: UISearchBar!
    @IBOutlet weak var searchBarView: UIView!
    
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
    
    let cellID = "SelectedFriendTableViewCell"
    let emptyCellID = "EmptyViewTableViewCell"

    var groupId:String = ""
    var isGroupAdmin:Bool = false
    
    //    var attachedImg:Bool = false
    let imagePicker = UIImagePickerController()
    
    var viewmodel:GroupViewModel = GroupViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        title = "Group Details"
        
        getGroupDetails()
        setupSearchBar()
        initBackChatButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupNavBar()
    }
    
    func setupViews() {
        tableView.register(UINib(nibName: cellID, bundle: nil), forCellReuseIdentifier: cellID)
        
        nameTxt.isUserInteractionEnabled = false
        nameTxtView.cornerRadiusView(radius: 8)
        cameraBtn.isHidden = true
        nameTxtView.setBorder()
        groupImg.setBorder()
        groupImg.cornerRadiusForHeight()
        addUsersBtn.cornerRadiusView(radius: 8)
        
        initEditAndOptionButton()
        
        if isGroupAdmin {
            addUsersBtn.isHidden = false
        }else {
            addUsersBtn.isHidden = true
        }
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
    
    
    func getGroupDetails() {
//        self.showLoading()
        self.superView.showLoader()
        viewmodel.getGroupDetails(id: groupId)
        viewmodel.groupMembers.bind { [unowned self] value in
            DispatchQueue.main.async {
                self.hideLoading()
                tableView.delegate = self
                tableView.dataSource = self
                tableView.reloadData()
                
                tableViewHeight.constant = CGFloat((value.chatGroupSubscribers?.count ?? 0) * 75)
                
                groupImg.sd_setImage(with: URL(string: value.image ?? "" ), placeholderImage: UIImage(named: "placeholder"))
                nameTxt.text = value.name
                
                self.superView.hideLoader()
            }
        }
        
        // Set View Model Event Listener
        viewmodel.errorMsg.bind { [unowned self]error in
            DispatchQueue.main.async {
                self.hideLoading()
                DispatchQueue.main.async {
                    self.view.makeToast(error)
                }
                
            }
        }
    }
    
    @IBAction func editImgBtn(_ sender: Any) {
        if UIDevice.current.userInterfaceIdiom == .pad {
            let settingsActionSheet: UIAlertController = UIAlertController(title:nil, message:nil, preferredStyle: .alert)
            
            settingsActionSheet.addAction(UIAlertAction(title:"Camera".localizedString, style:UIAlertAction.Style.default, handler:{ action in
                self.openCamera()
            }))
            settingsActionSheet.addAction(UIAlertAction(title:"Photo Liberary".localizedString, style:UIAlertAction.Style.default, handler:{ action in
                self.openLibrary()
            }))
            settingsActionSheet.addAction(UIAlertAction(title:"Cancel".localizedString, style:UIAlertAction.Style.cancel, handler:nil))
            
            present(settingsActionSheet, animated:true, completion:nil)
            
        }else {
            let settingsActionSheet: UIAlertController = UIAlertController(title:nil, message:nil, preferredStyle:UIAlertController.Style.actionSheet)
            
            settingsActionSheet.addAction(UIAlertAction(title:"Camera".localizedString, style:UIAlertAction.Style.default, handler:{ action in
                self.openCamera()
            }))
            settingsActionSheet.addAction(UIAlertAction(title:"Photo Liberary".localizedString, style:UIAlertAction.Style.default, handler:{ action in
                self.openLibrary()
            }))
            settingsActionSheet.addAction(UIAlertAction(title:"Cancel".localizedString, style:UIAlertAction.Style.cancel, handler:nil))
            
            present(settingsActionSheet, animated:true, completion:nil)
        }
    }
    
    @IBAction func addUsersBtn(_ sender: Any) {
        if let controller = UIViewController.viewController(withStoryboard: .Main, AndContollerID: "AddNewUsersForMyGroupNC") as? UINavigationController, let vc = controller.viewControllers.first as? AddNewUsersForMyGroupVC {
            vc.groupId = groupId
            
            self.present(controller, animated: true)
        }
    }
}

extension GroupVC {
    func initBackChatButton() {
        
        var imageName = ""
        if Language.currentLanguage() == "ar" {
            imageName = "back_icon"
        }else {
            imageName = "back_icon"
        }
        
        let button = UIButton.init(type: .custom)
        let image = UIImage.init(named: imageName)
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        button.setImage(image, for: .normal)
        image?.withTintColor(UIColor.blue)
        button.addTarget(self, action:  #selector(backToConversationVC), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.leftBarButtonItem = barButton
    }
    
    @objc func backToConversationVC() {
//        let model = viewmodel.groupMembers.value
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
//            Router().toConversationVC(isEvent: false, eventChatID: "", leavevent: 0, chatuserID: "", isFriend: false, titleChatImage: model?.image ?? "", titleChatName: model?.name ?? "", isChatGroupAdmin: self.isGroupAdmin, isChatGroup: true, groupId: self.groupId,leaveGroup: model?.leaveGroup ?? 0)
//        })
        Router().toHome()
    }
    
    
    
    func initEditAndOptionButton(btnColor: UIColor? = .red) {
        let btn1 = UIButton.init(type: .custom)
        btn1.setImage(UIImage(named: "menu_H_ic"), for: .normal)
        btn1.tintColor = .black
        btn1.setTitleColor(.red, for: .normal)
        if isGroupAdmin {
            btn1.addTarget(self, action:  #selector(handleAdminOptionBtn), for: .touchUpInside)

        }else {
            btn1.addTarget(self, action:  #selector(handleUserOptionBtn), for: .touchUpInside)
        }
        
        let barButton1 = UIBarButtonItem(customView: btn1)
        
        
        let btn2 = UIButton.init(type: .custom)
        btn2.setTitle("Edit".localizedString, for: .normal)
        btn2.setTitleColor(.blue, for: .normal)
        btn2.titleLabel?.font = UIFont(name: "Montserrat-Medium", size: 14)
        btn2.addTarget(self, action:  #selector(handleEditBtn), for: .touchUpInside)
        let barButton2 = UIBarButtonItem(customView: btn2)
        
        if isGroupAdmin == true {
            self.navigationItem.rightBarButtonItems = [barButton1,barButton2]
        }else {
            self.navigationItem.rightBarButtonItems = [barButton1]
        }
    }
    
    func initSaveAndOptionButton(btnColor: UIColor? = .red) {
        let btn1 = UIButton.init(type: .custom)
        btn1.setImage(UIImage(named: "menu_H_ic"), for: .normal)
        btn1.tintColor = .black
        btn1.setTitleColor(.red, for: .normal)
        if isGroupAdmin {
            btn1.addTarget(self, action:  #selector(handleAdminOptionBtn), for: .touchUpInside)

        }else {
            btn1.addTarget(self, action:  #selector(handleUserOptionBtn), for: .touchUpInside)
        }
        
        let barButton1 = UIBarButtonItem(customView: btn1)
        
        
        let btn2 = UIButton.init(type: .custom)
        btn2.setTitle("Save".localizedString, for: .normal)
        btn2.setTitleColor(.blue, for: .normal)
        btn2.titleLabel?.font = UIFont(name: "Montserrat-Medium", size: 14)
        btn2.addTarget(self, action:  #selector(handleSaveBtn), for: .touchUpInside)
        let barButton2 = UIBarButtonItem(customView: btn2)
        
        if isGroupAdmin == true {
            self.navigationItem.rightBarButtonItems = [barButton1,barButton2]
        }else {
            self.navigationItem.rightBarButtonItems = [barButton1]
        }
    }
    
    @objc func handleEditBtn() {
        self.nameTxt.isUserInteractionEnabled = true
        self.cameraBtn.isHidden = false
        self.initSaveAndOptionButton()
    }
    
    @objc func handleSaveBtn() {
        self.showLoading()
        self.viewmodel.updateGroup(ByID: self.groupId, AndName: nameTxt.text!, attachedImg: true, AndImage: groupImg.image ?? UIImage()) { error, data in
            self.hideLoading()
            if let error = error {
                DispatchQueue.main.async {
                    self.view.makeToast(error)
                }
                return
            }
            
            guard let _ = data else {return}
            
            DispatchQueue.main.async {
                self.view.makeToast("Changed successfully".localizedString)
            }
            
            DispatchQueue.main.async {
                self.nameTxt.isUserInteractionEnabled = false
                self.cameraBtn.isHidden = true
                
                self.initEditAndOptionButton()
            }
        }
    }
    
    @objc func handleAdminOptionBtn() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            let actionAlert  = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
            actionAlert.addAction(UIAlertAction(title: "Delete".localizedString, style: .default, handler: { action in
                self.handleDeleteGroup()
            }))
            actionAlert.addAction(UIAlertAction(title: "Leave".localizedString, style: .default, handler: { action in
                self.handleLeaveGroup()
            }))
            actionAlert.addAction(UIAlertAction(title: "Cancel".localizedString, style: .cancel, handler: {  _ in
            }))
            
            present(actionAlert, animated: true, completion: nil)
        }else {
            let actionSheet  = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            actionSheet.addAction(UIAlertAction(title: "Delete".localizedString, style: .default, handler: { action in
                self.handleDeleteGroup()
            }))
            actionSheet.addAction(UIAlertAction(title: "Leave".localizedString, style: .default, handler: { action in
                self.handleLeaveGroup()
            }))
            
            actionSheet.addAction(UIAlertAction(title: "Cancel".localizedString, style: .cancel, handler: {  _ in
            }))
            
            present(actionSheet, animated: true, completion: nil)
        }
    }

    @objc func handleUserOptionBtn() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            let actionAlert  = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
            actionAlert.addAction(UIAlertAction(title: "Leave".localizedString, style: .default, handler: { action in
                self.handleLeaveGroup()
            }))
            actionAlert.addAction(UIAlertAction(title: "Cancel".localizedString, style: .cancel, handler: {  _ in
            }))
            
            present(actionAlert, animated: true, completion: nil)
        }else {
            let actionSheet  = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            actionSheet.addAction(UIAlertAction(title: "Leave".localizedString, style: .default, handler: { action in
                self.handleLeaveGroup()
            }))
            
            actionSheet.addAction(UIAlertAction(title: "Cancel".localizedString, style: .cancel, handler: {  _ in
            }))
            
            present(actionSheet, animated: true, completion: nil)
        }
    }
    
    func handleDeleteGroup() {
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            let settingsActionSheet: UIAlertController = UIAlertController(title:"Are you sure you want to delete this group?".localizedString, message:nil, preferredStyle: .alert)
            
            settingsActionSheet.addAction(UIAlertAction(title:"Confirm".localizedString, style:UIAlertAction.Style.default, handler:{ action in
                self.deleteGroup()
            }))
            settingsActionSheet.addAction(UIAlertAction(title:"Cancel".localizedString, style:UIAlertAction.Style.cancel, handler:nil))
            
            present(settingsActionSheet, animated:true, completion:nil)
            
        }else {
            let settingsActionSheet: UIAlertController = UIAlertController(title:"Are you sure you want to delete this group?".localizedString, message:nil, preferredStyle:UIAlertController.Style.actionSheet)
            
            settingsActionSheet.addAction(UIAlertAction(title:"Confirm".localizedString, style:UIAlertAction.Style.default, handler:{ action in
                self.deleteGroup()
            }))
            settingsActionSheet.addAction(UIAlertAction(title:"Cancel".localizedString, style:UIAlertAction.Style.cancel, handler:nil))
            
            present(settingsActionSheet, animated:true, completion:nil)
        }
    }
    
    func handleLeaveGroup() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            let settingsActionSheet: UIAlertController = UIAlertController(title:"Are you sure you want to leave from this group?".localizedString, message:nil, preferredStyle: .alert)
            
            settingsActionSheet.addAction(UIAlertAction(title:"Confirm".localizedString, style:UIAlertAction.Style.default, handler:{ action in
                self.leaveGroup()
            }))
            settingsActionSheet.addAction(UIAlertAction(title:"Cancel".localizedString, style:UIAlertAction.Style.cancel, handler:nil))
            
            present(settingsActionSheet, animated:true, completion:nil)
            
        }else {
            let settingsActionSheet: UIAlertController = UIAlertController(title:"Are you sure you want to leave from this group?".localizedString, message:nil, preferredStyle:UIAlertController.Style.actionSheet)
            
            settingsActionSheet.addAction(UIAlertAction(title:"Confirm".localizedString, style:UIAlertAction.Style.default, handler:{ action in
                self.leaveGroup()
            }))
            settingsActionSheet.addAction(UIAlertAction(title:"Cancel".localizedString, style:UIAlertAction.Style.cancel, handler:nil))
            
            present(settingsActionSheet, animated:true, completion:nil)
        }
        
    }

    func deleteGroup() {
        self.showLoading()
        self.viewmodel.deleteGroup(withGroupId: groupId) { error, data in
            self.hideLoading()
            if let error = error {
                DispatchQueue.main.async {
                    self.view.makeToast(error)
                }
                return
            }
            
            guard let _ = data else {
                return
            }
            
            DispatchQueue.main.async {
                self.view.makeToast("Your group has been successfully deleted".localizedString)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                Router().toHome()
            }
        }
    }
    
    func leaveGroup() {
        let actionDate = formatterDate.string(from: Date())
        let actionTime = formatterTime.string(from: Date())
        
        
        self.showLoading()
        self.viewmodel.leaveGroupChat(ByID: groupId, registrationDateTime: "\(actionDate) \(actionTime)") { error, data in
            self.hideLoading()
            if let error = error {
                DispatchQueue.main.async {
                    self.view.makeToast(error)
                }
                return
            }
            
            guard let _ = data else {
                return
            }
            
            DispatchQueue.main.async {
                self.view.makeToast("You have exit the group successfully".localizedString)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                Router().toHome()
            }
        }
    }

}

extension GroupVC : UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    //MARK:- Take Picture
    func openCamera(){
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera;
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    //MARK:- Open Library
    func openLibrary(){
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image = info[.originalImage] as! UIImage
        picker.dismiss(animated:true, completion: {
            let size = CGSize(width: screenW, height: screenW)
            let img = image.crop(to: size)
            self.groupImg.image = img
        })
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated:true, completion: nil)
    }
}

extension GroupVC : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewmodel.groupMembers.value?.chatGroupSubscribers?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? SelectedFriendTableViewCell else {return UITableViewCell()}
        let model = viewmodel.groupMembers.value?.chatGroupSubscribers?[indexPath.row]
        cell.titleLbl.text = model?.userName
        cell.profileImg.sd_setImage(with: URL(string: model?.userImage ?? "" ), placeholderImage: UIImage(named: "placeholder"))
        
        if indexPath.row == ((viewmodel.groupMembers.value?.chatGroupSubscribers?.count ?? 0) - 1 ) {
            cell.bottomView.isHidden = true
        }
        
        cell.selectedImg.isHidden = true
        return cell
    }
    
    
}

extension GroupVC : UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let model = viewmodel.groupMembers.value?.chatGroupSubscribers?[indexPath.row]
        
        let actionDate = formatterDate.string(from: Date())
        let actionTime = formatterTime.string(from: Date())
        
        if isGroupAdmin == true {
            let deleteAction = UITableViewRowAction(style: .default, title: "Delete".localizedString) { action, indexPath in
                print("deleteAction")
                
                if UIDevice.current.userInterfaceIdiom == .pad {
                    let settingsActionSheet: UIAlertController = UIAlertController(title:"Are you sure you want to delete this user from your group?".localizedString, message:nil, preferredStyle: .alert)
                    
                    settingsActionSheet.addAction(UIAlertAction(title:"Confirm".localizedString, style:UIAlertAction.Style.default, handler:{ action in
                        self.showLoading()
                        self.viewmodel.deleteUsersGroup(withGroupId: self.groupId, AndListOfUserIDs: [model?.userID ?? ""], AndRegistrationDateTime:  "\(actionDate) \(actionTime)") { error, data in
                            self.hideLoading()
                            if let error = error {
                                DispatchQueue.main.async {
                                    self.view.makeToast(error)
                                }
                                return
                            }
                            
                            guard let _ = data else {
                                return
                            }
                            
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                    }))
                    settingsActionSheet.addAction(UIAlertAction(title:"Cancel".localizedString, style:UIAlertAction.Style.cancel, handler:nil))
                    
                    self.present(settingsActionSheet, animated:true, completion:nil)
                }
                else {
                    let settingsActionSheet: UIAlertController = UIAlertController(title:"Are you sure you want to delete this user from your group?".localizedString, message:nil, preferredStyle:UIAlertController.Style.actionSheet)
                    
                    settingsActionSheet.addAction(UIAlertAction(title:"Confirm".localizedString, style:UIAlertAction.Style.default, handler:{ action in
                        self.showLoading()
                        self.viewmodel.deleteUsersGroup(withGroupId: self.groupId, AndListOfUserIDs: [model?.userID ?? ""], AndRegistrationDateTime:  "\(actionDate) \(actionTime)") { error, data in
                            self.hideLoading()
                            if let error = error {
                                DispatchQueue.main.async {
                                    self.view.makeToast(error)
                                }
                                return
                            }
                            
                            guard let _ = data else {
                                return
                            }
                            
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                    }))
                    settingsActionSheet.addAction(UIAlertAction(title:"Cancel".localizedString, style:UIAlertAction.Style.cancel, handler:nil))
                    
                    self.present(settingsActionSheet, animated:true, completion:nil)
                }
            }
            
            if model?.isAdminGroup == false {
                return [deleteAction]
            }else {
                return []
            }
            
        }else {
            return []
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

extension GroupVC : UISearchBarDelegate {
    @objc func updateSearchResult() {
        guard let text = searchbar.text else {return}
        print(text)
        
//        getAllFriends(pageNumber: 1, search: text)
    }
}
