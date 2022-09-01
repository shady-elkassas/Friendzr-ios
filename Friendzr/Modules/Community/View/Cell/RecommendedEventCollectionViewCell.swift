//
//  RecommendedEventCollectionViewCell.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 24/08/2022.
//

import UIKit

class RecommendedEventCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var eventImg: UIImageView!
    @IBOutlet weak var expandBtn: UIButton!
    @IBOutlet weak var enventNameLbl: UILabel!
    @IBOutlet weak var infoLbl: UILabel!
    @IBOutlet weak var startDateLbl: UILabel!
    @IBOutlet weak var attendeesLbl: UILabel!
    @IBOutlet weak var skipBtn: UIButton!
    
    var HandleExpandBtn: (()->())?
    var HandleSkipBtn: (()->())?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        setupView()
    }
    
    func setupView() {
        containerView.setBorder()
        eventImg.cornerRadiusView(radius: 12)
        bgView.cornerRadiusView(radius: 10)
        containerView.cornerRadiusView(radius: 8)
        skipBtn.cornerRadiusView(radius: 6)
        
//        skipBtn.imageEdgeInsets.left = skipBtn.frame.width
//        skipBtn.titleEdgeInsets.left = -10
    }
    @IBAction func expandBtn(_ sender: Any) {
        HandleExpandBtn?()
    }
    
    @IBAction func skipBtn(_ sender: Any) {
        HandleSkipBtn?()
    }
    
    
}
