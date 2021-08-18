//
//  TermsAndConditionsVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 16/08/2021.
//

import UIKit
import WebKit

class TermsAndConditionsVC: UIViewController {

    
    @IBOutlet weak var viewForEmbeddingWebView: UIView!
    var webView: WKWebView!
    var titleVC = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        clearNavigationBar()
        initBackButton()
        setupWebView()
        self.title = titleVC
    }
    
    func setupWebView() {
        webView = WKWebView(frame: viewForEmbeddingWebView.bounds, configuration: WKWebViewConfiguration() )
        self.viewForEmbeddingWebView.addSubview(webView)
        self.webView.allowsBackForwardNavigationGestures = true
        let myURL = URL(string: "https://www.apple.com")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }
}
