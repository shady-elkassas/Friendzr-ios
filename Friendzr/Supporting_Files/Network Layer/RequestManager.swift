//
//  RequestManager.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 29/08/2021.
//

import Foundation
import Alamofire

class RequestManager  {
    func request(fromUrl url: String, byMethod method: String? = nil, withParameters parameters: [String:Any]?
                 , andHeaders headers: HTTPHeaders?, completion: @escaping (_ response:[String:Any]?, _ error: String?) -> ()) {
        
        let file = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        // Set up the URL request
        guard let url = URL.init(string: file) else {
            print("Error: cannot create URL")
            return
        }
        
        var urlRequest = URLRequest(url: url)
        
        urlRequest.httpMethod = method
        
        var bodyData = Data()
        for (key,value) in parameters ?? [:] {
            bodyData.append("\(key)=\(value)&".data(using: .utf8)!)
        }
        
        urlRequest.httpBody = bodyData.dropLast()
        
        urlRequest.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("Bearer \(Defaults.token)", forHTTPHeaderField: "Authorization")
        
        // set up the session
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        // vs let session = URLSession.shared
        
        
        // make the request
        let task = session.dataTask(with: urlRequest, completionHandler: {
            (data, response, error) in
            
            if (error != nil) {
                print(error!)
            } else {
                let httpResponse = response as? HTTPURLResponse
                let code  = httpResponse?.statusCode
                print(httpResponse!)
                print("statusCode: \(code!)")
                print("**MD** response: \(response)")
                
                if code == 200 || code == 201 {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                        print(json)
                        let valJsonBlock = json as! [String : Any]
                        completion(valJsonBlock,nil)
                    } catch {
                        print(error)
                    }
                }else {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                        print(json)
                        let valJsonBlock = json as! [String : Any]
                        completion([:],valJsonBlock["message"] as? String)
                    } catch {
                        print(error)
                    }
                    //                    }
                }
            }
        })
        task.resume()
    }
}

public enum ServerError: Error {
    
    case systemError(Error)
    case customError(String)
    // add http status errors
    public var details:(code:Int, message:String){
        switch self {
        case .customError(let errorMesg):
            return (0,errorMesg)
        case .systemError(let errCode) :
            return (errCode._code,errCode.localizedDescription)
            
        }
    }
}

public enum ServerErrorCodes:Int {
    case noMoreMovies = 10001
    case genericError = 20001
    
}

public enum ServerErrorMessages:String {
    case noMoreData = "No More Data"
    case genericError = "Unknown Server Error"
    
}