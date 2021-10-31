//
//  ShowImageVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 25/08/2021.
//

import UIKit
import SDWebImage

class ShowImageVC: UIViewController {
    
    @IBOutlet weak var imgView: UIImageView!
    var imgURL: String? = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initBackButton()
        title = "Show Image"
        setupNavBar()
        imgView.sd_setImage(with: URL(string: imgURL ?? "") , placeholderImage: UIImage(named: "placeholder"))
    }
}
