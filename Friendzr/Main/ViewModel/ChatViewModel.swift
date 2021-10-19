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

class ChatViewModel {
    
    // Initialise ViewModel's
    
    var listChat : DynamicType<ChatList> = DynamicType<ChatList>()
    var chatsTemp : ChatList = ChatListDataModel()
    
    var messages : DynamicType<MessagesChat> = DynamicType<MessagesChat>()
    var messagesTemp: MessagesChat = MessagesDataModel()
    
    var eventmessages:DynamicType<EventChatMessages> = DynamicType<EventChatMessages>()
    var eventmessagesTemp: EventChatMessages = EventMessagesModel()
    
    // Fields that bind to our view's
    var isSuccess : Bool = false
    var isLoading : Bool = false
    var error:DynamicType<String> = DynamicType()
    
    // create a method for calling api which is return a Observable
    //MARK:- Chat list
    func getChatList(pageNumber:Int) {
        
        let url = URLs.baseURLFirst + "Messages/UsersinChat"
        let headers = RequestComponent.headerComponent([.authorization,.type])
        
        let parameters:[String : Any] = ["pageNumber": pageNumber,"pageSize":20]
        
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
    func SendMessage(withUserId userId:String,AndMessage message:String,AndMessageType messagetype:Int,attachedImg:Bool,AndAttachImage attachImage:UIImage,completion: @escaping (_ error: String?, _ data: Bool?) -> ()) {
        
        let url = URLs.baseURLFirst + "Messages/SendMessage"
        
        let parameters:[String:Any] = ["UserId":userId,"Message":message,"Messagetype":messagetype]
        let oParam = NSString(string: parameters.description)
        print(oParam)
        
        if attachedImg {
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
            
            session.dataTask(with: request) { (data, response, error) in
                
                let httpResponse = response as? HTTPURLResponse
                let code  = httpResponse?.statusCode
                print(httpResponse!)
                print("statusCode: \(code!)")
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
                            if let toAdd = userResponse.isSuccessful {
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
            }.resume()
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
            
            session.dataTask(with: request) { (data, response, error) in
                
                let httpResponse = response as? HTTPURLResponse
                let code  = httpResponse?.statusCode
//                print(httpResponse!)
                print("statusCode: \(code!)")
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
                            if let toAdd = userResponse.isSuccessful {
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
            }.resume()
        }
    }
    
    //MARK:- Send Message with Event
    func SendMessage(withEventId eventId:String,AndMessageType messagetype:Int,AndMessage message:String,attachedImg:Bool,AndAttachImage attachImage:UIImage,completion: @escaping (_ error: String?, _ data: Bool?) -> ()) {
        
        let url = URLs.baseURLFirst + "Messages/SendEventMessage"
        
        let parameters:[String:Any] = ["EventId":eventId,"Message":message,"Messagetype":messagetype]
        let oParam = NSString(string: parameters.description)
        print(oParam)
        
        if attachedImg {
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
            
            session.dataTask(with: request) { (data, response, error) in
                
                let httpResponse = response as? HTTPURLResponse
                let code  = httpResponse?.statusCode
                print(httpResponse!)
                print("statusCode: \(code!)")
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
                            if let toAdd = userResponse.isSuccessful {
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
            }.resume()
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
            
            session.dataTask(with: request) { (data, response, error) in
                
                let httpResponse = response as? HTTPURLResponse
                let code  = httpResponse?.statusCode
                print(httpResponse!)
                print("statusCode: \(code!)")
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
                            if let toAdd = userResponse.isSuccessful {
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
            }.resume()
        }
    }
    
    func getChatMessages(ByUserId userid:String,pageNumber:Int) {
        
        let url = URLs.baseURLFirst + "Messages/Chatdata"
        let headers = RequestComponent.headerComponent([.authorization,.type])
        
        let parameters:[String : Any] = ["userid":userid,"pageNumber": pageNumber,"pageSize":10]
        
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
        
        let url = URLs.baseURLFirst + "Messages/EventChat"
        let headers = RequestComponent.headerComponent([.authorization,.type])
        
        let parameters:[String : Any] = ["Eventid":eventid,"pageNumber": pageNumber,"pageSize":10]
        
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
    
    
    //MARK:- mute chat
    func muteChat(ByID id:String,isevent:Bool,mute:Bool, completion: @escaping (_ error: String?, _ data: String?) -> ()) {
        
        let url = URLs.baseURLFirst + "Messages/muitchat"
        let headers = RequestComponent.headerComponent([.type,.authorization])
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
    func deleteChat(ByID id:String,isevent:Bool, completion: @escaping (_ error: String?, _ data: String?) -> ()) {
        
        let url = URLs.baseURLFirst + "Messages/Deletchat"
        let headers = RequestComponent.headerComponent([.type,.authorization])
        let parameters:[String : Any] = ["id":id,"isevent":isevent]

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
    
    func generateBoundary() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
}
