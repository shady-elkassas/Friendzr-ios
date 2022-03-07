//
//  RequestManager.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 29/08/2021.
//

import Foundation
import UIKit
import Alamofire

//Singleton
class CancelRequest {
    static var currentTask: Bool = false
}

class RequestManager  {
    
    let startDate = Date()

    func request(fromUrl url: String, byMethod method: String? = nil, withParameters parameters: [String:Any]?
                 , andHeaders headers: HTTPHeaders?, completion: @escaping (_ response:[String:Any]?, _ error: String?) -> ()) {
        
        let file = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        // Set up the URL request
        guard let url = URL.init(string: file) else {
            print("Error: cannot create URL")
            return
        }
        
        var urlRequest = URLRequest(url: url)
        
        //        urlRequest.allowsConstrainedNetworkAccess = true
        //        urlRequest.networkServiceType = URLRequest.NetworkServiceType.default
        //        urlRequest.allowsCellularAccess = true
        //        urlRequest.allowsExpensiveNetworkAccess = true
        
        urlRequest.httpMethod = method
        
        var bodyData = Data()
        for (key,value) in parameters ?? [:] {
            bodyData.append("\(key)=\(value)&".data(using: .utf8)!)
        }
        
        urlRequest.httpBody = bodyData.dropLast()
        print(String(data: bodyData.dropLast(), encoding: .utf8)!)
        
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("Bearer \(Defaults.token)", forHTTPHeaderField: "Authorization")
        
        // set up the session
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        // vs let session = URLSession.shared
        
        session.configuration.timeoutIntervalForRequest = 10 // seconds
        session.configuration.timeoutIntervalForResource = 10 // seconds
        
        // make the request
        let task = session.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            if (error != nil) {
                print(error!)
            }
            else {
                let httpResponse = response as? HTTPURLResponse
                let code  = httpResponse?.statusCode
                print("statusCode: \(code ?? 0)")
                print("**MD** response: \(String(describing: response))")
                
                if code == 200 || code == 201 {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                        print(json)
                        let valJsonBlock = json as! [String : Any]
                        completion(valJsonBlock,nil)
                    } catch {
                        print(error)
                    }
                }
                else if code == 400 {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                        print(json)
                        let valJsonBlock = json as! [String : Any]
                        completion([:],valJsonBlock["message"] as? String)
                    } catch {
                        print(error)
                    }
                }
                else if code == 401 {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                        print(json)
                        completion([:],"Unauthorized")
                        
                        DispatchQueue.main.async {
                            Router().toOptionsSignUpVC()
                        }
                    } catch {
                        print(error)
                    }
                }
                //500 network handling
                else if code == 500 || code == 501 || code == 502 || code == 503 {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                        print(json)
                        completion([:],"Internal Server Error")
                    } catch {
                        print(error)
                    }
                }
                else if code == 504 {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                        print(json)
                        completion([:],"Gateway Timeout")
                    } catch {
                        print(error)
                    }
                }
                else {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                        print(json)
                        let valJsonBlock = json as! [String : Any]
                        completion([:],valJsonBlock["message"] as? String)
                    } catch {
                        print(error)
                    }
                }
            }
        })

        let executionTimeWithSuccess = Date().timeIntervalSince(startDate)
        print("executionTimeWithSuccess \(executionTimeWithSuccess * 1000) second")
        
        if CancelRequest.currentTask == true {
            task.cancel()
        }else {
            task.resume()
        }
    }
}

//public enum ServerError: Error {
//
//    case systemError(Error)
//    case customError(String)
//    // add http status errors
//    public var details:(code:Int, message:String){
//        switch self {
//        case .customError(let errorMesg):
//            return (0,errorMesg)
//        case .systemError(let errCode) :
//            return (errCode._code,errCode.localizedDescription)
//
//        }
//    }
//}
//
//public enum ServerErrorCodes:Int {
//    case noMoreMovies = 10001
//    case genericError = 20001
//
//}
//
//public enum ServerErrorMessages:String {
//    case noMoreData = "No More Data"
//    case genericError = "Unknown Server Error"
//
//}
