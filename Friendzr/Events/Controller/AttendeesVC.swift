//
//  AttendeesVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 07/09/2021.
//

import UIKit

class AttendeesVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchContainerView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    let cellID = "AttendeesTableViewCell"
    var viewmodel:AttendeesViewModel = AttendeesViewModel()
    var eventID:String = ""
    
    lazy var alertView = Bundle.main.loadNibNamed("BlockAlertView", owner: self, options: nil)?.first as? BlockAlertView
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchBar()
        tableView.register(UINib(nibName: cellID, bundle: nil), forCellReuseIdentifier: cellID)
        initBackButton(btnColor: .black)
        title = "Attendees"
        getAllAttendees()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        alertView?.addGestureRecognizer(tap)
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
        let textHolder  = "Search Messages".localizedString
        let font = UIFont(name: "Montserrat-Medium", size: 14) ?? UIFont.systemFont(ofSize: 14)
        placeHolder = NSMutableAttributedString(string:textHolder, attributes: [NSAttributedString.Key.font: font])
        searchBar.searchTextField.attributedPlaceholder = placeHolder
        searchBar.searchTextField.addTarget(self, action: #selector(updateSearchResult), for: .editingChanged)
    }
    
    func getAllAttendees() {
        self.showLoading()
        viewmodel.getEventAttendees(ByEventID: eventID)
        viewmodel.attendees.bind { [unowned self] value in
            DispatchQueue.main.async {
                self.hideLoading()
                tableView.delegate = self
                tableView.dataSource = self
                tableView.reloadData()
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
    
    func showAlertView(messageString:String,eventID:String,UserattendId:String,Stutus :Int) {
        self.alertView?.frame = CGRect(x: 0, y: -100, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        self.alertView?.titleLbl.text = "Confirm?".localizedString
        self.alertView?.detailsLbl.text = "Are you sure you want to \(messageString) this account?".localizedString
        
        self.alertView?.HandleConfirmBtn = {
            // handling code
            
            self.showLoading()
            self.viewmodel.editAttendees(ByUserAttendId: UserattendId, AndEventid: eventID, AndStutus: Stutus) { [self] error, data in
                self.hideLoading()
                if let error = error {
                    self.showAlert(withMessage: error)
                    return
                }
                
                guard let _ = data else {return}
                self.showAlert(withMessage: "Successfully \(messageString)")
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
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
    
}

//MARK: - SearchBar Delegate
extension AttendeesVC: UISearchBarDelegate{
    @objc func updateSearchResult() {
        guard let text = searchBar.text else {return}
        print(text)
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
        return viewmodel.attendees.value?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? AttendeesTableViewCell else {return UITableViewCell()}
        let model = viewmodel.attendees.value?[indexPath.row]
        cell.friendNameLbl.text = model?.userName
        cell.friendImg.sd_setImage(with: URL(string: model?.image ?? ""), placeholderImage: UIImage(named: "photo_img"))
        //        cell.joinDateLbl.text = model.date
        cell.HandleDropDownBtn = {
            if UIDevice.current.userInterfaceIdiom == .pad {
                let settingsActionSheet: UIAlertController = UIAlertController(title:nil, message:nil, preferredStyle: .alert)
                
                settingsActionSheet.addAction(UIAlertAction(title:"Delete".localizedString, style:UIAlertAction.Style.default, handler:{ action in
                    self.showAlertView(messageString: "delete", eventID: self.eventID, UserattendId: model?.id ?? "", Stutus: 1)
                }))
                settingsActionSheet.addAction(UIAlertAction(title:"Block".localizedString, style:UIAlertAction.Style.default, handler:{ action in
                    self.showAlertView(messageString: "block", eventID: self.eventID, UserattendId: model?.id ?? "", Stutus: 2)
                }))
                settingsActionSheet.addAction(UIAlertAction(title:"Cancel".localizedString, style:UIAlertAction.Style.cancel, handler:nil))
                
                self.present(settingsActionSheet, animated:true, completion:nil)
            }else {
                let settingsActionSheet: UIAlertController = UIAlertController(title:nil, message:nil, preferredStyle:UIAlertController.Style.actionSheet)
                
                settingsActionSheet.addAction(UIAlertAction(title:"Delete".localizedString, style:UIAlertAction.Style.default, handler:{ action in
                    self.showAlertView(messageString: "delete", eventID: self.eventID, UserattendId: model?.id ?? "", Stutus: 1)
                }))
                settingsActionSheet.addAction(UIAlertAction(title:"Block".localizedString, style:UIAlertAction.Style.default, handler:{ action in
                    self.showAlertView(messageString: "block", eventID: self.eventID, UserattendId: model?.id ?? "", Stutus: 2)
                }))
                settingsActionSheet.addAction(UIAlertAction(title:"Cancel".localizedString, style:UIAlertAction.Style.cancel, handler:nil))
                
                self.present(settingsActionSheet, animated:true, completion:nil)
            }
        }
        return cell
    }
}

extension AttendeesVC:UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}
