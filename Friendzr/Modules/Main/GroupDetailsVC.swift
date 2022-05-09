//
//  GroupDetailsVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 28/02/2022.
//

import UIKit
import QCropper
import SDWebImage

class GroupDetailsVC: UIViewController,UIPopoverPresentationControllerDelegate {
    
    //MARK: - Outlets
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
    @IBOutlet weak var editOrShowImageBtn: UIButton!
    
    //MARK: - Properties
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
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()
    
    let cellID = "AttendeesTableViewCell"
    let emptyCellID = "EmptyViewTableViewCell"
    
    var groupId:String = ""
    var isGroupAdmin:Bool = false
    
    var attachedImg:Bool = false
    let imagePicker = UIImagePickerController()
    var selectedVC:Bool = false
    var viewmodel:GroupViewModel = GroupViewModel()
    var selectedIDs = [String]()
    var selectedNames = [String]()
    var selectedFrineds = [UserConversationModel]()
    var groupImgStr:String = ""

    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        
        getGroupDetails(search: "")
        setupSearchBar()
        
        if selectedVC {
            initCloseBarButton()
        }else {
            initBackButton()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateGroupDetails), name: Notification.Name("updateGroupDetails"), object: nil)
        
        editOrShowImageBtn.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if selectedVC {
            Defaults.availableVC = "PresentGroupDetailsVC"
        }else {
            Defaults.availableVC = "GroupDetailsVC"
        }
        print("availableVC >> \(Defaults.availableVC)")
        
        title = "Group Details"
        setupNavBar()
        hideNavigationBar(NavigationBar: false, BackButton: false)
    }
    
    

    //MARK: - APIs
    func getGroupDetails(search:String) {
        self.superView.showLoader()
        viewmodel.getGroupDetails(id: groupId, search: search)
        viewmodel.groupMembers.bind { [unowned self] value in
            DispatchQueue.main.async {
                self.tableView.delegate = self
                self.tableView.dataSource = self
                self.tableView.reloadData()
                
                self.tableViewHeight.constant = CGFloat((value.chatGroupSubscribers?.count ?? 0) * 75)
                
                DispatchQueue.main.async {
                    self.groupImg.sd_setImage(with: URL(string: value.image ?? "" ), placeholderImage: UIImage(named: "placeHolderApp"))
                    self.groupImgStr = value.image ?? ""
                    
                    self.nameTxt.text = value.name
                }
                
                DispatchQueue.main.async {
                    self.selectedIDs.removeAll()
                    self.selectedNames.removeAll()
                    self.selectedFrineds.removeAll()
                    for item in value.chatGroupSubscribers  ?? [] {
                        self.selectedIDs.append(item.userId)
                        self.selectedNames.append(item.userName )
                        self.selectedFrineds.append(item)
                    }
                    
                    self.selectedNames.remove(at: 0)
                    self.selectedIDs.remove(at: 0)
                    self.selectedFrineds.remove(at: 0)
                }
                
                self.superView.hideLoader()
            }
        }
        
        // Set View Model Event Listener
        viewmodel.errorMsg.bind { [unowned self]error in
            DispatchQueue.main.async {
                //                self.view.makeToast(error)
            }
        }
    }
    
    //MARK: - Helpers
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
    
    @objc func updateGroupDetails() {
        getGroupDetails(search: "")
    }

    //MARK: - Actions
    @IBAction func editImgBtn(_ sender: Any) {
        let settingsActionSheet: UIAlertController = UIAlertController(title:nil, message:nil, preferredStyle:UIAlertController.Style.actionSheet)
        
        let cameraBtn = UIAlertAction(title: "Camera", style: .default) {_ in
            self.openCamera()
        }
        let libraryBtn = UIAlertAction(title: "Photo Library", style: .default) {_ in
            self.openLibrary()
        }
        
        let cancelBtn = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        cameraBtn.setValue(UIColor.FriendzrColors.primary, forKey: "titleTextColor")
        libraryBtn.setValue(UIColor.FriendzrColors.primary, forKey: "titleTextColor")
        cancelBtn.setValue(UIColor.red, forKey: "titleTextColor")
        
        settingsActionSheet.addAction(cameraBtn)
        settingsActionSheet.addAction(libraryBtn)
        settingsActionSheet.addAction(cancelBtn)
        
        present(settingsActionSheet, animated: true, completion: nil)
        
    }
    
    @IBAction func addUsersBtn(_ sender: Any) {
        if let controller = UIViewController.viewController(withStoryboard: .Main, AndContollerID: "AddNewUsersForMyGroupNC") as? UINavigationController, let vc = controller.viewControllers.first as? AddNewUsersForMyGroupVC {
            vc.groupId = groupId
            vc.selectedIDs = selectedIDs
            vc.selectedNames = selectedNames
            vc.selectedFriends = selectedFrineds
            self.present(controller, animated: true)
        }
    }
    
    @IBAction func editOrShowImageBtn(_ sender: Any) {
        guard let popupVC = UIViewController.viewController(withStoryboard: .Main, AndContollerID: "ShowImageVC") as? ShowImageVC else {return}
        popupVC.modalPresentationStyle = .overCurrentContext
        popupVC.modalTransitionStyle = .crossDissolve
        let pVC = popupVC.popoverPresentationController
        pVC?.permittedArrowDirections = .any
        pVC?.delegate = self
        pVC?.sourceRect = CGRect(x: 100, y: 100, width: 1, height: 1)
        popupVC.imgURL = groupImgStr
        present(popupVC, animated: true, completion: nil)
    }
}

