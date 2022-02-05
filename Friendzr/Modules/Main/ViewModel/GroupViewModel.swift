//
//  GroupViewModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 17/01/2022.
//

import Foundation
import ObjectMapper
import MobileCoreServices
import Alamofire

class GroupViewModel {
    
    var groupMembers : DynamicType<GroupUsers> = DynamicType<GroupUsers>()

    var listChat : DynamicType<ChatList> = DynamicType<ChatList>()
    var chatsTemp : ChatList = ChatListDataModel()

    // Initialise ViewModel's
    let nameGroupViewModel = NameGroupViewModel()
    
    // Fields that bind to our view's
    var isSuccess : Bool = false
    var isLoading : Bool = false
    var errorMsg:DynamicType<String> = DynamicType()

    func validateAddGroupCredentials() -> Bool{
        
        isSuccess =  nameGroupViewModel.validateCredentials()
        
        errorMsg.value = "\(nameGroupViewModel.errorValue ?? "")"
        
        return isSuccess
    }
    
    // create a method for calling api which is return a Observable
    
    //MARK:- Add group
    func createGroup(withName name:String,AndListOfUserIDs listOfUserIDs:[String],AndRegistrationDateTime registrationDateTime: String,attachedImg:Bool,AndImage image:UIImage,completion: @escaping (_ error: String?, _ data: GroupModel?) -> ()) {
        
        CancelRequest.currentTask = false
        nameGroupViewModel.data = name
        
        guard validateAddGroupCredentials() else {
            completion(errorMsg.value, nil)
            return
        }
        
        let url = URLs.baseURLFirst + "ChatGroup/Create"
        let parameters:[String : Any] = ["Name": name,"ListOfUserIDs":listOfUserIDs,"RegistrationDateTime":registrationDateTime]
        
        if attachedImg {
            guard let mediaImage = Media(withImage: image, forKey: "Image_File") else { return }
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
                        guard let userResponse = Mapper<GroupResponse>().map(JSON: valJsonBlock) else {
                            completion(self.errorMsg.value, nil)
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
                                self.errorMsg.value = error
                                completion(self.errorMsg.value,nil)
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
                        guard let userResponse = Mapper<GroupResponse>().map(JSON: valJsonBlock) else {
                            completion(self.errorMsg.value, nil)
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
                                self.errorMsg.value = error
                                completion(self.errorMsg.value,nil)
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
    
    //MARK:- Add Users in Group
    func addUsersGroup(withGroupId id:String,AndListOfUserIDs listOfUserIDs:[String],AndRegistrationDateTime registrationDateTime: String,completion: @escaping (_ error: String?, _ data: GroupModel?) -> ()) {
        CancelRequest.currentTask = false
        let url = URLs.baseURLFirst + "ChatGroup/AddUsers"
        let headers = RequestComponent.headerComponent([.authorization,.type])
        let parameters:[String : Any] = ["ID": id,"RegistrationDateTime":registrationDateTime,"ListOfUserIDs":listOfUserIDs]
        
        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: parameters, andHeaders: headers) { (data,error) in
            
            guard let userResponse = Mapper<GroupResponse>().map(JSON: data!) else {
                self.errorMsg.value = error!
                completion(self.errorMsg.value, nil)
                return
            }
            if let error = error {
                self.errorMsg.value = error
                completion(self.errorMsg.value, nil)
            }
            else {
                // When set the listener (if any) will be notified
                if let toAdd = userResponse.data {
                    completion(nil, toAdd)
                }
            }
        }
    }
    
    //MARK :- mute group chat
    func muteGroupChat(ByID id:String,mute:Bool, completion: @escaping (_ error: String?, _ data: String?) -> ()) {
        CancelRequest.currentTask = false
        let url = URLs.baseURLFirst + "ChatGroup/MuteChatGroup"
        let headers = RequestComponent.headerComponent([.type,.authorization])
        let parameters:[String : Any] = ["ID":id,"IsMuted": mute]
        
        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: parameters, andHeaders: headers) { (data,error) in
            guard let userResponse = Mapper<GroupResponse>().map(JSON: data!) else {
                self.errorMsg.value = error!
                completion(self.errorMsg.value, nil)
                return
            }
            if let error = error {
                print ("Error while fetching data \(error)")
                self.errorMsg.value = error
                completion(self.errorMsg.value, nil)
            }
            else {
                // When set the listener (if any) will be notified
                if let toAdd = userResponse.message {
                    completion(nil,toAdd)
                }
            }
        }
    }
    
    //MARK : - delete users from group
    func deleteUsersGroup(withGroupId id:String,AndListOfUserIDs listOfUserIDs:[String],AndRegistrationDateTime registrationDateTime: String,completion: @escaping (_ error: String?, _ data: GroupModel?) -> ()) {
        CancelRequest.currentTask = false
        let url = URLs.baseURLFirst + "ChatGroup/kickOutUser"
        let headers = RequestComponent.headerComponent([.authorization,.type])
        let parameters:[String : Any] = ["ID": id,"RegistrationDateTime":registrationDateTime,"ListOfUserIDs":listOfUserIDs]
        
        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: parameters, andHeaders: headers) { (data,error) in
            
            guard let userResponse = Mapper<GroupResponse>().map(JSON: data!) else {
                self.errorMsg.value = error!
                completion(self.errorMsg.value, nil)
                return
            }
            if let error = error {
                self.errorMsg.value = error
                completion(self.errorMsg.value, nil)
            }
            else {
                // When set the listener (if any) will be notified
                if let toAdd = userResponse.data {
                    completion(nil, toAdd)
                }
            }
        }
    }
    
    //MARK:- leave group chat
    func leaveGroupChat(ByID id:String,registrationDateTime:String, completion: @escaping (_ error: String?, _ data: String?) -> ()) {
        CancelRequest.currentTask = false
        let url = URLs.baseURLFirst + "ChatGroup/Leave"
        let headers = RequestComponent.headerComponent([.type,.authorization])
        let parameters:[String : Any] = ["ID":id,"RegistrationDateTime":registrationDateTime]
        
        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: parameters, andHeaders: headers) { (data,error) in
            guard let userResponse = Mapper<GroupResponse>().map(JSON: data!) else {
                self.errorMsg.value = error!
                completion(self.errorMsg.value, nil)
                return
            }
            if let error = error {
                print ("Error while fetching data \(error)")
                self.errorMsg.value = error
                completion(self.errorMsg.value, nil)
            }
            else {
                // When set the listener (if any) will be notified
                if let toAdd = userResponse.message {
                    completion(nil,toAdd)
                }
            }
        }
    }
    
