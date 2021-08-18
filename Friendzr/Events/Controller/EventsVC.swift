//
//  EventsVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 16/08/2021.
//

import UIKit

class EventsVC: UIViewController {
    
    @IBOutlet weak var totlaEventsLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    let cellID = "EventsTableViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Events"
        setup()
        initAddNewEventBarButton()
        initBackButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    func setup() {
        tableView.register(UINib(nibName: cellID, bundle: nil), forCellReuseIdentifier: cellID)
    }
}

extension EventsVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? EventsTableViewCell else {return UITableViewCell()}
        return cell
    }
}

extension EventsVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vc = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "EventDetailsVC") as? EventDetailsVC else {return}
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension EventsVC {
    func initAddNewEventBarButton() {
        let button = UIButton.init(type: .custom)
        button.tintColor = UIColor.color("#141414")
        button.setTitle("Add Event".localizedString, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.init(name: "Montserrat-SemiBold", size: 12)
        button.addTarget(self, action: #selector(goToAddEventVC), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    @objc func goToAddEventVC() {
//        if let controller = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "AddEventNC") as? UINavigationController, let _ = controller.viewControllers.first as? AddEventVC {
//            self.present(controller, animated: true)
//        }
        guard let vc = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "AddEventVC") as? AddEventVC else {return}
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
