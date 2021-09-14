//
//  FriendProfileVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 15/08/2021.
//

import UIKit

class FriendProfileVC: UIViewController {
    
    //MARK:- Outlets
    @IBOutlet weak var superView: UIView!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var ageLbl: UILabel!
    @IBOutlet weak var genderLbl: UILabel!
    @IBOutlet weak var svBtns: UIStackView!
    @IBOutlet weak var blockBtn: UIButton!
    @IBOutlet weak var unfriendBtn: UIButton!
    @IBOutlet weak var sendRequestBtn: UIButton!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var aboutFriendLbl: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var cancelRequestBtn: UIButton!
    @IBOutlet weak var respondBtn: UIButton!
    @IBOutlet weak var unblockBtn: UIButton!
    
    
    //MARK: - Properties
    lazy var alertView = Bundle.main.loadNibNamed("BlockAlertView", owner: self, options: nil)?.first as? BlockAlertView
    var viewmodel:FriendViewModel = FriendViewModel()
    var userID:String = ""
    
    var cellID = "TagLabelCollectionViewCell"
    var strWidth:CGFloat = 0
    var strheight:CGFloat = 0
    
    var requestFriendVM:RequestFriendStatusViewModel = RequestFriendStatusViewModel()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        alertView?.addGestureRecognizer(tap)
        
