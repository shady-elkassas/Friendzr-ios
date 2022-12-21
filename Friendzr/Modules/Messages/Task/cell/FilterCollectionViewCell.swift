//
//  FilterCollectionViewCell.swift
//  SoftExpert_Task_IOS
//
//  Created by Shady Elkassas on 18/12/2022.
//

import UIKit

class FilterCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var filterLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        containerView.setBorder()
        containerView.cornerRadiusView(radius: 10)
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                containerView.backgroundColor = .FriendzrColors.primary!
            }else {
                containerView.backgroundColor = .white
            }
        }
    }
}
