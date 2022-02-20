//
//  HideGhostModeView.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 16/08/2021.
//

import Foundation
import UIKit

class SelectedSingleTone {
    static var isSelected: Bool = false
}

class GhostModeType {
    
    var id:Int = 0
    var name: String = ""
    var color: UIColor = UIColor()
    var isSelected: Bool = false
    
    init(id:Int,name:String,color:UIColor,isSelected:Bool) {
        self.id = id
        self.color = color
        self.name = name
        self.isSelected = isSelected
    }
}

class HideGhostModeView: UIView {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var saveBtn: UIButton!
    
    var HandlehideViewBtn: (()->())?
    var HandleSaveBtn: (()->())?
    
    let cellId = "GhostModeTableViewCell"
    var hideArray:[GhostModeType] = [GhostModeType]()
    var selectedHideType:[GhostModeType] = [GhostModeType]()
    var typeIDs = [Int]()
    var typeStrings = [String]()
    var parentVC = UIViewController()
    
    var onTypesCallBackResponse: ((_ data: [String], _ value: [Int]) -> ())?
    
    override func awakeFromNib() {
        containerView.shadow()
        containerView.cornerRadiusView(radius: 12)
        saveBtn.cornerRadiusView(radius: 8)
        
        hideArray.append(GhostModeType(id: 2, name: "Men", color: UIColor.blue, isSelected: false))
        hideArray.append(GhostModeType(id: 3, name: "Women", color: UIColor.red, isSelected: false))
        hideArray.append(GhostModeType(id: 4, name: "Other Gender", color: UIColor.darkGray, isSelected: false))
        
        tableView.allowsMultipleSelection = true
        tableView.register(UINib(nibName: cellId, bundle: nil), forCellReuseIdentifier: cellId)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }
    
    
    @IBAction func hideViewBtn(_ sender: Any) {
        HandlehideViewBtn?()
        UIView.animate(withDuration: 0.3, animations: {
            self.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.alpha = 0
        }) { (success: Bool) in
            self.removeFromSuperview()
            self.alpha = 1
            self.transform = CGAffineTransform.init(scaleX: 1, y: 1)
        }
    }
    
    @IBAction func saveBtn(_ sender: Any) {
   
        if typeIDs.count > 2 {
            self.parentVC.view.makeToast("You can only select two".localizedString)
            return
        }else {
            if SelectedSingleTone.isSelected == true {
                onTypesCallBackResponse?(["Everyone"],[1])
            }else {
                if typeIDs.count == 0 {
                    self.parentVC.view.makeToast("Please select a private mode type".localizedString)
                    return
                }else {
                    onTypesCallBackResponse?(typeStrings,typeIDs)
                }
            }
            
            HandleSaveBtn?()
            
            UIView.animate(withDuration: 0.3, animations: {
                self.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
                self.alpha = 0
            }) { (success: Bool) in
                self.removeFromSuperview()
                self.alpha = 1
                self.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            }
        }
    }
}


extension HideGhostModeView : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }else {
            return hideArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? GhostModeTableViewCell else {return UITableViewCell()}
        if indexPath.section == 0 {
            cell.titleLbl.text = "Everyone"
            cell.containerView.backgroundColor = UIColor.FriendzrColors.primary?.withAlphaComponent(0.5)

            if SelectedSingleTone.isSelected == true {
                print("isSelected")
                cell.containerView.backgroundColor = UIColor.FriendzrColors.primary!
            }else {
                print("unSelected")
                cell.containerView.backgroundColor = UIColor.FriendzrColors.primary?.withAlphaComponent(0.5)
            }
        }else {
            let model = hideArray[indexPath.row]
            cell.titleLbl.text = model.name
            cell.containerView.backgroundColor = model.color.withAlphaComponent(0.5)
            
            if SelectedSingleTone.isSelected == true {
                selectedHideType.removeAll()
                cell.containerView.backgroundColor = model.color.withAlphaComponent(0.5)
            }else {
                if model.isSelected {
                    cell.containerView.backgroundColor = model.color
                }else {
                    cell.containerView.backgroundColor = model.color.withAlphaComponent(0.5)
                }
            }
        }

        return cell
    }
    
    
}
extension HideGhostModeView : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){

        if indexPath.section == 0 {
            SelectedSingleTone.isSelected = true
            selectedHideType.removeAll()
            typeIDs.removeAll()
            typeStrings.removeAll()
            
            for itm in hideArray {
                itm.isSelected = false
            }
        }else {
            SelectedSingleTone.isSelected = false
            let type = hideArray[indexPath.row]

            if selectedHideType.contains(where: { $0.id == type.id }) {
                // found
                print("remove")
                selectedHideType.removeAll(where: { $0.id == type.id })
                type.isSelected = false
            } else {
                // not
                print("append")
                selectedHideType.append(type)
                type.isSelected = true
            }
            
            //remove the lbl
            if typeIDs.count != 0 {
                typeIDs.removeAll()
                typeStrings.removeAll()
                for item in selectedHideType {
                    typeIDs.append(item.id)
                    typeStrings.append(item.name)
                }
            }else {
                for item in selectedHideType {
                    typeIDs.append(item.id)
                    typeStrings.append(item.name)
                }
            }
            
            print("typeIDs = \(typeIDs)")
            print("typeStrings = \(typeStrings)")
        }
        
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {

        if indexPath.section == 0 {
            SelectedSingleTone.isSelected = true
            selectedHideType.removeAll()
            typeIDs.removeAll()
            typeStrings.removeAll()
            
            for itm in hideArray {
                itm.isSelected = false
            }
        }else {
            SelectedSingleTone.isSelected = false
            let type = hideArray[indexPath.row]
            if selectedHideType.contains(where: { $0.id == type.id }) {
                // found
                print("remove")
                selectedHideType.removeAll(where: { $0.id == type.id })
                type.isSelected = false
            } else {
                // not
                print("append")
                selectedHideType.append(type)
                type.isSelected = true
            }
            
            
            //remove the lbl
            typeIDs.removeAll()
            typeStrings.removeAll()
            for item in selectedHideType {
                typeIDs.append(item.id)
                typeStrings.append(item.name)
            }
            
            print("typeIDs = \(typeIDs)")
            print("typeStrings = \(typeStrings)")

        }
        
        tableView.reloadData()
    }
}