        getFriendProfileInformation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initBackButton(btnColor: .white)
        clearNavigationBar()
    }
    
    //MARK:- APIs
    func getFriendProfileInformation() {
        viewmodel.getFriendDetails(ById: userID)
        viewmodel.model.bind { [unowned self]value in
            DispatchQueue.main.async {
                collectionView.dataSource = self
                collectionView.delegate = self
                collectionView.reloadData()
                
                setupData()
                
                let tagsCount = value.listoftagsmodel?.count
                collectionViewHeight.constant = CGFloat(((tagsCount! / 2) * 30))
            }
        }
        
        // Set View Model Event Listener
        viewmodel.error.bind { [unowned self]error in
            DispatchQueue.main.async {
                print(error)
            }
        }
    }
    
    //set data for user
    func setupData() {
        let model = viewmodel.model.value
        aboutFriendLbl.text = model?.bio
        userNameLbl.text = model?.userName
        nameLbl.text = model?.userName
        ageLbl.text = "\(model?.age ?? 0)"
        genderLbl.text = model?.gender
        profileImg.sd_setImage(with: URL(string: model?.userImage ?? "" ), placeholderImage: UIImage(named: "avatar"))
        
        switch model?.key {
        case 0:
            //Status = normal case
            respondBtn.isHidden = true
            cancelRequestBtn.isHidden = true
            sendRequestBtn.isHidden = false
            svBtns.isHidden = true
            unblockBtn.isHidden = true
            break
        case 1:
            //Status = I have added a friend request
            respondBtn.isHidden = true
            cancelRequestBtn.isHidden = false
            sendRequestBtn.isHidden = true
            svBtns.isHidden = true
            unblockBtn.isHidden = true
            break
        case 2:
            //Status = Send me a request to add a friend
            respondBtn.isHidden = false
            cancelRequestBtn.isHidden = true
            sendRequestBtn.isHidden = true
            svBtns.isHidden = true
            unblockBtn.isHidden = true
            break
        case 3:
            //Status = We are friends
            respondBtn.isHidden = true
            cancelRequestBtn.isHidden = true
            sendRequestBtn.isHidden = true
            svBtns.isHidden = false
            unblockBtn.isHidden = true
            break
        case 4:
            //Status = I block user
            respondBtn.isHidden = true
            cancelRequestBtn.isHidden = true
            sendRequestBtn.isHidden = true
            svBtns.isHidden = true
            unblockBtn.isHidden = false
            break
        case 5:
            //Status = user block me
            respondBtn.isHidden = true
            cancelRequestBtn.isHidden = true
            sendRequestBtn.isHidden = true
            svBtns.isHidden = true
            unblockBtn.isHidden = true
            break
        case 6:
            break
        default:
            break
        }
    }
    
    //MARK: - Actions
    @IBAction func sendRequestBtn(_ sender: Any) {
        alertView?.frame = CGRect(x: 0, y: -100, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        alertView?.titleLbl.text = "Confirm?".localizedString
        alertView?.detailsLbl.text = "Are you sure you want to send request?".localizedString
        
        alertView?.HandleConfirmBtn = {
            self.showLoading()
            self.requestFriendVM.requestFriendStatus(withID: self.userID, AndKey: 1) { error, message in
                self.hideLoading()
                if let error = error {
                    self.showAlert(withMessage: error)
                    return
                }
                
                guard let message = message else {return}
                self.showAlert(withMessage: message)
                
                self.respondBtn.isHidden = true
                self.cancelRequestBtn.isHidden = false
                self.sendRequestBtn.isHidden = true
                self.svBtns.isHidden = true
                self.unblockBtn.isHidden = true
            }
            
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
        
        self.view.addSubview((alertView)!)
    }
    
    @IBAction func cancelRequestBtn(_ sender: Any) {
        alertView?.frame = CGRect(x: 0, y: -100, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        alertView?.titleLbl.text = "Confirm?".localizedString
        alertView?.detailsLbl.text = "Are you sure you want to cancel this request?".localizedString
        
        alertView?.HandleConfirmBtn = {
            self.showLoading()
            self.requestFriendVM.requestFriendStatus(withID: self.userID, AndKey: 6) { error, message in
                self.hideLoading()
                if let error = error {
                    self.showAlert(withMessage: error)
                    return
                }
                
                guard let message = message else {return}
                self.showAlert(withMessage: message)
                
                self.respondBtn.isHidden = true
                self.cancelRequestBtn.isHidden = true
                self.sendRequestBtn.isHidden = false
                self.svBtns.isHidden = true
                self.unblockBtn.isHidden = true
            }
            
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
        
        self.view.addSubview((alertView)!)
    }
    
    @IBAction func respondBtn(_ sender: Any) {
        alertView?.frame = CGRect(x: 0, y: -100, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        alertView?.titleLbl.text = "Confirm?".localizedString
        alertView?.detailsLbl.text = "Are you sure you want to accept this request?".localizedString
        
        alertView?.HandleConfirmBtn = {
            self.showLoading()
            self.requestFriendVM.requestFriendStatus(withID: self.userID, AndKey: 2) { error, message in
                self.hideLoading()
                if let error = error {
                    self.showAlert(withMessage: error)
                    return
                }
                
                guard let message = message else {return}
                self.showAlert(withMessage: message)
                
                self.respondBtn.isHidden = true
                self.cancelRequestBtn.isHidden = true
                self.sendRequestBtn.isHidden = true
                self.svBtns.isHidden = false
                self.unblockBtn.isHidden = true
            }
            
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
        
        self.view.addSubview((alertView)!)
    }
    
    
    @IBAction func unfriendBtn(_ sender: Any) {
        alertView?.frame = CGRect(x: 0, y: -100, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        alertView?.titleLbl.text = "Confirm?".localizedString
        alertView?.detailsLbl.text = "Are you sure you want to unfriend this account?".localizedString
        
        alertView?.HandleConfirmBtn = {
            self.sendRequestBtn.isHidden = false
            self.svBtns.isHidden = true
            
            self.showLoading()
            self.requestFriendVM.requestFriendStatus(withID: self.userID, AndKey: 5) { error, message in
                self.hideLoading()
                if let error = error {
                    self.showAlert(withMessage: error)
                    return
                }
                
                guard let message = message else {return}
                self.showAlert(withMessage: message)
                
                self.respondBtn.isHidden = true
                self.cancelRequestBtn.isHidden = true
                self.sendRequestBtn.isHidden = false
                self.svBtns.isHidden = true
                self.unblockBtn.isHidden = true
            }
            
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
        
        self.view.addSubview((alertView)!)
    }
    
    @IBAction func blockBtn(_ sender: Any) {
        alertView?.frame = CGRect(x: 0, y: -100, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        alertView?.titleLbl.text = "Confirm?".localizedString
        alertView?.detailsLbl.text = "Are you sure you want to block this account?".localizedString
        
        alertView?.HandleConfirmBtn = {
            // handling code
            
            self.showLoading()
            self.requestFriendVM.requestFriendStatus(withID: self.userID, AndKey: 3) { error, message in
                self.hideLoading()
                if let error = error {
                    self.showAlert(withMessage: error)
                    return
                }
                
                guard let message = message else {return}
                self.showAlert(withMessage: message)
                
                self.respondBtn.isHidden = true
                self.cancelRequestBtn.isHidden = true
                self.sendRequestBtn.isHidden = true
                self.svBtns.isHidden = true
                self.unblockBtn.isHidden = false
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
        
        self.view.addSubview((alertView)!)
    }
    
    @IBAction func unBlockBtn(_ sender: Any) {
        alertView?.frame = CGRect(x: 0, y: -100, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        alertView?.titleLbl.text = "Confirm?".localizedString
        alertView?.detailsLbl.text = "Are you sure you want to unblock this account?".localizedString
        
        alertView?.HandleConfirmBtn = {
            // handling code
            
            self.showLoading()
            self.requestFriendVM.requestFriendStatus(withID: self.userID, AndKey: 4) { error, message in
                self.hideLoading()
                if let error = error {
                    self.showAlert(withMessage: error)
                    return
                }
                
                guard let message = message else {return}
                self.showAlert(withMessage: message)
                
                self.respondBtn.isHidden = true
                self.cancelRequestBtn.isHidden = true
                self.sendRequestBtn.isHidden = false
                self.svBtns.isHidden = true
                self.unblockBtn.isHidden = true
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
        
        self.view.addSubview((alertView)!)
    }
    
    
    //MARK: - Helpers
    func setup() {
        sendRequestBtn.cornerRadiusView(radius: 15)
        cancelRequestBtn.cornerRadiusView(radius: 15)
        respondBtn.cornerRadiusView(radius: 15)
        unfriendBtn.cornerRadiusView(radius: 15)
        blockBtn.cornerRadiusView(radius: 15)
        blockBtn.setBorder(color: UIColor.white.cgColor, width: 1)
        cancelRequestBtn.setBorder(color: UIColor.FriendzrColors.primary?.cgColor, width: 1)
        collectionView.register(UINib(nibName: cellID, bundle: nil), forCellWithReuseIdentifier: cellID)
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

extension FriendProfileVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewmodel.model.value?.listoftagsmodel?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as? TagLabelCollectionViewCell else {return UICollectionViewCell()}
        let model = viewmodel.model.value?.listoftagsmodel?[indexPath.row]
        cell.titleLbl.text = "#\(model?.tagname ?? "")"
        cell.containerView.cornerRadiusView(radius: 8)
        return cell
    }
}

extension FriendProfileVC: UICollectionViewDelegateFlowLayout,UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let model = viewmodel.model.value?.listoftagsmodel?[indexPath.row]
        strWidth = (model?.tagname.widthOfString(usingFont: UIFont(name: "Montserrat-Regular", size: 12)!))!
        strheight = (model?.tagname.heightOfString(usingFont: UIFont(name: "Montserrat-Regular", size: 12)!))!
        print("strWidth = \(strWidth)","strheight = \(strheight)")
        
        let width = collectionView.bounds.width
        let height = collectionView.bounds.height
        return CGSize(width: width / 4, height: 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        //        if UIDevice.current.userInterfaceIdiom == .pad {
        //            return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        //        }
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}
