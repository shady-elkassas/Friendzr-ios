//
//  CategoriesViewController.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 05/06/2022.
//

import UIKit

class CategoriesViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var applyBtn: UIButton!
    
    var viewmodel:AllCategoriesViewModel = AllCategoriesViewModel()
    let cellID = "FilterCatsTableViewCell"

    var selectedIDs = [String]()
    var selectedNames = [String]()
    var selectedCats:[CategoryObj] = [CategoryObj]()

    var onListCatsCallBackResponse: ((_ listIDs: [String],_ listNames: [String],_ selectCats:[CategoryObj]) -> ())?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBar()
        title = "Filter By Categories"
        initCloseBarButton()
        
        setupViews()

        getCats()
        
        Defaults.availableVC = "CategoriesViewController"
        print("availableVC >> \(Defaults.availableVC)")
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.post(name: Notification.Name("updateFilterBtn"), object: nil, userInfo: nil)
    }
    //MARK: - APIs
    func getCats() {
        viewmodel.getAllCategories()
        viewmodel.cats.bind { [unowned self] value in
            DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.5) {
                self.tableView.dataSource = self
                self.tableView.delegate = self
                self.tableView.reloadData()
            }
        }
        
        // Set View Model Event Listener
        viewmodel.error.bind { [unowned self]error in
            DispatchQueue.main.async {
                DispatchQueue.main.async {
                    self.view.makeToast(error)
                }
            }
        }
    }
    
    func setupViews() {
        tableView.allowsMultipleSelection = true
        tableView.register(UINib(nibName: cellID, bundle: nil), forCellReuseIdentifier: cellID)
        applyBtn.cornerRadiusView(radius: 8)
    }
    
    
    @IBAction func applyBtn(_ sender: Any) {
        onListCatsCallBackResponse?(selectedIDs,selectedNames,selectedCats)
        self.onDismiss()
    }
}

extension CategoriesViewController:UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewmodel.cats.value?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? FilterCatsTableViewCell else {return UITableViewCell()}
        let model = viewmodel.cats.value?[indexPath.row]
        cell.nameLbl.text = model?.name
        
        if indexPath.row == (viewmodel.cats.value?.count ?? 0) - 1 {
            cell.bottomView.isHidden = true
        }
        
        if selectedIDs.contains(model?.id ?? "") {
            cell.selectedImg.image = UIImage(named: "selected_ic")
        }
        else {
            cell.selectedImg.image = UIImage(named: "unSelected_ic")
        }
        
        return cell
    }
    
    
}

extension CategoriesViewController:UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let type = viewmodel.cats.value?[indexPath.row]
        if selectedCats.contains(where: { $0.id == type?.id }) {
            // found
            selectedCats.removeAll(where: { $0.id == type?.id })
        } else {
            // not
            selectedCats.append(type!)
        }
        
        //remove the lbl
        if selectedIDs.count != 0 {
            selectedIDs.removeAll()
            selectedNames.removeAll()
            for item in selectedCats {
                selectedIDs.append(item.id ?? "")
                selectedNames.append(item.name ?? "")
            }
        }else {
            for item in selectedCats {
                selectedIDs.append(item.id ?? "")
                selectedNames.append(item.name ?? "")
            }
        }
        
        print("selectedIDs = \(selectedIDs)")
        print("selectedNames = \(selectedNames)")
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let type = viewmodel.cats.value?[indexPath.row]
        if selectedCats.contains(where: { $0.id == type?.id }) {
            // found
            selectedCats.removeAll(where: { $0.id == type?.id })
        } else {
            // not
            selectedCats.append(type!)
        }
        
        //remove the lbl
        selectedIDs.removeAll()
        selectedNames.removeAll()
        for item in selectedCats {
            selectedIDs.append(item.id ?? "" )
            selectedNames.append(item.name ?? "" )
        }
        
        print("selectedIDs = \(selectedIDs)")
        print("selectedNames = \(selectedNames)")
        tableView.reloadData()

    }
}
