//
//  AddEventViewModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 05/09/2021.
//

import UIKit
import Foundation
import ObjectMapper
import MobileCoreServices
import Alamofire

class AddEventViewModel {
    
    // Initialise ViewModel's
    let titleEventViewModel = TitleEventViewModel()
    let descriptionViewModel = DescriptionViewModel()
    let categoryEventViewModel = CategoryEventViewModel()
    let locationEventViewModel = LocationEventViewModel()
    let totlalNumberEventViewModel = TotlalNumberEventViewModel()

    // Fields that bind to our view's
    var isSuccess : Bool = false
    var isLoading : Bool = false
    var errorMsg : String = ""
    
    func validateAddEventCredentials() -> Bool{
        
        isSuccess =  titleEventViewModel.validateCredentials() && descriptionViewModel.validateCredentials() && categoryEventViewModel.validateCredentials() && locationEventViewModel.validateCredentials() && totlalNumberEventViewModel.validateCredentials()
        
        errorMsg = "\(titleEventViewModel.errorValue ?? "")\(descriptionViewModel.errorValue ?? "")\(categoryEventViewModel.errorValue ?? "")\(locationEventViewModel.errorValue ?? "")\(totlalNumberEventViewModel.errorValue ?? "")"
        
        return isSuccess
    }
    
    // create a method for calling api which is return a Observable
    
    //MARK:- Add event
    func addNewEvent(withTitle title:String,AndDescription description:String,AndStatus status: String,AndCategory categoryId:String,lang:Double,lat:Double,totalnumbert:String,allday:Bool,eventdateFrom:String,eventDateto:String,eventfrom:String,eventto:String,creatDate:String,creattime:String,attachedImg:Bool,AndImage image:UIImage,completion: @escaping (_ error: String?, _ data: EventObj?) -> ()) {
        CancelRequest.currentTask = false
        titleEventViewModel.data = title
        descriptionViewModel.data = description
        categoryEventViewModel.data = categoryId
        locationEventViewModel.data = "\(lat)"
        totlalNumberEventViewModel.data = totalnumbert

        guard validateAddEventCredentials() else {
            completion(errorMsg, nil)
            return
        }
        
        let url = URLs.baseURLFirst + "Events/AddEventData"
        var parameters:[String : Any] = ["Title": title,"description":description,"status":status,"categoryid":categoryId,"lang":lang,"lat":lat,"totalnumbert": totalnumbert,"allday":allday,"eventdate":eventdateFrom,"eventdateto":eventDateto,"eventfrom":eventfrom,"eventto":eventto,"CreatDate":creatDate,"Creattime":creattime]
        
        if allday == true {
            parameters = ["Title": title,"description":description,"status":status,"categoryid":categoryId,"lang":lang,"lat":lat,"totalnumbert": totalnumbert,"allday":allday,"eventdate":eventdateFrom,"eventdateto":eventDateto,"CreatDate":creatDate,"Creattime":creattime]
        }
        
        if attachedImg {
            guard let mediaImage = Media(withImage: image, forKey: "Eventimage") else { return }
            guard let urlRequest = URL(string: url) else { return }
            var request = URLRequest(url: urlRequest)
            request.httpMethod = "POST"
            let boundary = generateBoundary()
            
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(Defaults.token)", forHTTPHeaderField: "Authorization")
            let dataBody = createDataBody(withParameters: parameters, media: [mediaImage], boundary: boundary)
            request.httpBody = dataBody
            
            let session = URLSession.shared
            
            let task = session.dataTask(with: request, completionHandler: {(data, response, error) in
                
                let httpResponse = response as? HTTPURLResponse
                let code  = httpResponse?.statusCode
                if let data = data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: [])
                        let valJsonBlock = json as! [String : Any]
                        guard let userResponse = Mapper<EventModel>().map(JSON: valJsonBlock) else {
                            completion(self.errorMsg, nil)
                            return
                        }
                        
                        if code == 200 || code == 201 {
                            // When set the listener (if any) will be notified
                            if let toAdd = userResponse.data {
                                completion(nil,toAdd)
                            }

                        }else {
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
        }else {
            guard let urlRequest = URL(string: url) else { return }
            var request = URLRequest(url: urlRequest)
            request.httpMethod = "POST"
            let boundary = generateBoundary()
            
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(Defaults.token)", forHTTPHeaderField: "Authorization")
            let dataBody = createDataBody(withParameters: parameters, media: nil, boundary: boundary)
            request.httpBody = dataBody
            
            let session = URLSession.shared
            
            let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
                
                let httpResponse = response as? HTTPURLResponse
                let code  = httpResponse?.statusCode
                
                if let data = data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: [])
                        let valJsonBlock = json as! [String : Any]
                        guard let userResponse = Mapper<EventModel>().map(JSON: valJsonBlock) else {
                            completion(self.errorMsg, nil)
                            return
                        }
                        
                        if code == 200 || code == 201 {
                            // When set the listener (if any) will be notified
                            if let toAdd = userResponse.data {
                                completion(nil,toAdd)
                            }

                        }else {
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

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

struct Media {
    let key: String
    let filename: String
    let data: Data
    let mimeType: String
    
    init?(withImage image: UIImage, forKey key: String) {
        self.key = key
        self.mimeType = "image/jpeg"
        self.filename = key+".jpeg"

        guard let data = image.jpegData(compressionQuality: 0) else { return nil }
        self.data = data
    }
}

struct MediaFile {
    let key: String
    let filename: String
    let data: Data
    let mimeType: String

    init?(url:URL ,forKey key: String) {
        self.key = key
        self.mimeType = "application/pdf"
        self.filename = "url.pdf"
//        filename = ".doc"
//        mimeType = "application/msword"
        let pdfData = try! Data(contentsOf: url.asURL())
        self.data = pdfData
    }
}
