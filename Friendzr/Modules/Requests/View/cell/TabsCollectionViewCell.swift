//
//  TabsCollectionViewCell.swift
//  Friendzr
//
//  Created by Shady Elkassas on 31/01/2022.
//

import UIKit

class TabsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        containerView.cornerRadiusView(radius: 8)
        
    }
    
    override var isSelected: Bool {
       didSet{
           if self.isSelected {
               UIView.animate(withDuration: 0.3) { // for animation effect
                   self.containerView.backgroundColor = .FriendzrColors.primary!
               }
           }
           else {
               UIView.animate(withDuration: 0.3) { // for animation effect
                   self.containerView.backgroundColor = .lightGray.withAlphaComponent(0.5)
               }
           }
       }
   }
}