    //MARK : - Clear Chat Group
    func clearGroupChat(ByID id:String,registrationDateTime:String, completion: @escaping (_ error: String?, _ data: String?) -> ()) {
        CancelRequest.currentTask = false
        let url = URLs.baseURLFirst + "ChatGroup/ClearChatGroup"
        let headers = RequestComponent.headerComponent([.type,.authorization])
        let parameters:[String : Any] = ["ID":id,"RegistrationDateTime":registrationDateTime]
        
        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: parameters, andHeaders: headers) { (data,error) in
            guard let userResponse = Mapper<GroupResponse>().map(JSON: data!) else {
                self.errorMsg.value = error!
                completion(self.errorMsg.value, nil)
                return
            }
            if let error = error {
                print ("Error while fetching data \(error)")
                self.errorMsg.value = error
                completion(self.errorMsg.value, nil)
            }
            else {
                // When set the listener (if any) will be notified
                if let toAdd = userResponse.message {
                    completion(nil,toAdd)
                }
            }
        }
    }
    
    //MARK : - ChatGroup/Update
    
    func updateGroup(ByID Id:String,AndName name:String,attachedImg:Bool,AndImage image:UIImage,completion: @escaping (_ error: String?, _ data: String?) -> ()) {
        
        CancelRequest.currentTask = false
        nameGroupViewModel.data = name
        
        guard validateAddGroupCredentials() else {
            completion(errorMsg.value, nil)
            return
        }
        
        let url = URLs.baseURLFirst + "ChatGroup/Update"
        let parameters:[String : Any] = ["ID":Id,"Name": name]
        
        if attachedImg {
            guard let mediaImage = Media(withImage: image, forKey: "Image_File") else { return }
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
                        guard let userResponse = Mapper<GroupResponse>().map(JSON: valJsonBlock) else {
                            completion(self.errorMsg.value, nil)
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
                                self.errorMsg.value = error
                                completion(self.errorMsg.value,nil)
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
                        guard let userResponse = Mapper<GroupResponse>().map(JSON: valJsonBlock) else {
                            completion(self.errorMsg.value, nil)
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
                                self.errorMsg.value = error
                                completion(self.errorMsg.value,nil)
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
    
    
    //MARK :- delete group chat
    func deleteGroup(withGroupId id:String,completion: @escaping (_ error: String?, _ data: String?) -> ()) {
        CancelRequest.currentTask = false
        let url = URLs.baseURLFirst + "ChatGroup/Remove"
        let headers = RequestComponent.headerComponent([.authorization,.type])
        let parameters:[String : Any] = ["ID": id]
        
        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: parameters, andHeaders: headers) { (data,error) in
            
            guard let userResponse = Mapper<GroupResponse>().map(JSON: data!) else {
                self.errorMsg.value = error!
                completion(self.errorMsg.value, nil)
                return
            }
            if let error = error {
                self.errorMsg.value = error
                completion(self.errorMsg.value, nil)
            }
            else {
                // When set the listener (if any) will be notified
                if let toAdd = userResponse.message {
                    completion(nil, toAdd)
                }
            }
        }
    }
    
    //MARK :- group details
    func getGroupDetails(id:String,search:String) {
        CancelRequest.currentTask = false
        let url = URLs.baseURLFirst + "ChatGroup/GetChatGroup"
        let headers = RequestComponent.headerComponent([.authorization,.type])
        let parameters:[String : Any] = ["ID": id,"search":search]
        
        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: parameters, andHeaders: headers) { (data,error) in
            
            guard let userResponse = Mapper<GroupResponse>().map(JSON: data!) else {
                self.errorMsg.value = error!
                return
            }
            if let error = error {
                self.errorMsg.value = error
            }
            else {
                // When set the listener (if any) will be notified
                if let toAdd = userResponse.data {
                    self.groupMembers.value = toAdd
                }
            }
        }
    }
    
    func getAllGroupChat(pageNumber:Int,search:String) {
        CancelRequest.currentTask = false
        let url = URLs.baseURLFirst + "ChatGroup/GetAllChats"
        let headers = RequestComponent.headerComponent([.authorization,.type])
        
        let parameters:[String : Any] = ["pageNumber": pageNumber,"pageSize":10,"search":search]

        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: parameters, andHeaders: headers) { (data,error) in
            
            guard let userResponse = Mapper<ChatsListModel>().map(JSON: data!) else {
                self.errorMsg.value = error
                return
            }
            if let error = error {
                print ("Error while fetching data \(error)")
                self.errorMsg.value = error
            }
            else {
                // When set the listener (if any) will be notified
                if let toAdd = userResponse.data {
                    if pageNumber > 1 {
                        for itm in toAdd.data ?? [] {
                            if !(self.chatsTemp.data?.contains(where: { $0.id == itm.id }) ?? false) {
                                self.chatsTemp.data?.append(itm)
                            }
                        }
                        self.listChat.value = self.chatsTemp
                    } else {
                        self.listChat.value = toAdd
                        self.chatsTemp = toAdd
                    }
                }
            }
        }
    }
}


extension GroupViewModel {
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
