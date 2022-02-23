//
//  EventDetailsAttendeesTableViewCell.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 09/02/2022.
//

import UIKit

class EventDetailsAttendeesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
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
    
    let attendeesCellID = "AttendeesTableViewCell"
    private var footerCellID = "SeeMoreTableViewCell"

    var HandleDropDownBtn: (() -> ())?

    var attendeesVM:AttendeesViewModel = AttendeesViewModel()
    var eventModel:Event? = Event()
    var parentvc = EventDetailsViewController()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        containerView.cornerRadiusView(radius: 12)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
        
        tableView.register(UINib(nibName: attendeesCellID, bundle: nil), forCellReuseIdentifier: attendeesCellID)
        tableView.register(UINib(nibName: footerCellID, bundle: nil), forHeaderFooterViewReuseIdentifier: footerCellID)
     
        if eventModel?.attendees?.count == 0 {
            self.tableViewHeight.constant = 0
        }else if eventModel?.attendees?.count == 1 {
            self.tableViewHeight.constant = CGFloat(120)
        }else if eventModel?.attendees?.count == 2 {
            self.tableViewHeight.constant = CGFloat(220)
        }else {
            self.tableViewHeight.constant = CGFloat(275)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension EventDetailsAttendeesTableViewCell: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventModel?.attendees?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: attendeesCellID, for: indexPath) as? AttendeesTableViewCell else {return UITableViewCell()}
        let model = eventModel?.attendees?[indexPath.row]

        cell.joinDateLbl.isHidden = true
        cell.friendNameLbl.text = model?.userName
        cell.friendImg.sd_setImage(with: URL(string: model?.image ?? "" ), placeholderImage: UIImage(named: "placeHolderApp"))
        
        if indexPath.row == (eventModel?.attendees?.count ?? 0) - 1 {
            cell.underView.isHidden = true
        }else {
            cell.underView.isHidden = false
        }

        if model?.myEventO == true {
            cell.adminLbl.isHidden = false
            cell.dropDownBtn.isHidden = true
            cell.btnWidth.constant = 0
        }else {
            cell.adminLbl.isHidden = true
            cell.dropDownBtn.isHidden = false
            cell.btnWidth.constant = 20
        }

        cell.HandleDropDownBtn = {
            if UIDevice.current.userInterfaceIdiom == .pad {
                let settingsActionSheet: UIAlertController = UIAlertController(title:nil, message:nil, preferredStyle: .alert)
                
                settingsActionSheet.addAction(UIAlertAction(title:"Remove".localizedString, style:UIAlertAction.Style.default, handler:{ action in
                    self.showAlertView(messageString: "delete", eventID: self.eventModel?.id ?? "", UserattendId: model?.userId ?? "", Stutus: 1)
                }))
                settingsActionSheet.addAction(UIAlertAction(title:"Block From Event".localizedString.localizedString, style:UIAlertAction.Style.default, handler:{ action in
                    self.showAlertView(messageString: "block".localizedString, eventID: self.eventModel?.id ?? "", UserattendId: model?.userId ?? "", Stutus: 2)
                }))
                settingsActionSheet.addAction(UIAlertAction(title:"Cancel".localizedString.localizedString, style:UIAlertAction.Style.cancel, handler:nil))
                
                self.parentvc.present(settingsActionSheet, animated:true, completion:nil)
            }else {
                let settingsActionSheet: UIAlertController = UIAlertController(title:nil, message:nil, preferredStyle:UIAlertController.Style.actionSheet)
                
                settingsActionSheet.addAction(UIAlertAction(title:"Remove".localizedString.localizedString, style:UIAlertAction.Style.default, handler:{ action in
                    self.showAlertView(messageString: "delete".localizedString, eventID: self.eventModel?.id ?? "", UserattendId: model?.userId ?? "", Stutus: 1)
                }))
                settingsActionSheet.addAction(UIAlertAction(title:"Block From Event".localizedString.localizedString, style:UIAlertAction.Style.default, handler:{ action in
                    self.showAlertView(messageString: "block".localizedString, eventID: self.eventModel?.id ?? "", UserattendId: model?.userId ?? "", Stutus: 2)
                }))
                settingsActionSheet.addAction(UIAlertAction(title:"Cancel".localizedString, style:UIAlertAction.Style.cancel, handler:nil))
                
                self.parentvc.present(settingsActionSheet, animated:true, completion:nil)
            }
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {

        guard let footerView = Bundle.main.loadNibNamed(footerCellID, owner: self, options: nil)?.first as? SeeMoreTableViewCell else { return UIView()}

        footerView.HandleSeeMoreBtn = {
            guard let vc = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "AttendeesVC") as? AttendeesVC else {return}
            vc.eventID = self.eventModel?.id ?? ""
            self.parentvc.navigationController?.pushViewController(vc, animated: true)
        }
        if (eventModel?.attendees?.count ?? 0) == 1 {
            return nil
        }else {
            return footerView
        }
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (eventModel?.attendees?.count ?? 0) == 1 {
            return 0
        }else {
            return 40
        }
    }
}

extension EventDetailsAttendeesTableViewCell: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = eventModel?.attendees?[indexPath.row]

        if model?.myEventO == true {
            guard let vc = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "MyProfileViewController") as? MyProfileViewController else {return}
            self.parentvc.navigationController?.pushViewController(vc, animated: true)
        }else {
            guard let vc = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "FriendProfileViewController") as? FriendProfileViewController else {return}
            vc.userID = model?.userId ?? ""
            self.parentvc.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension EventDetailsAttendeesTableViewCell {
    func showAlertView(messageString:String,eventID:String,UserattendId:String,Stutus :Int) {
        self.alertView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        self.alertView?.titleLbl.text = "Confirm?".localizedString
        self.alertView?.detailsLbl.text = "Are you sure you want to ".localizedString + "\(messageString)" + " this account?".localizedString
        
        let ActionDate = self.formatterDate.string(from: Date())
        let Actiontime = self.formatterTime.string(from: Date())
        
        self.alertView?.HandleConfirmBtn = {
            // handling code
            self.attendeesVM.editAttendees(ByUserAttendId: UserattendId, AndEventid: eventID, AndStutus: Stutus,Actiontime: Actiontime ,ActionDate: ActionDate) { [self] error, data in
                if let error = error {
                    DispatchQueue.main.async {
                        self.parentvc.view.makeToast(error)
                    }
                    return
                }
                
                guard let _ = data else {return}
                
                
                DispatchQueue.main.async {
                    self.parentvc.getEventDetails()
//                    NotificationCenter.default.post(name: Notification.Name("handleEventDetails"), object: nil, userInfo: nil)
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
        
        self.parentvc.view.addSubview((self.alertView)!)
    }
}
