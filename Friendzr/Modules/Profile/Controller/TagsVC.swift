//
//  TagsVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 17/08/2021.
//

import UIKit
import SpriteKit
import ListPlaceholder

class TagsVC: UIViewController {
    
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var tryAgainBtn: UIButton!
    @IBOutlet weak var emptyLbl: UILabel!
    @IBOutlet weak var emptyImg: UIImageView!

    var vm = InterestsViewModel()
    var normalInterests:[InterestObj]!
    var onInterestsCallBackResponse: ((_ data: [String], _ value: [String]) -> ())?
    var ids:[String] = [String]()
    var names:[String] = [String]()

    //MARK:- Outlets
    @IBOutlet weak var magneticView: MagneticView! {
        didSet {
            magnetic.magneticDelegate = self
            magnetic.removeNodeOnLongPress = true
            #if DEBUG
            magneticView.showsFPS = true
            magneticView.showsDrawCount = true
            magneticView.showsQuadCount = true
            magneticView.showsPhysics = true
            #endif
        }
    }
    
    var magnetic: Magnetic {
        return magneticView.magnetic
    }
    
    //MARK: - Life Cycle

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        initBackButton()
        self.title = "Tags"
        setupNavBar()
        
        DispatchQueue.main.async {
            self.updateUserInterface()
        }
        
//        self.view.backgroundColor = UIColor.setColor(lightColor: .white, darkColor: .black)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        print("availableVC >> \(Defaults.availableVC)")
        CancelRequest.currentTask = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.hideLoading()
        CancelRequest.currentTask = true
    }
    
    func addTags(node:InterestObj)  {
        let name = node.name
        let color = UIColor.colors.randomItem()
        
        let node = Node(nodeId:(node.id ?? ""), text: name?.capitalized, image: UIImage(named: ""), color: color, radius: 40)
        node.scaleToFitContent = true
        node.selectedColor = UIColor.FriendzrColors.primary
        magnetic.addChild(node)
    }
    
    //MARK: - APIs
    
    func getAllTags() {
        vm.getAllInterests(completion: { (error, cats) in
            if let error = error {
                DispatchQueue.main.async {
                    if error == "Internal Server Error" {
                        self.HandleInternetConnection()
                    }else if error == "Bad Request" {
                        self.HandleinvalidUrl()
                    }else {
                        DispatchQueue.main.async {
                            self.view.makeToast(error)
                        }
                    }
                }
                
                return
            }
            
            
            guard let data = cats else {return}
            
            if data.count == 0 {
                self.emptyView.isHidden = false
                self.emptyLbl.text = "You haven't any data yet".localizedString
                self.tryAgainBtn.alpha = 0.0
            }else {
                self.emptyView.isHidden = true
                self.tryAgainBtn.alpha = 0.0
                
                for item in data {
                    self.addTags(node: item)
                }
                self.normalInterests = data
            }
        })
    }
    
    //MARK: - Helper
    
    func updateUserInterface() {
//        appDelegate.networkReachability()
//
//        switch Network.reachability.status {
//        case .unreachable:
//            self.emptyView.isHidden = false
//            HandleInternetConnection()
//        case .wwan:
//            self.emptyView.isHidden = true
//            getAllTags()
//        case .wifi:
//            self.emptyView.isHidden = true
//            getAllTags()
//        }
//
//        print("Reachability Summary")
//        print("Status:", Network.reachability.status)
//        print("HostName:", Network.reachability.hostname ?? "nil")
//        print("Reachable:", Network.reachability.isReachable)
//        print("Wifi:", Network.reachability.isReachableViaWiFi)
    }
    
    func HandleinvalidUrl() {
        emptyView.isHidden = false
        emptyImg.image = UIImage.init(named: "maskGroup9")
        emptyLbl.text = "sorry for that we have some maintaince with our servers please try again in few moments".localizedString
        tryAgainBtn.alpha = 1.0
    }
    
    func HandleInternetConnection() {
        emptyView.isHidden = false
        emptyImg.image = UIImage.init(named: "feednodata_img")
        emptyLbl.text = "No available network, please try again!".localizedString
        tryAgainBtn.alpha = 1.0
    }

    //MARK: - Actions
    @IBAction func add(_ sender: UIControl?) {
        ids.removeAll()
        names.removeAll()
        
        for itm in self.magnetic.selectedChildren {
            print("selected item")
            print(itm.nodeId)
            
            ids.append(itm.nodeId)
            names.append(itm.text!)
            
            if ids.count > 5 {
//                self.showAlert(withMessage: "Choose maximum 5 interests".localizedString)
                
                DispatchQueue.main.async {
                    self.view.makeToast("Choose a maximum of 5 interests".localizedString)
                }
                return
            }else {
                onInterestsCallBackResponse!(ids,names)
            }
        }
        
        if ids.count == 0 {
//            self.showAlert(withMessage: "You have to select Interests".localizedString)
            DispatchQueue.main.async {
                self.view.makeToast("You have to select Interests".localizedString)
            }
            return
        }else {
            self.onPopup()
        }
    }
    
    @IBAction func reset(_ sender: UIControl?) {
        magneticView.magnetic.reset()
        DispatchQueue.main.async() {
            if self.normalInterests.count > 0 {
                for item in  self.normalInterests {
                    self.addTags(node: item)
                }
            } else {
                self.vm.getAllInterests(completion: { (error, cats) in
                    if let error = error {
                        DispatchQueue.main.async {
                            self.view.makeToast(error)
                        }
                        return
                    }
                    guard let data = cats else {return}
                    for item in data {
                        self.addTags(node: item)
                    }
                    self.normalInterests = data
                    
                })
            }
        }
    }
    
    @IBAction func tryAgainBtn(_ sender: Any) {
        updateUserInterface()
    }
}

// MARK: - MagneticDelegate
extension TagsVC: MagneticDelegate {
    
    func magnetic(_ magnetic: Magnetic, didSelect node: Node) {
        print("didSelect -> \(node.nodeId)")
    }
    
    func magnetic(_ magnetic: Magnetic, didDeselect node: Node) {
        print("didDeselect -> \(node.nodeId)")
    }
    
    func magnetic(_ magnetic: Magnetic, didRemove node: Node) {
        print("didRemove -> \(node.nodeId)")
    }
    
}

// MARK: - ImageNode
class ImageNode: Node {
    override var image: UIImage? {
        didSet {
            texture = image.map { SKTexture(image: $0) }
        }
    }
    override func selectedAnimation() {}
    override func deselectedAnimation() {}
}
