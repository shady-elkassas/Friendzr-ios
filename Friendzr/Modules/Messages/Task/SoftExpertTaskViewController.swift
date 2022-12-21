//
//  SoftExpertTaskViewController.swift
//  Friendzr
//
//  Created by Shady Elkassas on 19/12/2022.
//

import UIKit
import SDWebImage

class SoftExpertTaskViewController: UIViewController {

    
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchbar: UISearchBar!
    
    @IBOutlet weak var collectionContainerView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var tableView: UITableView!
    
    var healthLabels:[(String,String)] = []
    
    
    let healthLabelsCellID = "FilterCollectionViewCell"
    let recipesCellID = "RecipeTableViewCell"
    
    var healthLabelID = "sugar-conscious"
    
    let viewmodel:SoftExpertTaskViewModel = SoftExpertTaskViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getAllRecipes(fromPage: 0, toPage: 20, healthName: healthLabelID, searchText: searchbar.text!)
        setupViews()
    }
    
    
    
    func getAllRecipes(fromPage:Int,toPage:Int,healthName:String,searchText:String) {
        viewmodel.getRecipes(fromPage: fromPage, toPage: toPage, healthName: healthName, searchText: searchText)
        viewmodel.recipes.bind { [weak self] value in
            DispatchQueue.main.async {
                self?.tableView.dataSource = self
                self?.tableView.delegate = self
                self?.tableView.reloadData()
            }
        }
        
        // Set View Model Event Listener
        viewmodel.error.bind { [weak self]error in
            DispatchQueue.main.async {
                self?.view.makeToast(error)
            }
        }
    }
    
    
    func setupViews() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        tableView.register(UINib(nibName: recipesCellID, bundle: nil), forCellReuseIdentifier: recipesCellID)
        collectionView.register(UINib(nibName: healthLabelsCellID, bundle: nil), forCellWithReuseIdentifier: healthLabelsCellID)
        
        healthLabels.append(("Sugar Conscious" , "sugar-conscious"))
        healthLabels.append(("Low Sugar", "low-sugar"))
        healthLabels.append(("Vegan" , "vegan"))
        healthLabels.append(("Vegetarian" , "vegetarian"))
        healthLabels.append(("Pescatarian" , "pescatarian"))
        healthLabels.append(("Mediterranean" , "mediterranean"))
        healthLabels.append(("Dairy Free" , "dairy-free"))
        healthLabels.append(("Gluten Free" , "gluten-free"))
        healthLabels.append(("Wheat Free" , "wheat-free"))
        healthLabels.append(("Egg Free" , "egg-free"))
        healthLabels.append(("Peanut Free" , "peanut-free"))
        healthLabels.append(("Tree Nut Free" , "tree-nut-free"))
        healthLabels.append(("Soy Free" , "soy-free"))
        healthLabels.append(("Fish Free" , "fish-free"))
        healthLabels.append(("Shellfish Free" , "shellfish-free"))
        healthLabels.append(("Pork Free" , "pork-free"))
        healthLabels.append(("Red Meat Free" , "red-meat-free"))
        healthLabels.append(("Crustacean Free" , "crustacean-free"))
        healthLabels.append(("No oil added" , "no-oil-added"))
        healthLabels.append(("Sulfite Free" , "sulfite-free"))
        healthLabels.append(("Kosher" , "kosher"))
    }
}

extension SoftExpertTaskViewController:UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return healthLabels.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: healthLabelsCellID, for: indexPath) as? FilterCollectionViewCell else {return UICollectionViewCell()}
        let model = healthLabels[indexPath.row]
        cell.filterLbl.text = model.0
        if indexPath.row == 0 && healthLabelID == "sugar-conscious" {
            cell.isSelected = true
        }
        return cell
    }
}

extension SoftExpertTaskViewController:UICollectionViewDelegateFlowLayout,UICollectionViewDelegate {
    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        return CGSize(width: 100, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = healthLabels[indexPath.row]
        healthLabelID = model.1
        
        getAllRecipes(fromPage: 0, toPage: 20, healthName: healthLabelID, searchText: "")
    }
}

extension SoftExpertTaskViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewmodel.recipes.value?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: recipesCellID, for: indexPath) as? RecipeTableViewCell else {return UITableViewCell()}
        let model = viewmodel.recipes.value?[indexPath.row]
        cell.recipeTitleLbl.text = model?.recipe?.label
        cell.recipeSourceLbl.text = model?.recipe?.source
        cell.recipeImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        cell.recipeImageView.sd_setImage(with: URL(string: model?.recipe?.image ?? "" ), placeholderImage: UIImage(named: "placeHolderApp"))
        return cell
    }
}
extension SoftExpertTaskViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}

