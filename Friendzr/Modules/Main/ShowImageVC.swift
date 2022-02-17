//
//  ShowImageVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 25/08/2021.
//

import UIKit
import SDWebImage

class ShowImageVC: UIViewController ,UIScrollViewDelegate {
    
    @IBOutlet weak var imgView: UIImageView!
    
    var imgURL: String? = ""
    var scrollImg: UIScrollView = UIScrollView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initBackButton()
        title = "Show Image".localizedString
        setupNavBar()
        imgView.sd_setImage(with: URL(string: imgURL ?? "") , placeholderImage: UIImage(named: "placeHolderApp"))
        
        imgView.enableZoom()
//        setupScrollView()
    }
    
    func setupScrollView() {
        scrollImg.delegate = self
        scrollImg.frame = CGRect(x: 0, y: 0, width: screenW, height: screenH)
        scrollImg.backgroundColor = UIColor(red: 90, green: 90, blue: 90, alpha: 0.90)
        scrollImg.alwaysBounceVertical = false
        scrollImg.alwaysBounceHorizontal = false
        scrollImg.showsVerticalScrollIndicator = true
        scrollImg.flashScrollIndicators()
        
        scrollImg.minimumZoomScale = 1.0
        scrollImg.maximumZoomScale = 10.0
        scrollImg.zoomScale = 1.0

        self.view.addSubview(scrollImg)
        
        imgView!.layer.cornerRadius = 11.0
        imgView!.clipsToBounds = false
        scrollImg.addSubview(imgView)
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imgView
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imgView
    }
    
    @IBAction func closeBtn(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func cancelpopups(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}



