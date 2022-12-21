//
//  RecipeTableViewCell.swift
//  SoftExpert_Task_IOS
//
//  Created by Shady Elkassas on 18/12/2022.
//

import UIKit

class RecipeTableViewCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var recipeTitleLbl: UILabel!
    @IBOutlet weak var recipeSourceLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        recipeImageView.setBorder()
        recipeImageView.cornerRadiusView(radius: 10)
        containerView.setBorder()
        containerView.cornerRadiusView(radius: 10)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
