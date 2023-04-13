//
//  EventsVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 16/08/2021.
//

import UIKit
import StoreKit


class SubscriptionsVC: UIViewController {
    
    @IBOutlet weak var monthlyBtn: UIButton!
    @IBOutlet weak var sixMonthBtn: UIButton!
    @IBOutlet weak var yearlyBtn: UIButton!

    @IBOutlet weak var restorePurchasesBtn: UIButton!
    
    var products = [SKProduct]()

 
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Subscriptions"
        initBackButton()
        setupView()
     
//        validate(productIdentifiers: productIds)
        
        StoreKitManager.sharedInstance.getProducts()
    }
    
    func setupView() {
        monthlyBtn.cornerRadiusView(radius: 8)
        sixMonthBtn.cornerRadiusView(radius: 8)
        yearlyBtn.cornerRadiusView(radius: 8)
        restorePurchasesBtn.cornerRadiusView(radius: 8)
    }
    
    
    @IBAction func monthlyBtn(_ sender: Any) {
        let pro = (StoreKitManager.sharedInstance.products?[0])!
        StoreKitManager.sharedInstance.purchase(productParam: pro)
    }
    
    @IBAction func sixMonthBtn(_ sender: Any) {
        let pro = (StoreKitManager.sharedInstance.products?[2])!
        StoreKitManager.sharedInstance.purchase(productParam: pro)
    }
    
    @IBAction func yearlyBtn(_ sender: Any) {
        let pro = (StoreKitManager.sharedInstance.products?[1])!
        StoreKitManager.sharedInstance.purchase(productParam: pro)
    }
    
    @IBAction func restorePurchasesBtn(_ sender: Any) {
        StoreKitManager.sharedInstance.restorePurchases()
    }
    
}
