//
//  FaceRecognitionViewModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 23/01/2022.
//

import Foundation
import ObjectMapper
import MobileCoreServices
import Alamofire

class FaceRecognitionViewModel {
    
    
    // Fields that bind to our view's
    var isSuccess : Bool = false
    var isLoading : Bool = false
    var errorMsg : String = ""
    
    // create a method for calling api which is return a Observable
    
    //MARK:- Edit Profile
    func compare(withImage1 image1:UIImage,AndImage2 image2:UIImage,completion: @escaping (_ error: String?, _ data: String?) -> ()) {
        
        CancelRequest.currentTask = false
        let url = "https://confirmation.friendzr.com/compare/"
        
        guard let mediaImage1 = Media(withImage: image1, forKey: "image1") else { return }
        guard let mediaImage2 = Media(withImage: image2, forKey: "image2") else { return }
        
        guard let urlRequest = URL(string: url) else { return }
        var request = URLRequest(url: urlRequest)
        request.httpMethod = "POST"
        let boundary = generateBoundary()
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
//        request.addValue("Bearer \(Defaults.token)", forHTTPHeaderField: "Authorization")
        let dataBody = createDataBody(withParameters: nil, media: [mediaImage1,mediaImage2], boundary: boundary)
        request.httpBody = dataBody
        
        print(dataBody as Data)
        let session = URLSession.shared
        
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            
            let httpResponse = response as? HTTPURLResponse
            let code  = httpResponse?.statusCode
//            print(httpResponse!)
            print("statusCode: \(code ?? 0)")
            print("**MD** response: \(String(describing: response))")
            if code == 500 {
                self.errorMsg = "clear photo"
                completion(self.errorMsg,nil)
            }
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    let valJsonBlock = json as! [String : Any]
                    guard let userResponse = Mapper<FaceRecognitionModel>().map(JSON: valJsonBlock) else {
                        completion(self.errorMsg, nil)
                        return
                    }
                    
                    if code == 200 || code == 201 {
                        if let toAdd = userResponse.result {
                            completion(nil,toAdd)
                        }
                    }
                   
                    else {
                        if let error = userResponse.message {
                            print ("Error while fetching data \(error)")
                            self.errorMsg = error
                            completion(self.errorMsg,nil)
                        }
                    }
                } catch {
                    print(error)
                }
            }
        })
        if CancelRequest.currentTask == true {
            task.cancel()
        }else {
            task.resume()
        }
    }
    
    private func generateBoundaryString() -> String {
        return "Boundary-\(UUID().uuidString)"
    }
    
    private func mimeType(for path: String) -> String {
        let url = URL(fileURLWithPath: path)
        let pathExtension = url.pathExtension
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as NSString, nil)?.takeRetainedValue() {
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimetype as String
            }
        }
        return "application/octet-stream"
    }
    
    func createDataBody(withParameters params: Parameters?, media: [Media]?, boundary: String) -> Data {
        
        let lineBreak = "\r\n"
        var body = Data()
        
        if let parameters = params {
            for (key, value) in parameters {
                body.append("--\(boundary + lineBreak)")
                body.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak + lineBreak)")
                body.append("\("\(value)" + lineBreak)")
            }
        }
        
        if let media = media {
            for photo in media {
                body.append("--\(boundary + lineBreak)")
                body.append("Content-Disposition: form-data; name=\"\(photo.key)\"; filename=\"\(photo.filename)\"\(lineBreak)")
                body.append("Content-Type: \(photo.mimeType + lineBreak + lineBreak)")
                body.append(photo.data)
                body.append(lineBreak)
            }
        }
        
        body.append("--\(boundary)--\(lineBreak)")
        
        return body
    }
    
    func generateBoundary() -> String {
        return "Boundary-\(UUID().uuidString)"
    }
}
