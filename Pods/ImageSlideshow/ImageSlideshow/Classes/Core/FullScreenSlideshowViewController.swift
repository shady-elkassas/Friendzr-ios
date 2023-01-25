//
//  FullScreenSlideshowViewController.swift
//  ImageSlideshow
//
//  Created by Petr Zvoníček on 31.08.15.
//

import UIKit
import SwiftUI

@objcMembers
open class FullScreenSlideshowViewController: UIViewController {
    
    open var slideshow: ImageSlideshow = {
        let slideshow = ImageSlideshow()
        slideshow.zoomEnabled = true
        slideshow.contentScaleMode = UIViewContentMode.scaleAspectFit
        slideshow.pageIndicatorPosition = PageIndicatorPosition(horizontal: .center, vertical: .bottom)
        // turns off the timer
        slideshow.slideshowInterval = 0
        slideshow.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        
        return slideshow
    }()
    
    /// Close button
    open var closeButton = UIButton()
    
    open var optionsButton = UIButton()
    
    /// Close button frame
    open var closeButtonFrame: CGRect?
    open var optionsButtonFrame: CGRect?
    
    /// Closure called on page selection
    open var pageSelected: ((_ page: Int) -> Void)?
    
    /// Index of initial image
    open var initialPage: Int = 0
    
    /// Input sources to
    open var inputs: [InputSource]?
    
    /// Background color
    open var backgroundColor = UIColor.black
    
    /// Enables/disable zoom
    open var zoomEnabled = true {
        didSet {
            slideshow.zoomEnabled = zoomEnabled
        }
    }
    
    fileprivate var isInit = true
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
        
        self.modalPresentationStyle = .custom
        if #available(iOS 13.0, *) {
            // Use KVC to set the value to preserve backwards compatiblity with Xcode < 11
            self.setValue(true, forKey: "modalInPresentation")
        }
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = backgroundColor
        slideshow.backgroundColor = backgroundColor
        
        if let inputs = inputs {
            slideshow.setImageInputs(inputs)
        }
        
        view.addSubview(slideshow)
        
        // close button configuration
        closeButton.setImage(UIImage(named: "ic_cross_white", in: .module, compatibleWith: nil), for: UIControlState())
        closeButton.addTarget(self, action: #selector(FullScreenSlideshowViewController.close), for: UIControlEvents.touchUpInside)
        view.addSubview(closeButton)
        
        // close button configuration
        optionsButton.setImage(UIImage(named: "menu_WH_ic"), for: .normal)
        optionsButton.addTarget(self, action: #selector(FullScreenSlideshowViewController.presentInputActionSheet), for: UIControlEvents.touchUpInside)
        view.addSubview(optionsButton)
    }
    
    override open var prefersStatusBarHidden: Bool {
        return true
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isInit {
            isInit = false
            slideshow.setCurrentPage(initialPage, animated: false)
        }
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        slideshow.slideshowItems.forEach { $0.cancelPendingLoad() }
        
        // Prevents broken dismiss transition when image is zoomed in
        slideshow.currentSlideshowItem?.zoomOut()
    }
    
    open override func viewDidLayoutSubviews() {
        if !isBeingDismissed {
            let safeAreaInsets: UIEdgeInsets
            if #available(iOS 11.0, *) {
                safeAreaInsets = view.safeAreaInsets
            } else {
                safeAreaInsets = UIEdgeInsets.zero
            }
            
            closeButton.frame = closeButtonFrame ?? CGRect(x: max(10, safeAreaInsets.left), y: max(10, safeAreaInsets.top), width: 40, height: 40)
            optionsButton.frame = optionsButtonFrame ?? CGRect(x: view.frame.width - 50, y: max(10, safeAreaInsets.top), width: 40, height: 40)
        }
        
        slideshow.frame = view.frame
    }
    
    func close() {
        // if pageSelected closure set, send call it with current page
        if let pageSelected = pageSelected {
            pageSelected(slideshow.currentPage)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func initOptionsImageButton() {
        let imageName = "menu_WH_ic"
        let button = UIButton.init(type: .custom)
        let image = UIImage.init(named: imageName)
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        button.setImage(image, for: .normal)
        button.addTarget(self, action:  #selector(presentInputActionSheet), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    func presentInputActionSheet() {
        let actionSheet  = UIAlertController()
        
        let saveBtn = UIAlertAction(title: "Save", style: .default) {_ in
            let imag: UIImage? = self.slideshow.currentSlideshowItem?.imageView.image
            self.writeToPhotoAlbum(image: imag!)
        }
        
        let cancelBtn = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        actionSheet.addAction(saveBtn)
        actionSheet.addAction(cancelBtn)
        
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    
    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }
    
    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        print("Save finished!")
        let alert = UIAlertController(title: "Saved", message: "", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alert.addAction(cancel)
        DispatchQueue.main.async(execute: {
            self.present(alert, animated: true)
        })
    }
}
