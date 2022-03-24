//
//  EditEventViewModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 06/09/2021.
//

import Foundation
import ObjectMapper
import MobileCoreServices
import Alamofire

class EditEventViewModel {
    
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
    
    func validateEditEventCredentials() -> Bool{
        
        isSuccess =  titleEventViewModel.validateCredentials() && descriptionViewModel.validateCredentials() && categoryEventViewModel.validateCredentials() && locationEventViewModel.validateCredentials() && totlalNumberEventViewModel.validateCredentials()
        
        errorMsg = "\(titleEventViewModel.errorValue ?? "")\(descriptionViewModel.errorValue ?? "")\(categoryEventViewModel.errorValue ?? "")\(locationEventViewModel.errorValue ?? "")\(totlalNumberEventViewModel.errorValue ?? "")"
        
        return isSuccess
    }
    
    // create a method for calling api which is return a Observable
    
    //MARK:- Edit event
    func editEvent(withID eventid:String,AndTitle title:String,AndDescription description:String,AndStatus status: String,AndCategory categoryId:String,lang:String,lat:String,totalnumbert:String,allday:Bool,eventdateFrom:String,eventDateto:String,eventfrom:String,eventto:String,eventTypeName:String,eventtype:String,showAttendees:Bool,listOfUserIDs:[String],attachedImg:Bool,AndImage image:UIImage,completion: @escaping (_ error: String?, _ data: String?) -> ()) {
        
        CancelRequest.currentTask = false
        titleEventViewModel.data = title
        descriptionViewModel.data = description
        categoryEventViewModel.data = categoryId
        locationEventViewModel.data = "\(lat)"
        totlalNumberEventViewModel.data = totalnumbert
        
        
        guard validateEditEventCredentials() else {
            completion(errorMsg, nil)
            return
        }
        
        let url = URLs.baseURLFirst + "Events/updateEventData"
        var parameters:[String : Any] = ["eventId":eventid,"Title": title,"description":description,"status":status,"categorieId":categoryId,"lang":lang,"lat":lat,"totalnumbert":totalnumbert,"allday":allday,"eventdate":eventdateFrom,"eventdateto":eventDateto,"eventfrom":eventfrom,"eventto":eventto,"eventtype":eventtype,"showAttendees":showAttendees]
        
        
        if eventTypeName == "Private" {
            if allday == true {
                parameters = ["eventId":eventid,"Title": title,"description":description,"status":status,"categorieId":categoryId,"lang":lang,"lat":lat,"totalnumbert":totalnumbert,"allday":allday,"eventdate":eventdateFrom,"eventdateto":eventDateto,"eventtype":eventtype,"ListOfUserIDs":listOfUserIDs,"showAttendees":showAttendees]
            }else {
                parameters = ["eventId":eventid,"Title": title,"description":description,"status":status,"categorieId":categoryId,"lang":lang,"lat":lat,"totalnumbert":totalnumbert,"allday":allday,"eventdate":eventdateFrom,"eventdateto":eventDateto,"eventfrom":eventfrom,"eventto":eventto,"eventtype":eventtype,"ListOfUserIDs":listOfUserIDs,"showAttendees":showAttendees]
            }
        }else {
            if allday == true {
                parameters = ["eventId":eventid,"Title": title,"description":description,"status":status,"categorieId":categoryId,"lang":lang,"lat":lat,"totalnumbert":totalnumbert,"allday":allday,"eventdate":eventdateFrom,"eventdateto":eventDateto,"eventtype":eventtype]
            }else {
            parameters = ["eventId":eventid,"Title": title,"description":description,"status":status,"categorieId":categoryId,"lang":lang,"lat":lat,"totalnumbert":totalnumbert,"allday":allday,"eventdate":eventdateFrom,"eventdateto":eventDateto,"eventfrom":eventfrom,"eventto":eventto,"eventtype":eventtype]
            }
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
                            if let toAdd = userResponse.message {
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
        else {
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
                            if let toAdd = userResponse.message {
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
