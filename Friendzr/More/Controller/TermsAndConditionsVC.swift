//
//  TermsAndConditionsVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 16/08/2021.
//

import UIKit
import WebKit

class TermsAndConditionsVC: UIViewController {
    
    //MARK:- Outlets
    @IBOutlet weak var viewForEmbeddingWebView: UIView!
    
    //MARK: - Properties
    var webView: WKWebView!
    var titleVC = ""
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        clearNavigationBar()
        initBackButton()
        setupWebView()
        self.title = titleVC
    }
    
    //MARK: - Helper
    func setupWebView() {
        webView = WKWebView(frame: viewForEmbeddingWebView.bounds, configuration: WKWebViewConfiguration() )
        self.viewForEmbeddingWebView.addSubview(webView)
        self.webView.allowsBackForwardNavigationGestures = true
        let myURL = URL(string: "https://www.apple.com")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }
}
