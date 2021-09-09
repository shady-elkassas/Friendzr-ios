//
//  EventsVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 16/08/2021.
//

import UIKit

class EventsVC: UIViewController {
    
    //MARK:- Outlets
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - Properties
    let cellID = "EventTableViewCell"
    var viewmodel:EventsViewModel = EventsViewModel()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Events"
        setupView()
        getAllEvents()
        initBackButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        clearNavigationBar()
    }
    
    func getAllEvents() {
        self.showLoading()
        viewmodel.getAllEvents()
        viewmodel.events.bind { [unowned self] value in
            DispatchQueue.main.async {
                self.hideLoading()
                tableView.delegate = self
                tableView.dataSource = self
                tableView.reloadData()
                initAddNewEventBarButton(total: value.count)
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
    
    //MARK: - Helper
    func setupView() {
        tableView.register(UINib(nibName: cellID, bundle: nil), forCellReuseIdentifier: cellID)
    }
}

//MARK: - Extensions
extension EventsVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewmodel.events.value?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? EventTableViewCell else {return UITableViewCell()}
        let model = viewmodel.events.value?[indexPath.row]
        cell.attendeesLbl.text = "Attendees : \(model?.attendees?.count ?? 0) / \(model?.totalnumbert ?? 0)"
        cell.eventTitleLbl.text = model?.title
        cell.categoryLbl.text = model?.categorie
        cell.dateLbl.text = model?.eventdate
        cell.eventImg.sd_setImage(with: URL(string: model?.image ?? "" ), placeholderImage: UIImage(named: "photo_img"))
        return cell
    }
}

extension EventsVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vc = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "EventDetailsVC") as? EventDetailsVC else {return}
        vc.eventId = viewmodel.events.value?[indexPath.row].id ?? ""
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension EventsVC {
    func initAddNewEventBarButton(total:Int) {
        let button = UIButton.init(type: .custom)
        button.setTitle("Total Event: \(total)".localizedString, for: .normal)
        button.setTitleColor(UIColor.color("#141414"), for: .normal)
        button.titleLabel?.font = UIFont.init(name: "Montserrat-SemiBold", size: 12)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButton
    }
}