extension GroupDetailsVC {
    //MARK: - Edit And Option Button
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
    
    //MARK: - Save And Option Button
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
        self.editOrShowImageBtn.isHidden = true
    }
    
    @objc func handleSaveBtn() {
        self.viewmodel.updateGroup(ByID: self.groupId, AndName: nameTxt.text!, attachedImg: self.attachedImg, AndImage: groupImg.image ?? UIImage()) { error, data in
            
            if let error = error {
                DispatchQueue.main.async {
                    self.view.makeToast(error)
                }
                return
            }
            
            guard let _ = data else {return}
            
            DispatchQueue.main.async {
                self.nameTxt.isUserInteractionEnabled = false
                self.cameraBtn.isHidden = true
                self.initEditAndOptionButton()
                self.editOrShowImageBtn.isHidden = false
            }
        }
    }
    
    @objc func handleAdminOptionBtn() {
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
    
    @objc func handleUserOptionBtn() {
        let actionSheet  = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Leave".localizedString, style: .default, handler: { action in
            self.handleLeaveGroup()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel".localizedString, style: .cancel, handler: {  _ in
        }))
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    func handleDeleteGroup() {
        let settingsActionSheet: UIAlertController = UIAlertController(title:"Are you sure you want to delete this group?".localizedString, message:nil, preferredStyle:UIAlertController.Style.actionSheet)
        
        settingsActionSheet.addAction(UIAlertAction(title:"Confirm".localizedString, style:UIAlertAction.Style.default, handler:{ action in
            self.deleteGroup()
        }))
        settingsActionSheet.addAction(UIAlertAction(title:"Cancel".localizedString, style:UIAlertAction.Style.cancel, handler:nil))
        
        present(settingsActionSheet, animated:true, completion:nil)
    }
    
    func handleLeaveGroup() {
        let settingsActionSheet: UIAlertController = UIAlertController(title:"Are you sure you want to leave from this group?".localizedString, message:nil, preferredStyle:UIAlertController.Style.actionSheet)
        
        settingsActionSheet.addAction(UIAlertAction(title:"Confirm".localizedString, style:UIAlertAction.Style.default, handler:{ action in
            self.leaveGroup()
        }))
        settingsActionSheet.addAction(UIAlertAction(title:"Cancel".localizedString, style:UIAlertAction.Style.cancel, handler:nil))
        
        present(settingsActionSheet, animated:true, completion:nil)
    }
    
    func deleteGroup() {
        self.viewmodel.deleteGroup(withGroupId: groupId) { error, data in
            if let error = error {
                DispatchQueue.main.async {
                    self.view.makeToast(error)
                }
                return
            }
            
            guard let _ = data else {
                return
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                Router().toHome()
            }
        }
    }
    
    func leaveGroup() {
        let actionDate = formatterDate.string(from: Date())
        let actionTime = formatterTime.string(from: Date())
        
        
        self.viewmodel.leaveGroupChat(ByID: groupId, registrationDateTime: "\(actionDate) \(actionTime)") { error, data in
            if let error = error {
                DispatchQueue.main.async {
                    self.view.makeToast(error)
                }
                return
            }
            
            guard let _ = data else {
                return
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                Router().toHome()
            }
        }
    }
    
}

