//
//  ChatViewModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 03/10/2021.
//

import Foundation
import ObjectMapper
import MobileCoreServices
import Alamofire
import SwiftUI

class ChatViewModel {
    
    // Initialise ViewModel's
    
    var listChat : DynamicType<ChatList> = DynamicType<ChatList>()
    var chatsTemp : ChatList = ChatListDataModel()
    
    var messages : DynamicType<MessagesChat> = DynamicType<MessagesChat>()
    var messagesTemp: MessagesChat = MessagesDataModel()
    
    var eventmessages:DynamicType<EventChatMessages> = DynamicType<EventChatMessages>()
    var eventmessagesTemp: EventChatMessages = EventMessagesModel()
    
    var groupmessages:DynamicType<GroupChatMessages> = DynamicType<GroupChatMessages>()
    var groupmessagesTemp: GroupChatMessages = GroupMessagesModel()
    
    
    // Fields that bind to our view's
    var isSuccess : Bool = false
    var isLoading : Bool = false
    var error:DynamicType<String> = DynamicType()
    
    // create a method for calling api which is return a Observable
    //MARK:- Chat list
    func getChatList(pageNumber:Int,search:String) {
        CancelRequest.currentTask = false
        let url = URLs.baseURLFirst + "Messages/UsersinChat"
        let headers = RequestComponent.headerComponent([.authorization,.type,.lang])
        
        let parameters:[String : Any] = ["pageNumber": pageNumber,"pageSize":20,"search":search]
        
        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: parameters, andHeaders: headers) { (data,error) in
            
            guard let userResponse = Mapper<ChatsListModel>().map(JSON: data!) else {
                self.error.value = error
                return
            }
            if let error = error {
                print ("Error while fetching data \(error)")
                self.error.value = error
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
    
    //MARK:- Send Message with user
    func SendMessage(withUserId userId:String,AndMessage message:String,AndMessageType messagetype:Int,messagesdate:String,messagestime:String,attachedImg:Bool,AndAttachImage attachImage:UIImage,_ fileUrl: URL? = URL(string: "https://www.apple.com/eg/"),eventShareid:String,latitude:String? = "",longitude:String? = "",locationName:String? = "",isLiveLocation:Bool? = false,locationStartTime:String? = "",locationEndTime:String? = "",locationPeriod:String? = "",completion: @escaping (_ error: String?, _ data: SendMessageObj?) -> ()) {
        CancelRequest.currentTask = false
        let url = URLs.baseURLFirst + "Messages/SendMessage"
        
        var parameters:[String:Any] = ["UserId":userId,"Message":message,"Messagetype":messagetype,"messagestime":messagestime,"messagesdate":messagesdate,"EventLINKid":eventShareid,"longitude":longitude ?? "","latitude":latitude ?? "","locationName":locationName ?? "","isLiveLocation":isLiveLocation ?? false,"locationStartTime":locationStartTime ?? "","locationPeriod":locationPeriod ?? "","locationEndTime":locationEndTime ?? ""]
        
//        let oParam = NSString(string: parameters.description)
//        print(oParam)

        if attachedImg {
            if messagetype == 2 {
                guard let mediaImage = Media(withImage: attachImage, forKey: "Attach") else { return }
                guard let urlRequest = URL(string: url) else { return }
                var request = URLRequest(url: urlRequest)
                request.httpMethod = "POST"
                let boundary = generateBoundary()
                
                request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                request.addValue("Bearer \(Defaults.token)", forHTTPHeaderField: "Authorization")
                let dataBody = createDataBody(withParameters: parameters, media: [mediaImage], boundary: boundary)
                request.httpBody = dataBody
                
                print(dataBody as Data)
                let session = URLSession.shared
                
                let task = session.dataTask(with: request, completionHandler: {(data, response, error) in
                    
                    let httpResponse = response as? HTTPURLResponse
                    let code  = httpResponse?.statusCode
                    //                    print(httpResponse!)
                    print("statusCode: \(code ?? 0)")
                    print("**MD** response: \(String(describing: response))")
                    
                    if let data = data {
                        do {
                            let json = try JSONSerialization.jsonObject(with: data, options: [])
                            let valJsonBlock = json as! [String : Any]
                            guard let userResponse = Mapper<SendMessageModel>().map(JSON: valJsonBlock) else {
                                completion(self.error.value, nil)
                                return
                            }
                            
                            if code == 200 || code == 201 {
                                if let toAdd = userResponse.data {
                                    completion(nil,toAdd)
                                }
                            }else {
                                if let error = userResponse.message {
                                    print ("Error while fetching data \(error)")
                                    self.error.value = error
                                    completion(self.error.value,nil)
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
            else if messagetype == 3 {
                guard let mediaImage = MediaFile(url: fileUrl!, forKey: "Attach") else { return }
                guard let urlRequest = URL(string: url) else { return }
                var request = URLRequest(url: urlRequest)
                request.httpMethod = "POST"
                let boundary = generateBoundary()
                
                request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                request.addValue("Bearer \(Defaults.token)", forHTTPHeaderField: "Authorization")
                let dataBody = createDataBodyFile(withParameters: parameters, media: [mediaImage], boundary: boundary)
                request.httpBody = dataBody
                
                print(dataBody as Data)
                let session = URLSession.shared
                
                let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
                    
                    let httpResponse = response as? HTTPURLResponse
                    let code  = httpResponse?.statusCode
                    //                    print(httpResponse!)
                    print("statusCode: \(code ?? 0)")
                    print("**MD** response: \(String(describing: response))")
                    
                    if let data = data {
                        do {
                            let json = try JSONSerialization.jsonObject(with: data, options: [])
                            let valJsonBlock = json as! [String : Any]
                            guard let userResponse = Mapper<SendMessageModel>().map(JSON: valJsonBlock) else {
                                completion(self.error.value, nil)
                                return
                            }
                            
                            if code == 200 || code == 201 {
                                if let toAdd = userResponse.data {
                                    completion(nil,toAdd)
                                }
                            }else {
                                if let error = userResponse.message {
                                    print ("Error while fetching data \(error)")
                                    self.error.value = error
                                    completion(self.error.value,nil)
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
        else {
            guard let urlRequest = URL(string: url) else { return }
            var request = URLRequest(url: urlRequest)
            request.httpMethod = "POST"
            let boundary = generateBoundary()
            
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(Defaults.token)", forHTTPHeaderField: "Authorization")
            let dataBody = createDataBody(withParameters: parameters, media: nil, boundary: boundary)
            request.httpBody = dataBody
            
            print(dataBody as Data)
            let session = URLSession.shared
            
            let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
                
                let httpResponse = response as? HTTPURLResponse
                let code  = httpResponse?.statusCode
                //                print(httpResponse!)
                print("statusCode: \(code ?? 0)")
                print("**MD** response: \(String(describing: response))")
                
                if let data = data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: [])
                        let valJsonBlock = json as! [String : Any]
                        guard let userResponse = Mapper<SendMessageModel>().map(JSON: valJsonBlock) else {
                            completion(self.error.value, nil)
                            return
                        }
                        
                        if code == 200 || code == 201 {
                            if let toAdd = userResponse.data {
                                completion(nil,toAdd)
                            }
                        }else {
                            if let error = userResponse.message {
                                print ("Error while fetching data \(error)")
                                self.error.value = error
                                completion(self.error.value,nil)
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
    
    //MARK:- Send Message with Event
    func SendMessage(withEventId eventId:String,AndMessageType messagetype:Int,AndMessage message:String,messagesdate:String,messagestime:String,attachedImg:Bool,AndAttachImage attachImage:UIImage,_ fileUrl: URL? = URL(string: "https://www.apple.com/eg/"),eventShareid:String,latitude:String? = "",longitude:String? = "",locationName:String? = "",isLiveLocation:Bool? = false,locationStartTime:String? = "",locationEndTime:String? = "",locationPeriod:String? = "",completion: @escaping (_ error: String?, _ data: SendMessageObj?) -> ()) {
        CancelRequest.currentTask = false
        let url = URLs.baseURLFirst + "Messages/SendEventMessage"
        
        let parameters:[String:Any] = ["EventId":eventId,"Message":message,"Messagetype":messagetype,"messagestime":messagestime,"messagesdate":messagesdate,"EventLINKid":eventShareid,"longitude":longitude ?? "","latitude":latitude ?? "","locationName":locationName ?? "","isLiveLocation":isLiveLocation ?? false,"locationStartTime":locationStartTime ?? "","locationEndTime":locationEndTime ?? "","locationPeriod":locationPeriod ?? ""]
        
//        let oParam = NSString(string: parameters.description)
//        print(oParam)
        
        if attachedImg {
            if messagetype == 2 {
                guard let mediaImage = Media(withImage: attachImage, forKey: "Attach") else { return }
                guard let urlRequest = URL(string: url) else { return }
                var request = URLRequest(url: urlRequest)
                request.httpMethod = "POST"
                let boundary = generateBoundary()
                
                request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                request.addValue("Bearer \(Defaults.token)", forHTTPHeaderField: "Authorization")
                let dataBody = createDataBody(withParameters: parameters, media: [mediaImage], boundary: boundary)
                request.httpBody = dataBody
                
                print(dataBody as Data)
                let session = URLSession.shared
                
                let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
                    
                    let httpResponse = response as? HTTPURLResponse
                    let code  = httpResponse?.statusCode
                    //                    print(httpResponse!)
                    print("statusCode: \(code ?? 0)")
                    print("**MD** response: \(String(describing: response))")
                    
                    if let data = data {
                        do {
                            let json = try JSONSerialization.jsonObject(with: data, options: [])
                            let valJsonBlock = json as! [String : Any]
                            guard let userResponse = Mapper<SendMessageModel>().map(JSON: valJsonBlock) else {
                                completion(self.error.value, nil)
                                return
                            }
                            
                            if code == 200 || code == 201 {
                                if let toAdd = userResponse.data {
                                    completion(nil,toAdd)
                                }
                            }else {
                                if let error = userResponse.message {
                                    print ("Error while fetching data \(error)")
                                    self.error.value = error
                                    completion(self.error.value,nil)
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
                
            }else if messagetype == 3 {
                guard let mediaFile = MediaFile(url: fileUrl!, forKey: "Attach") else { return }
                guard let urlRequest = URL(string: url) else { return }
                var request = URLRequest(url: urlRequest)
                request.httpMethod = "POST"
                let boundary = generateBoundary()
                
                request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                request.addValue("Bearer \(Defaults.token)", forHTTPHeaderField: "Authorization")
                let dataBody = createDataBodyFile(withParameters: parameters, media: [mediaFile], boundary: boundary)
                request.httpBody = dataBody
                
                print(dataBody as Data)
                let session = URLSession.shared
                
                let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
                    
                    let httpResponse = response as? HTTPURLResponse
                    let code  = httpResponse?.statusCode
                    //                    print(httpResponse!)
                    print("statusCode: \(code ?? 0)")
                    print("**MD** response: \(String(describing: response))")
                    
                    if let data = data {
                        do {
                            let json = try JSONSerialization.jsonObject(with: data, options: [])
                            let valJsonBlock = json as! [String : Any]
                            guard let userResponse = Mapper<SendMessageModel>().map(JSON: valJsonBlock) else {
                                completion(self.error.value, nil)
                                return
                            }
                            
                            if code == 200 || code == 201 {
                                if let toAdd = userResponse.data {
                                    completion(nil,toAdd)
                                }
                            }else {
                                if let error = userResponse.message {
                                    print ("Error while fetching data \(error)")
                                    self.error.value = error
                                    completion(self.error.value,nil)
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
        }else {
            guard let urlRequest = URL(string: url) else { return }
            var request = URLRequest(url: urlRequest)
            request.httpMethod = "POST"
            let boundary = generateBoundary()
            
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(Defaults.token)", forHTTPHeaderField: "Authorization")
            let dataBody = createDataBody(withParameters: parameters, media: nil, boundary: boundary)
            request.httpBody = dataBody
            
            print(dataBody as Data)
            let session = URLSession.shared
            
            let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
                
                let httpResponse = response as? HTTPURLResponse
                let code  = httpResponse?.statusCode
                //                print(httpResponse)
                print("statusCode: \(code ?? 0)")
                print("**MD** response: \(String(describing: response))")
                
                if let data = data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: [])
                        let valJsonBlock = json as! [String : Any]
                        guard let userResponse = Mapper<SendMessageModel>().map(JSON: valJsonBlock) else {
                            completion(self.error.value, nil)
                            return
                        }
                        
                        if code == 200 || code == 201 {
                            if let toAdd = userResponse.data {
                                completion(nil,toAdd)
                            }
                        }else {
                            if let error = userResponse.message {
                                print ("Error while fetching data \(error)")
                                self.error.value = error
                                completion(self.error.value,nil)
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
    
    func getChatMessages(ByUserId userid:String,pageNumber:Int) {
        let url = URLs.baseURLFirst + "Messages/Chatdata"
        let headers = RequestComponent.headerComponent([.authorization,.type,.lang])
        
        let parameters:[String : Any] = ["userid":userid,"pageNumber": pageNumber,"pageSize":20]
        
        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: parameters, andHeaders: headers) { (data,error) in
            
            guard let userResponse = Mapper<MessagesChatResponse>().map(JSON: data!) else {
                self.error.value = error
                return
            }
            if let error = error {
                print ("Error while fetching data \(error)")
                self.error.value = error
            }
            else {
                // When set the listener (if any) will be notified
                if let toAdd = userResponse.data {
                    if pageNumber > 1 {
                        for itm in toAdd.data ?? [] {
                            if !(self.messagesTemp.data?.contains(where: { $0.id == itm.id }) ?? false ) {
                                self.messagesTemp.data?.append(itm)
                            }
                        }
                        
                        self.messages.value = self.messagesTemp
                    } else {
                        self.messages.value = toAdd
                        self.messagesTemp = toAdd
                    }
                }
            }
        }
    }
    
    func getChatMessages(ByEventId eventid:String,pageNumber:Int) {
        //        CancelRequest.currentTask = false
        let url = URLs.baseURLFirst + "Messages/EventChat"
        let headers = RequestComponent.headerComponent([.authorization,.type,.lang])
        
        let parameters:[String : Any] = ["Eventid":eventid,"pageNumber": pageNumber,"pageSize":20]
        
        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: parameters, andHeaders: headers) { (data,error) in
            
            guard let userResponse = Mapper<EventChatMessagesResponse>().map(JSON: data!) else {
                self.error.value = error
                return
            }
            if let error = error {
                print ("Error while fetching data \(error)")
                self.error.value = error
            }
            else {
                // When set the listener (if any) will be notified
                if let toAdd = userResponse.data {
                    if pageNumber > 1 {
                        for itm in toAdd.pagedModel?.data ?? [] {
                            if !(self.eventmessagesTemp.pagedModel?.data?.contains(where: { $0.id == itm.id}) ?? false) {
                                self.eventmessagesTemp.pagedModel?.data?.append(itm)
                            }
                        }
                        self.eventmessages.value = self.eventmessagesTemp
                    } else {
                        self.eventmessages.value = toAdd
                        self.eventmessagesTemp = toAdd
                    }
                }
            }
        }
    }
    
    func SendMessage(withGroupId groupId:String,AndMessageType messagetype:Int,AndMessage message:String,messagesdate:String,messagestime:String,attachedImg:Bool,AndAttachImage attachImage:UIImage,_ fileUrl: URL? = URL(string: "https://www.apple.com/eg/"),eventShareid:String,latitude:String? = "",longitude:String? = "",locationName:String? = "",isLiveLocation:Bool? = false,locationStartTime:String? = "",locationEndTime:String? = "",locationPeriod:String? = "",completion: @escaping (_ error: String?, _ data: SendMessageObj?) -> ()) {
        
        CancelRequest.currentTask = false
        let url = URLs.baseURLFirst + "Messages/SendChatGroupMessage"
        
        let parameters:[String:Any] = ["ChatGroupID":groupId,"Message":message,"Messagetype":messagetype,"MessagesDateTime":"\(messagesdate) \(messagestime)","EventLINKid":eventShareid,"longitude":longitude ?? "","latitude":latitude ?? "","locationName":locationName ?? "","isLiveLocation":isLiveLocation ?? false,"locationStartTime":locationStartTime ?? "","locationPeriod":locationPeriod ?? "","locationEndTime":locationEndTime ?? ""]
        
//        let oParam = NSString(string: parameters.description)
//        print(oParam)
        
        if attachedImg {
            if messagetype == 2 {
                guard let mediaImage = Media(withImage: attachImage, forKey: "Attach_File") else { return }
                guard let urlRequest = URL(string: url) else { return }
                var request = URLRequest(url: urlRequest)
                request.httpMethod = "POST"
                let boundary = generateBoundary()
                
                request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                request.addValue("Bearer \(Defaults.token)", forHTTPHeaderField: "Authorization")
                let dataBody = createDataBody(withParameters: parameters, media: [mediaImage], boundary: boundary)
                request.httpBody = dataBody
                
                print(dataBody as Data)
                let session = URLSession.shared
                
                let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
                    
                    let httpResponse = response as? HTTPURLResponse
                    let code  = httpResponse?.statusCode
                    //                    print(httpResponse!)
                    print("statusCode: \(code ?? 0)")
                    print("**MD** response: \(String(describing: response))")
                    
                    if let data = data {
                        do {
                            let json = try JSONSerialization.jsonObject(with: data, options: [])
                            let valJsonBlock = json as! [String : Any]
                            guard let userResponse = Mapper<SendMessageModel>().map(JSON: valJsonBlock) else {
                                completion(self.error.value, nil)
                                return
                            }
                            
                            if code == 200 || code == 201 {
                                if let toAdd = userResponse.data {
                                    completion(nil,toAdd)
                                }
                            }else {
                                if let error = userResponse.message {
                                    print ("Error while fetching data \(error)")
                                    self.error.value = error
                                    completion(self.error.value,nil)
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
            else if messagetype == 3 {
                guard let mediaFile = MediaFile(url: fileUrl!, forKey: "Attach_File") else { return }
                guard let urlRequest = URL(string: url) else { return }
                var request = URLRequest(url: urlRequest)
                request.httpMethod = "POST"
                let boundary = generateBoundary()
                
                request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                request.addValue("Bearer \(Defaults.token)", forHTTPHeaderField: "Authorization")
                let dataBody = createDataBodyFile(withParameters: parameters, media: [mediaFile], boundary: boundary)
                request.httpBody = dataBody
                
                print(dataBody as Data)
                let session = URLSession.shared
                
                let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
                    
                    let httpResponse = response as? HTTPURLResponse
                    let code  = httpResponse?.statusCode
                    //                    print(httpResponse!)
                    print("statusCode: \(code ?? 0)")
                    print("**MD** response: \(String(describing: response))")
                    
                    if let data = data {
                        do {
                            let json = try JSONSerialization.jsonObject(with: data, options: [])
                            let valJsonBlock = json as! [String : Any]
                            guard let userResponse = Mapper<SendMessageModel>().map(JSON: valJsonBlock) else {
                                completion(self.error.value, nil)
                                return
                            }
                            
                            if code == 200 || code == 201 {
                                if let toAdd = userResponse.data {
                                    completion(nil,toAdd)
                                }
                            }else {
                                if let error = userResponse.message {
                                    print ("Error while fetching data \(error)")
                                    self.error.value = error
                                    completion(self.error.value,nil)
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
        else {
            guard let urlRequest = URL(string: url) else { return }
            var request = URLRequest(url: urlRequest)
            request.httpMethod = "POST"
            let boundary = generateBoundary()
            
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(Defaults.token)", forHTTPHeaderField: "Authorization")
            let dataBody = createDataBody(withParameters: parameters, media: nil, boundary: boundary)
            request.httpBody = dataBody
            
            print(dataBody as Data)
            let session = URLSession.shared
            
            let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
                
                let httpResponse = response as? HTTPURLResponse
                let code  = httpResponse?.statusCode
                //                print(httpResponse!)
                print("statusCode: \(code ?? 0)")
                print("**MD** response: \(String(describing: response))")
                
                if let data = data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: [])
                        let valJsonBlock = json as! [String : Any]
                        guard let userResponse = Mapper<SendMessageModel>().map(JSON: valJsonBlock) else {
                            completion(self.error.value, nil)
                            return
                        }
                        
                        if code == 200 || code == 201 {
                            if let toAdd = userResponse.data {
                                completion(nil,toAdd)
                            }
                        }else {
                            if let error = userResponse.message {
                                print ("Error while fetching data \(error)")
                                self.error.value = error
                                completion(self.error.value,nil)
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
    
    func getChatMessages(BygroupId groupId:String,pageNumber:Int) {
        //        CancelRequest.currentTask = false
        let url = URLs.baseURLFirst + "ChatGroup/GetChat"
        let headers = RequestComponent.headerComponent([.authorization,.type,.lang])
        
        let parameters:[String : Any] = ["ID":groupId,"pageNumber": pageNumber,"pageSize":20]
        
        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: parameters, andHeaders: headers) { (data,error) in
            
            guard let userResponse = Mapper<GroupChatMessagesResponse>().map(JSON: data!) else {
                self.error.value = error
                return
            }
            if let error = error {
                print ("Error while fetching data \(error)")
                self.error.value = error
            }
            else {
                // When set the listener (if any) will be notified
                if let toAdd = userResponse.data {
                    if pageNumber > 1 {
                        for itm in toAdd.pagedModel?.data ?? [] {
                            if !(self.groupmessagesTemp.pagedModel?.data?.contains(where: { $0.id == itm.id}) ?? false) {
                                self.groupmessagesTemp.pagedModel?.data?.append(itm)
                            }
                        }
                        self.groupmessages.value = self.groupmessagesTemp
                    } else {
                        self.groupmessages.value = toAdd
                        self.groupmessagesTemp = toAdd
                    }
                }
            }
        }
    }
    
    //MARK:- mute chat
    func muteChat(ByID id:String,isevent:Bool,mute:Bool, completion: @escaping (_ error: String?, _ data: String?) -> ()) {
        CancelRequest.currentTask = false
        let url = URLs.baseURLFirst + "Messages/muitchat"
        let headers = RequestComponent.headerComponent([.authorization,.type,.lang])
        let parameters:[String : Any] = ["id":id,"isevent":isevent,"muit": mute]
        
        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: parameters, andHeaders: headers) { (data,error) in
            guard let userResponse = Mapper<ChatsListModel>().map(JSON: data!) else {
                self.error.value = error!
                completion(self.error.value, nil)
                return
            }
            if let error = error {
                print ("Error while fetching data \(error)")
                self.error.value = error
                completion(self.error.value, nil)
            }
            else {
                // When set the listener (if any) will be notified
                if let toAdd = userResponse.message {
                    completion(nil,toAdd)
                }
            }
        }
    }
    
    //MARK:- delte chat
    func deleteChat(ByID id:String,isevent:Bool,deleteDateTime:String, completion: @escaping (_ error: String?, _ data: String?) -> ()) {
        CancelRequest.currentTask = false
        let url = URLs.baseURLFirst + "Messages/Deletchat"
        let headers = RequestComponent.headerComponent([.authorization,.type,.lang])
        let parameters:[String : Any] = ["id":id,"isevent":isevent,"DeleteDateTime":deleteDateTime]
        
        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: parameters, andHeaders: headers) { (data,error) in
            guard let userResponse = Mapper<ChatsListModel>().map(JSON: data!) else {
                self.error.value = error!
                completion(self.error.value, nil)
                return
            }
            if let error = error {
                print ("Error while fetching data \(error)")
                self.error.value = error
                completion(self.error.value, nil)
            }
            else {
                // When set the listener (if any) will be notified
                if let toAdd = userResponse.message {
                    completion(nil,toAdd)
                }
            }
        }
    }
    
    //MARK:- leave event chat
    func LeaveChat(ByID id:String,ActionDate:String,Actiontime:String, completion: @escaping (_ error: String?, _ data: String?) -> ()) {
        CancelRequest.currentTask = false
        let url = URLs.baseURLFirst + "Events/leaveeventchat"
        let headers = RequestComponent.headerComponent([.authorization,.type,.lang])
        let parameters:[String : Any] = ["EventDataid":id,"ActionDate":ActionDate,"Actiontime":Actiontime]
        
        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: parameters, andHeaders: headers) { (data,error) in
            guard let userResponse = Mapper<EventModel>().map(JSON: data!) else {
                self.error.value = error!
                completion(self.error.value, nil)
                return
            }
            if let error = error {
                print ("Error while fetching data \(error)")
                self.error.value = error
                completion(self.error.value, nil)
            }
            else {
                // When set the listener (if any) will be notified
                if let toAdd = userResponse.message {
                    completion(nil,toAdd)
                }
            }
        }
    }
    
    //MARK:- join event chat
    func joinChat(ByID id:String,ActionDate:String,Actiontime:String, completion: @escaping (_ error: String?, _ data: String?) -> ()) {
        CancelRequest.currentTask = false
        let url = URLs.baseURLFirst + "Events/joineventchat"
        let headers = RequestComponent.headerComponent([.authorization,.type,.lang])
        let parameters:[String : Any] = ["EventDataid":id,"ActionDate":ActionDate,"Actiontime":Actiontime]
        
        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: parameters, andHeaders: headers) { (data,error) in
            guard let userResponse = Mapper<EventModel>().map(JSON: data!) else {
                self.error.value = error!
                completion(self.error.value, nil)
                return
            }
            if let error = error {
                print ("Error while fetching data \(error)")
                self.error.value = error
                completion(self.error.value, nil)
            }
            else {
                // When set the listener (if any) will be notified
                if let toAdd = userResponse.message {
                    completion(nil,toAdd)
                }
            }
        }
    }
}

extension ChatViewModel {
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
    
    func createDataBodyFile(withParameters params: Parameters?, media: [MediaFile]?, boundary: String) -> Data {
        
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
