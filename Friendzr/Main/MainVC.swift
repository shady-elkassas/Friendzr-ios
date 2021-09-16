//
//  ViewController.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 10/08/2021.
//

import UIKit
import SwiftUI
import JGProgressHUD
import CoreLocation

class UserChatList {
    var name = ""
    var profileImg = ""
    var date = ""
    var message = ""
    var isMute = false
    var isArchive = false
    
    
    init(name:String,profileImg:String,date:String,message:String,isMute:Bool,isArchive:Bool) {
        self.date = date
        self.name = name
        self.profileImg = profileImg
        self.message = message
        self.isArchive = isArchive
        self.isMute = isMute
    }
}
class MainVC: UIViewController, CLLocationManagerDelegate {

    //MARK:- Outlets
    @IBOutlet weak var searchContainerView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!

    //MARK: - Properties
    let cellID = "ChatListTableViewCell"
    var UsersList = [UserChatList]()
    var updateLocationVM:UpdateLocationViewModel = UpdateLocationViewModel()
    
    var locationManager: CLLocationManager!
    var locationLat = 0.0
    var locationLng = 0.0

    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        initProfileBarButton()
        initNewConversationBarButton()
        self.title = "Inbox"
        setupNavBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        hideNavigationBar(NavigationBar: false, BackButton: true)
        setupCLLocationManager()
    }
    
    //MARK: - Helper
    func setup() {
        setupSearchBar()
        tableView.register(UINib(nibName: cellID, bundle: nil), forCellReuseIdentifier: cellID)
        
        UsersList.append(UserChatList(name: "Ahmed", profileImg: "Dan-Leonard", date: "11:23 AM", message: "Hey Cody, you should definitely check out Yoga Six for hot yoga! They have…",isMute: false,isArchive: false))
        UsersList.append(UserChatList(name: "Ebrahim", profileImg: "Tim-Cook", date: "11:23 AM", message: "Hey Cody, you should definitely check out Yoga Six for hot yoga! They have…",isMute: false,isArchive: false))
        UsersList.append(UserChatList(name: "kamal", profileImg: "Dan-Leonard", date: "11:23 AM", message: "Hey Cody, you should definitely check out Yoga Six for hot yoga! They have…",isMute: false,isArchive: false))
        UsersList.append(UserChatList(name: "Muhammed Sabri", profileImg: "Dan-Leonard", date: "11:23 AM", message: "Hey Cody, you should definitely check out Yoga Six for hot yoga! They have…",isMute: false,isArchive: false))
        UsersList.append(UserChatList(name: "Esraa", profileImg: "p1", date: "11:23 AM", message: "Hey Cody, you should definitely check out Yoga Six for hot yoga! They have…",isMute: false,isArchive: false))
        UsersList.append(UserChatList(name: "Mona", profileImg: "p0", date: "11:23 AM", message: "Hey Cody, you should definitely check out Yoga Six for hot yoga! They have…",isMute: false,isArchive: false))
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
    
    func updateMyLocation() {
        updateLocationVM.updatelocation(ByLat: self.locationLat, AndLng: self.locationLng) { error, data in
            if let error = error {
                self.showAlert(withMessage: error)
                return
            }
            guard let _ = data else {return}
        }
    }
    
    
    func setupCLLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation :CLLocation = locations[0] as CLLocation
        
        manager.stopUpdatingLocation()
        print("user latitude = \(userLocation.coordinate.latitude)")
        print("user longitude = \(userLocation.coordinate.longitude)")
        
        self.locationLat = userLocation.coordinate.latitude
        self.locationLng = userLocation.coordinate.longitude
        Defaults.LocationLat = "\(self.locationLat )"
        Defaults.LocationLng = "\(self.locationLng )"
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(userLocation) { (placemarks, error) in
            if (error != nil){
                print("error in reverseGeocode")
            }
            
            let placemark = (placemarks ?? []) as [CLPlacemark]
            if placemark.count>0{
                let placemark = placemarks![0]
                print(placemark.locality!)
                print(placemark.administrativeArea!)
                print(placemark.country!)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.updateMyLocation()
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
//        self.checkLocationPermission()
    }
}

//MARK: - Extensions
extension MainVC:UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UsersList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? ChatListTableViewCell else {return UITableViewCell()}
        let model = UsersList[indexPath.row]
        cell.nameLbl.text = model.name
        cell.lastMessageLbl.text = model.message
        cell.lastMessageDateLbl.text = model.date
        cell.profileImg.image = UIImage(named: model.profileImg)
        
        if indexPath.row == (UsersList.count - 1) {
            cell.underView.isHidden = true
        }
        
        if model.isArchive {
            cell.containerView.backgroundColor = .systemBlue
        }else if model.isMute {
            cell.containerView.backgroundColor = .systemGreen
        }else {
            cell.containerView.backgroundColor = .white
        }
        
        return cell
    }
    
    
}
extension MainVC:UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let detailViewController = BasicExampleViewController()
//        appDelegate.window?.rootViewController = detailViewController
//        appDelegate.window?.makeKeyAndVisible()
        
        let vc = ChatVC()
//        vc.title = "Muhammed Sabri"
//        vc.navigationItem.largeTitleDisplayMode = .never
//        vc.isNewConversation = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let archiveTitle = self.UsersList[indexPath.row].isArchive ? "UnArchive" : "Archive"
        let muteTitle = self.UsersList[indexPath.row].isMute ? "UnMute" : "Mute"

        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { action, indexPath in
            print("deleteAction")
            self.UsersList.remove(at: indexPath.row)
            tableView.reloadData()
            self.view.makeToast("Deleted")
        }
        let archiveAction = UITableViewRowAction(style: .default, title: archiveTitle) { action, indexPath in
            print("archiveAction")
            self.UsersList[indexPath.row].isArchive.toggle()
            tableView.reloadData()
            self.view.makeToast("Archived")
        }
        let muteAction = UITableViewRowAction(style: .default, title: muteTitle) { action, indexPath in
            print("muteAction")
            self.UsersList[indexPath.row].isMute.toggle()
            tableView.reloadData()
            self.view.makeToast("Muted")
        }
        
        archiveAction.backgroundColor = .systemBlue
        muteAction.backgroundColor = .systemGreen
        return [deleteAction,archiveAction,muteAction]
    }
}

extension MainVC: UISearchBarDelegate{
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
