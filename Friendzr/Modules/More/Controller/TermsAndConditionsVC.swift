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
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
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
        
        webView = WKWebView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height), configuration: WKWebViewConfiguration() )
        self.view.addSubview(webView)
        webView.backgroundColor = .clear
        webView.navigationDelegate = self
        self.webView.allowsBackForwardNavigationGestures = true
        webView.contentMode = .scaleToFill
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.scrollView.showsVerticalScrollIndicator = false

        let myURL = URL(string: urlString)
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
        
        // add activity
        self.webView.addSubview(self.activity)
        self.activity.startAnimating()
        self.webView.navigationDelegate = self
        self.activity.hidesWhenStopped = true
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activity.stopAnimating()
        activity.isHidden = true
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activity.stopAnimating()
        activity.isHidden = true
    }
}