//MARK: -UITableViewDataSource
extension GroupDetailsVC : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewmodel.groupMembers.value?.chatGroupSubscribers?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? AttendeesTableViewCell else {return UITableViewCell()}
        let model = viewmodel.groupMembers.value?.chatGroupSubscribers?[indexPath.row]
        
        if model?.isAdminGroup == true {
            cell.dropDownBtn.isHidden = true
            cell.adminLbl.isHidden = false
            cell.btnWidth.constant = 0
        }else {
            if self.isGroupAdmin {
                cell.dropDownBtn.isHidden = false
                cell.adminLbl.isHidden = true
                cell.btnWidth.constant = 20
            }else {
                cell.dropDownBtn.isHidden = true
                cell.adminLbl.isHidden = true
                cell.btnWidth.constant = 20
                
            }
        }
        
        
        cell.friendNameLbl.text = model?.userName
        cell.friendImg.sd_imageIndicator = SDWebImageActivityIndicator.gray
        cell.friendImg.sd_setImage(with: URL(string: model?.image ?? ""), placeholderImage: UIImage(named: "placeHolderApp"))
        
        cell.joinDateLbl.isHidden = true
        
        cell.HandleDropDownBtn = {
            let settingsActionSheet: UIAlertController = UIAlertController(title:nil, message:nil, preferredStyle:UIAlertController.Style.actionSheet)
            
            settingsActionSheet.addAction(UIAlertAction(title:"Delete".localizedString.localizedString, style:UIAlertAction.Style.default, handler:{ action in
                self.showAlertView(messageString: "delete".localizedString, userID: model?.userId ?? "", Stutus: 1)
            }))
            settingsActionSheet.addAction(UIAlertAction(title:"Cancel".localizedString, style:UIAlertAction.Style.cancel, handler:nil))
            
            self.present(settingsActionSheet, animated:true, completion:nil)
        }
        return cell
    }
    
    
}
//MARK: -UITableViewDelegate
extension GroupDetailsVC : UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

extension GroupDetailsVC : UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    //MARK: - Take Picture
    func openCamera(){
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera;
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    //MARK: - Open Library
    func openLibrary(){
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image = info[.originalImage] as! UIImage
        let originImg = image.fixOrientation()

         let cropper = CropperViewController(originalImage: originImg, isCircular: true)
        cropper.delegate = self
        self.navigationController?.pushViewController(cropper, animated: true)
        
        picker.dismiss(animated: true) {
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.attachedImg = false
        self.tabBarController?.tabBar.isHidden = false
        picker.dismiss(animated:true, completion: nil)
    }
}


extension GroupDetailsVC : UISearchBarDelegate {
    @objc func updateSearchResult() {
        guard let text = searchbar.text else {return}
        print(text)
//        self.getGroupDetails(search: text)
    }
}

extension GroupDetailsVC {
    //Show Alert View
    func showAlertView(messageString:String,userID:String,Stutus :Int) {
        self.alertView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        self.alertView?.titleLbl.text = "Confirm?".localizedString
        self.alertView?.detailsLbl.text = "Are you sure you want to ".localizedString + "\(messageString)" + " this account?".localizedString
        
        let ActionDate = self.formatterDate.string(from: Date())
        let Actiontime = self.formatterTime.string(from: Date())
        
        self.alertView?.HandleConfirmBtn = {
            self.viewmodel.deleteUsersGroup(withGroupId: self.groupId, AndListOfUserIDs: [userID], AndRegistrationDateTime: "\(ActionDate) \(Actiontime)") { error, data in
                if let error = error {
                    DispatchQueue.main.async {
                        print(error)
                    }
                    return
                }
                
                guard let _ = data else {
                    return
                }
                
                DispatchQueue.main.async {
                    self.getGroupDetails(search: self.searchbar.text ?? "")
                }
            }
            
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
}

//MARK: - CropperViewControllerDelegate
extension GroupDetailsVC: CropperViewControllerDelegate {
    
    func aspectRatioPickerDidSelectedAspectRatio(_ aspectRatio: AspectRatio) {
        print("\(String(describing: aspectRatio.dictionary))")
    }
    
    func cropperDidConfirm(_ cropper: CropperViewController, state: CropperState?) {
        cropper.onPopup()
        if let state = state,
           let image = cropper.originalImage.cropped(withCropperState: state) {
            groupImg.image = image
            self.attachedImg = true
            print(cropper.isCurrentlyInInitialState)
            print(image)
        }
    }
    
    func cropperDidCancel(_ cropper: CropperViewController) {
        cropper.onPopup()
    }
}
