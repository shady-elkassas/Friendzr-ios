//
//  InstagramWebVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 17/11/2021.
//

import UIKit
import WebKit
import Alamofire


class InstagramWebVC: UIViewController, WKNavigationDelegate {
    
    @IBOutlet weak var webView: WKWebView!
    
    var isUrlValid : Bool = false
    var baseUrl : String?
    var authToken:String = ""
    var userID : String = ""
    var accessTokenFinal : String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        
        let url = "https://api.instagram.com/oauth/authorize/?client_id=284152480286634&redirect_uri=https://friendzr.com/&response_type=code&display=touch&scope=user_profile,user_media"
        let req = URLRequest.init(url: URL.init(string: url)!)
        webView.load(req)
        
        initBackButton()
        clearNavigationBar()
    }
    
    
    func serviceCall(urlString : String) {
        
        self.isUrlValid = false
        let accessToken : String = String(authToken)
        
        let parameter = ["client_id":"284152480286634", "client_secret": "0654705463c20d184ad33dad0b706164", "code":accessToken, "grant_type": "authorization_code", "redirect_uri":"https://friendzr.com/"]
        
        AF.request(urlString, method: HTTPMethod(rawValue: HTTPMethod.post.rawValue), parameters: parameter, encoding: URLEncoding.default, headers: HTTPHeaders(["Content-Type" : "application/x-www-form-urlencoded"]))
            .responseJSON { response in
                
                print("Request URL : " + urlString)
                print("Param : ",parameter)
                
                print(response)
                
                switch response.result {
                case .success(let JSON):
                    let object = JSON as? NSDictionary
                    let code = object?["code"] as? Int ?? 0
                    let errorMessage = object?["error_message"] as? String ?? ""
                    
                    if code == 200 {
                        self.userID = object?["user_id"] as? String ?? ""
                        self.accessTokenFinal = object?["access_token"] as? String ?? ""
                        
                        let graphApiUrl = "https://graph.instagram.com/"+"\(self.userID)"+"?fields=id,username&access_token=" + "\(self.accessTokenFinal)"
                        
                        AF.request(graphApiUrl, method: HTTPMethod(rawValue: HTTPMethod.get.rawValue), parameters: nil, encoding: URLEncoding.default,headers: HTTPHeaders(["Content-Type" : "application/x-www-form-urlencoded"]))
                            .responseJSON { response in
                            
                            print("Request URL : " + urlString)
                            print("Param : ",parameter)
                            
                            print(response)
                            
                            switch response.result {
                            case .success(let JSON):
                                let object = JSON as? NSDictionary
                                print(object)
                            case .failure(let error):
                                print(error)
                            }
                        }
                    }else {
                        self.showAlert(withMessage: errorMessage)
                        return
                    }
                    
                case .failure(let error):
                    print(error)
                    
                }
            }
    }
    
    public func webView(_ webView: WKWebView,
                        decidePolicyFor navigationAction: WKNavigationAction,
                        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        decisionHandler(.allow)
    }
    
    public func webView(_ webView: WKWebView,
                        decidePolicyFor navigationResponse: WKNavigationResponse,
                        decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        
        if isUrlValid {
            self.serviceCall(urlString: baseUrl ?? "")
        }
        
        
        
        if let response = navigationResponse.response as? HTTPURLResponse, response.statusCode == 200 {
            
            baseUrl = self.trimString(urlString: response.url?.absoluteString ?? "")
            
        }
        
        decisionHandler(.allow)
    }
    
    func trimString(urlString : String) -> String {
        
        
        var str:String = ""
        print(urlString)
        if !(urlString.contains("user_profile,user_media")) {
            let st = urlString.replacingOccurrences(of: "https://www.instagram.com/?code=", with: "")
            let st2 = st.replacingOccurrences(of: "#_", with: "")
            let access_token = st2.replacingOccurrences(of: "https://l.instagram.com/?u=https%3A%2F%2Finstagram.com%2F%3Fcode%3D", with: "")
            authToken = access_token
            isUrlValid = true
            str =  "https://api.instagram.com/oauth/access_token/"
            
            print(str)
        }
        return str
    }
}
