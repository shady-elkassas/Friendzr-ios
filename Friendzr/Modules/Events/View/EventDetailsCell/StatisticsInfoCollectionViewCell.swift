//
//  StatisticsInfoCollectionViewCell.swift
//  Friendzr
//
//  Created by Shady Elkassas on 10/03/2022.
//

import UIKit

class StatisticsInfoCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var maleLbl: UILabel!
    @IBOutlet weak var malePercentageLbl: UILabel!
    @IBOutlet weak var maleSlider: UISlider!
    
    @IBOutlet weak var femaleLbl: UILabel!
    @IBOutlet weak var femalePercentageLbl: UILabel!
    @IBOutlet weak var femaleSlider: UISlider!
    
    @IBOutlet weak var otherLbl: UILabel!
    @IBOutlet weak var otherPercentageLbl: UILabel!
    @IBOutlet weak var otherSlider: UISlider!
    
    @IBOutlet weak var interest1Lbl: UILabel!
    @IBOutlet weak var interest1PercentageLbl: UILabel!
    @IBOutlet weak var interest1Slider: UISlider!
    @IBOutlet weak var interest2Lbl: UILabel!
    @IBOutlet weak var interest2PercentageLbl: UILabel!
    @IBOutlet weak var interest2Slider: UISlider!
    @IBOutlet weak var interest3Lbl: UILabel!
    @IBOutlet weak var interest3PercentageLbl: UILabel!
    @IBOutlet weak var interest3Slider: UISlider!

    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
