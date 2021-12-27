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
        hideNavigationBar(NavigationBar: false, BackButton: false)
        CancelRequest.currentTask = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.hideLoading()
        CancelRequest.currentTask = true
    }
    
    //MARK: - Helper
    func setupWebView() {
        webView = WKWebView(frame: viewForEmbeddingWebView.bounds, configuration: WKWebViewConfiguration() )
        self.viewForEmbeddingWebView.addSubview(webView)
        self.webView.allowsBackForwardNavigationGestures = true
        webView.contentMode = .scaleAspectFill
        let myURL = URL(string: urlString)
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }
}
