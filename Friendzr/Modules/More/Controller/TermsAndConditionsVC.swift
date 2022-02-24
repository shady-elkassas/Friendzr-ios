//
//  TermsAndConditionsVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 16/08/2021.
//

import UIKit
import WebKit

class TermsAndConditionsVC: UIViewController,WKNavigationDelegate {
    
    //MARK:- Outlets
    @IBOutlet weak var viewForEmbeddingWebView: UIView!
    
    //MARK: - Properties
    var webView: WKWebView!
    var titleVC = ""
    var urlString = ""
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        clearNavigationBar()
        initBackButton()
        setupWebView()
        self.title = titleVC
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Defaults.availableVC = "TermsAndConditionsVC"
        print("availableVC >> \(Defaults.availableVC)")
        
        hideNavigationBar(NavigationBar: false, BackButton: false)
        CancelRequest.currentTask = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.hideLoading()
        CancelRequest.currentTask = true
    }
    
    //MARK: - Helper
    func setupWebView() {
        webView = WKWebView(frame: CGRect(x: 0, y: 0, width: viewForEmbeddingWebView.frame.width, height: viewForEmbeddingWebView.frame.height), configuration: WKWebViewConfiguration() )
        self.viewForEmbeddingWebView.addSubview(webView)
        webView.backgroundColor = .clear
        webView.navigationDelegate = self
        self.webView.allowsBackForwardNavigationGestures = true
        webView.contentMode = .scaleToFill
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.scrollView.showsVerticalScrollIndicator = false
        let myURL = URL(string: urlString)
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }
}
