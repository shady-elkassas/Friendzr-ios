//
//  ReportVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 03/01/2022.
//

import UIKit

class ReportVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let titleCellID = "ReportTitleTableViewCell"
    let problemCellID = "ProblemTableViewCell"
    let confirmBtnCellID = "ConfirmReportButtonTableViewCell"
    let detailsCellID = "WriteProblemTableViewCell"
    var selectedVC = ""
    var viewmodel:ReportViewModel = ReportViewModel()
    var internetConnect:Bool = false
    
    
    var id:String = ""
    var problemID:String = ""
    var message:String = ""
    var isEvent:Bool = false
    var chatimg:String = ""
    var chatname:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Report"
        setupView()
        
        DispatchQueue.main.async {
            self.updateUserInterface()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.hideLoading()
        CancelRequest.currentTask = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if selectedVC == "Friend" {
            initCloseBarButton()
        }else {
            initBackChatButton()
        }
        
        setupNavBar()
    }
    
    func setupView() {
        tableView.register(UINib(nibName: titleCellID, bundle: nil), forCellReuseIdentifier: titleCellID)
        tableView.register(UINib(nibName: confirmBtnCellID, bundle: nil), forCellReuseIdentifier: confirmBtnCellID)
        tableView.register(UINib(nibName: detailsCellID, bundle: nil), forCellReuseIdentifier: detailsCellID)
        tableView.register(UINib(nibName: problemCellID, bundle: nil), forCellReuseIdentifier: problemCellID)
    }
    
    
    func updateUserInterface() {
        appDelegate.networkReachability()
        
        switch Network.reachability.status {
        case .unreachable:
            internetConnect = false
            DispatchQueue.main.async {
                self.view.makeToast("No avaliable newtwok ,Please try again!".localizedString)
            }
        case .wwan:
            internetConnect = true
            getAllProblems()
        case .wifi:
            internetConnect = true
            getAllProblems()
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
            DispatchQueue.main.async {
                self.view.makeToast("No avaliable newtwok ,Please try again!".localizedString)
            }
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
    
    
    func getAllProblems() {
        self.showLoading()
        viewmodel.getAllProblems()
        viewmodel.model.bind { [unowned self] value in
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
                print(error)
            }
        }
    }
}

extension ReportVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        }
        else if section == 1 {
            return viewmodel.model.value?.count ?? 0
        }
        else{
            return 1
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: titleCellID, for: indexPath) as? ReportTitleTableViewCell else {return UITableViewCell()}
            if indexPath.row == 0 {
                cell.titleLbl.text = "Please select a problem"
                cell.titleLbl.font = UIFont.init(name: "Montserrat-Bold", size: 16)
                cell.titleLbl.textColor = .black
            }else {
                cell.titleLbl.text = "if someone is in immediate danger, get help before reporting to Friendzr. Don't wait."
                cell.titleLbl.font = UIFont.init(name: "Montserrat-Medium", size: 12)
                cell.titleLbl.textColor = .gray
            }
            
            cell.bottomView.isHidden = true
            //            cell.checkMarkImg.isHidden = true
            return cell
        }
        else if indexPath.section == 1 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: problemCellID, for: indexPath) as? ProblemTableViewCell else {return UITableViewCell()}
            let model = viewmodel.model.value?[indexPath.row]
            cell.titleLbl.text = model?.name ?? ""
            cell.titleLbl.font = UIFont.init(name: "Montserrat-Medium", size: 12)
            cell.bottomView.isHidden = false
            return cell
        }
        else if indexPath.section == 2 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: detailsCellID, for: indexPath) as? WriteProblemTableViewCell else {return UITableViewCell()}
            self.message = cell.textView.text
            return cell
        }
        else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: confirmBtnCellID, for: indexPath) as? ConfirmReportButtonTableViewCell else {return UITableViewCell()}
            cell.HandleConfirmBtn = {
                self.updateNetworkForBtns()
                
                if self.internetConnect {
                    self.viewmodel.sendReport(withID: self.id, isEvent: self.isEvent, message: self.message, reportReasonID: self.problemID) { error, data in
                        if let error = error {
                            DispatchQueue.main.async {
                                self.view.makeToast(error)
                            }
                            return
                        }
                        
                        guard let message = data else {return}
                        
                        DispatchQueue.main.async {
                            self.view.makeToast(message)
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            if self.isEvent == true {
                                Router().toHome()
                            }else {
                                Router().toFeed()
                            }
                        }
                    }
                }
            }
            return cell
        }
    }
}

extension ReportVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return UITableView.automaticDimension
        }
        else if indexPath.section == 1 {
            return 50
        }
        else if indexPath.section == 2 {
            return 150
        }
        else {
            return 60
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            let model = viewmodel.model.value?[indexPath.row]
            print("\(indexPath.row),\(model?.name ?? "")")
            self.problemID = model?.id ?? ""
        }else {
            return
        }
    }
}

extension ReportVC {
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
        button.addTarget(self, action:  #selector(backToInbox), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.leftBarButtonItem = barButton
    }
    
    @objc func backToInbox() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            Router().toConversationVC(isEvent: self.isEvent, eventChatID: self.id, leavevent: 0, chatuserID: self.id, isFriend: true, titleChatImage: self.chatimg, titleChatName: self.chatname)
        })
    }
}
