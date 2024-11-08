//
//  ReportVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 03/01/2022.
//

import UIKit
import Network

class ReportVC: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var hideView: UIView!
    
    //MARK: - Properties
    let titleCellID = "ReportTitleTableViewCell"
    let problemCellID = "ProblemTableViewCell"
    let confirmBtnCellID = "ConfirmReportButtonTableViewCell"
    let detailsCellID = "WriteProblemTableViewCell"
    var selectedVC = ""
    var viewmodel:ReportViewModel = ReportViewModel()
    
    var id:String = ""
    var problemID:String = ""
    var message:String = ""
    var isEvent:Bool = false
    var chatimg:String = ""
    var chatname:String = ""
    var reportType:Int = 0 //1 group 2 event 3 user
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        DispatchQueue.main.async {
            self.updateUserInterface()
        }
        
        
        title = "Report".localizedString
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.hideLoading()
        CancelRequest.currentTask = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("availableVC >> \(Defaults.availableVC)")
        
        if selectedVC == "Present" || selectedVC == "PresentC" {
            initCloseBarButton()
        }else {
            initBackButton()
        }
        
        hideNavigationBar(NavigationBar: false, BackButton: false)
        setupNavBar()
    }
    
    //MARK: - Helpers
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
            DispatchQueue.main.async {
                NetworkConected.internetConect = false
                DispatchQueue.main.async {
                    self.view.makeToast("Network is unavailable, please try again!".localizedString)
                }
            }
        case .wwan:
            DispatchQueue.main.async {
                NetworkConected.internetConect = true
                self.getAllProblems()
            }
        case .wifi:
            DispatchQueue.main.async {
                NetworkConected.internetConect = true
                self.getAllProblems()
            }
        }
        
        print("Reachability Summary")
        print("Status:", Network.reachability.status)
        print("HostName:", Network.reachability.hostname ?? "nil")
        print("Reachable:", Network.reachability.isReachable)
        print("Wifi:", Network.reachability.isReachableViaWiFi)
    }
    
    //MARK: - APIs
    func getAllProblems() {
        viewmodel.getAllProblems()
        viewmodel.model.bind { [weak self] value in
            DispatchQueue.main.async {
                self?.tableView.delegate = self
                self?.tableView.dataSource = self
                self?.tableView.reloadData()
                
                DispatchQueue.main.async {
                    self?.hideView.isHidden = true
                }
            }
        }
        
        // Set View Model Event Listener
        viewmodel.error.bind { [weak self]error in
            DispatchQueue.main.async {
                print(error)
            }
        }
    }
}

//MARK: - UITableViewDataSource
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
                cell.titleLbl.text = "Please select a problem".localizedString
                cell.titleLbl.font = UIFont.init(name: "Montserrat-Bold", size: 16)
                cell.titleLbl.textColor = .black
            }else {
                cell.titleLbl.text = "if someone is in immediate danger, get help before reporting to Friendzr. Don't wait.".localizedString
                cell.titleLbl.font = UIFont.init(name: "Montserrat-Medium", size: 12)
                cell.titleLbl.textColor = .gray
            }
            
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
            cell.textView.addDoneOnKeyboard(withTarget: self, action: #selector(dismissKeyboard))
            return cell
        }
        else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: confirmBtnCellID, for: indexPath) as? ConfirmReportButtonTableViewCell else {return UITableViewCell()}
            cell.HandleConfirmBtn = {
                if self.id != "" {
                    if NetworkConected.internetConect {
                        cell.confirmBtn.setTitle("Submitting...", for: .normal)
                        cell.confirmBtn.isUserInteractionEnabled = false
                        self.viewmodel.sendReport(withID: self.id, reportType: self.reportType, message: self.message, reportReasonID: self.problemID) { error, data in
                            if let error = error {
                                DispatchQueue.main.async {
                                    self.view.makeToast(error)
                                    cell.confirmBtn.setTitle("Submit", for: .normal)
                                    cell.confirmBtn.isUserInteractionEnabled = true
                                }
                                return
                            }
                            
                            guard let _ = data else {return}
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                if self.selectedVC == "Present" || self.selectedVC == "PresentC" {
                                    self.onDismiss()
                                }else {
                                    self.onPopup()
                                }
                            }
                        }
                    }
                }else {
                    DispatchQueue.main.async {
                        self.view.makeToast("Please select a problem".localizedString)
                        return
                    }
                }
                
            }
            return cell
        }
    }
}

//MARK: - UITableViewDelegate
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
