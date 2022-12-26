//
//  RecommendedEventCollectionViewCell.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 24/08/2022.
//

import UIKit
import SDWebImage

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
    @IBOutlet weak var openEventBtn: UIButton!
    
    @IBOutlet weak var skipBtnView: UIView!
    var HandleExpandBtn: (()->())?
    var HandleSkipBtn: (()->())?

    var model:RecommendedEventObj! {
        didSet {
            enventNameLbl.text = model?.title
            eventImg.sd_imageIndicator = SDWebImageActivityIndicator.gray
            eventImg.sd_setImage(with: URL(string: model?.image ?? "" ), placeholderImage: UIImage(named: "placeHolderApp"))
            infoLbl.text = model?.descriptionEvent
            attendeesLbl.text = "Attendees: \(model?.attendees ?? 0) / \(model?.from ?? 0)"
            startDateLbl.text = model?.eventDate
            bgView.backgroundColor =  UIColor.color((model?.eventtypecolor ?? ""))
        }
    }
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
        skipBtnView.cornerRadiusView(radius: 6)
    }
    @IBAction func expandBtn(_ sender: Any) {
        HandleExpandBtn?()
    }
    
    @IBAction func skipBtn(_ sender: Any) {
        HandleSkipBtn?()
    }
    
    @IBAction func openEventBtn(_ sender: Any) {
        HandleExpandBtn?()
    }
    
}
