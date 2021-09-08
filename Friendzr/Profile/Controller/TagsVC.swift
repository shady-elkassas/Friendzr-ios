//
//  TagsVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 17/08/2021.
//

import UIKit
import SpriteKit

class TagsVC: UIViewController {
    
    var vm = InterestsViewModel()
    var normalInterests:[InterestObj]!
    var onInterestsCallBackResponse: ((_ data: [Int], _ value: [String]) -> ())?
    var ids:[Int] = [Int]()
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
        clearNavigationBar()
        
        self.showLoading()
        vm.getAllInterests(completion: { (error, cats) in
            self.hideLoading()
            if let error = error {
                self.showAlert(withMessage: error)
                return
            }
            guard let data = cats else {return}
            for item in data {
                self.addCats(node: item)
            }
            self.normalInterests = data
        })
    }
    
    func addCats(node:InterestObj)  {
        let name = node.name
        let color = UIColor.colors.randomItem()
        
        let node = Node(nodeId: node.id ?? 0, text: name?.capitalized, image: UIImage(named: ""), color: color, radius: 40)
        node.scaleToFitContent = true
        node.selectedColor = UIColor.FriendzrColors.primary
        magnetic.addChild(node)
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//
//        for _ in 0..<12 {
//            add(nil)
//        }
//    }
    
    
    //MARK: - Actions
    @IBAction func add(_ sender: UIControl?) {
//        if self.magnetic.selectedChildren.count == 0 {
//            self.showAlert(withMessage: "you have to select Interests".localizedString)
//        } else {
//
//        }
//
        for itm in self.magnetic.selectedChildren {
            print("selected item")
            print(itm.nodeId)
            
            ids.append(itm.nodeId)
            names.append(itm.text!)
            onInterestsCallBackResponse!(ids,names)
        }
        
        if ids.count == 0 {
            self.showAlert(withMessage: "you have to select Interests".localizedString)
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
                    self.addCats(node: item)
                }
            } else {
                self.showLoading()
                self.vm.getAllInterests(completion: { (error, cats) in
                    self.hideLoading()
                    if let error = error {
                        self.showAlert(withMessage: error)
                        return
                    }
                    guard let data = cats else {return}
                    for item in data {
                        self.addCats(node: item)
                    }
                    self.normalInterests = data
                    
                })
            }
        }
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
